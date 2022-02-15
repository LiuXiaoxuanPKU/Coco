import copy
from email.utils import collapse_rfc2231_value
from http.client import UnimplementedFileMode
from lib2to3.pgen2 import token
from lib2to3.pgen2.tokenize import TokenError
from multiprocessing import Condition
import z3
from constraint import NumericalConstraint
from mo_sql_parsing import parse, format
from itertools import combinations

class Rule:
    def __init__(self, cs) -> None:
        self.constraints = cs

    def __str__(self) -> str:
        return self.name

    @staticmethod
    def keyword_nested(keyword, q):
        if keyword in ["select", "select_distinct"]:
            if keyword in q and isinstance(q[keyword], dict):
                return q[keyword]['value']
        
        if keyword == 'from' and 'from' in q and isinstance(q['from'], dict):
            return q['from']

        return []

    @staticmethod
    def replace_keyword_nested(org_q, keyword, sub_q):
        if keyword == "select" or keyword == 'select_distinct':
            org_q[keyword]['value'] = sub_q
        elif  keyword in ['from', 'where', 'having']:
            org_q[keyword] = sub_q
        return org_q


    def get_name(self):
        return str(self)

    # rewrite the entire query, call apply_single
    # handle nested queries
    def apply(self, q):
        if not isinstance(q, dict):
            return []

        # subquery happens in WHERE, FROM, SELECT, HAVING
        rewritten_qs = [q]
        outer_rewritten_q =  self.apply_single(q)
        if len(outer_rewritten_q):
            rewritten_qs += outer_rewritten_q

        # SELECT, FROM
        for k in ["select", "select_distinct", "from"]:
            tmp_rewritten_qs = []
            for rq in rewritten_qs:
                keyword_sub = Rule.keyword_nested(k, rq)
                if keyword_sub:
                    rewritten_keyword_subs = self.apply(keyword_sub)
                    for sub in rewritten_keyword_subs:
                        rewritten_q = Rule.replace_keyword_nested(copy.deepcopy(rq), k, sub)
                        tmp_rewritten_qs.append(rewritten_q)
            rewritten_qs += tmp_rewritten_qs
        
        def rewrite_cond(cond):
            rewritten_cond = []
            assert(len(cond) == 1)
            op = list(cond.keys())[0]
            if op == "and" or op == "or":
                lhs, rhs = cond[op][0], cond[op][1]
                rewritten_lhs = [lhs] + rewrite_cond(lhs)
                rewritten_rhs = [rhs] + rewrite_cond(rhs)
                for r1 in rewritten_lhs:
                    for r2 in rewritten_rhs:
                        if not (r1 == lhs and r2 == rhs):
                            rewritten_cond.append({op:[copy.deepcopy(r1), copy.deepcopy(r2)]})
            else:
                lhs, rhs = cond[op][0], cond[op][1]
                # nested query
                if isinstance(rhs, dict):
                    rewritten_rhs = self.apply(rhs)
                    for r1 in rewritten_rhs:
                        rewritten_cond.append({op:[copy.deepcopy(lhs), r1]})
            return rewritten_cond


        # WHERE, HAVING
        for k in ["where", "having"]:
            tmp_rewritten_qs = []
            for rq in rewritten_qs:
                if k not in rq:
                    continue
                rewritten_conds = rewrite_cond(rq[k])
                for c in rewritten_conds:
                    rq =  copy.deepcopy(rq)
                    rewritten_q = Rule.replace_keyword_nested(rq, k, c)
                    tmp_rewritten_qs.append(rewritten_q)

            rewritten_qs += tmp_rewritten_qs
        
        return rewritten_qs[1:]


    # rewrite subquery, different rules behavior differently
    def apply_single(self, q):
        raise NotImplementedError("Sub class must override apply_single")


class RemoveDistinct(Rule):
    def apply_single(self, q):
        if 'select_distinct' in q:
            rewritten_q =  copy.deepcopy(q)
            rewritten_q['select'] = rewritten_q['select_distinct']
            del rewritten_q['select_distinct']
            return [rewritten_q]
        return []


class AddLimitOne(Rule):
    def apply_single(self, q):
        if 'limit' not in q:
            rewritten_q =  copy.deepcopy(q)
            rewritten_q['limit'] = 1
            return [rewritten_q]
        return []

class RemoveJoin(Rule):
    pass

class UnionToUnionAll(Rule):
    def apply_single(self, q):
        if 'union' in q:
            q['union all'] = q.pop('union')
        return [q]

class RemovePredicate(Rule):
    def apply_single(self, q):
        if 'where' not in q:
            return []
        
        def rewrite_where(clause):
            return_wheres = []
            op = list(clause.keys())[0]
            if op == "and" or op == "or":
                clause_list = clause[op]
                predicates_combo = []
                for n in range(1, len(clause_list)):
                    predicates_combo += list(combinations(clause_list, n))
                for p in predicates_combo:
                    if len(p) == 1:
                        pred = p[0]
                        nested_preds = rewrite_where(pred)
                        for np in nested_preds:
                            # ????
                            for p2 in predicates_combo:
                                if len(p2) > 1 or "and" not in p2[0] and "or" not in p2[0]:
                                    p2list = list(p2)
                                    p2list.append(np)
                                    return_wheres.append({op: p2list})
                            return_wheres.append(np)
                            # ????
                        return_wheres.append(pred)
                    else:
                        return_wheres.append({op: list(p)})
            # print(return_wheres)
            return return_wheres
        # print(q['where'])

        rq = copy.deepcopy(q)
        where_clause = rq.pop('where', None)
        rewritten_qs = [rq]
        for where in rewrite_where(where_clause):
            rq = copy.deepcopy(q)
            rq['where'] = where
            rewritten_qs.append(rq)
        # print(rewritten_qs)
        return rewritten_qs

class AddPredicate(Rule):
    def apply_single(self, q):
        tokens = []

        def translate_token(t):
            if isinstance(t, int) or isinstance(t, float):
                tokens.append(t)
                return t
            elif isinstance(t, str):
                t = z3.Real(t)
                tokens.append(t)
                return t
            else:
                raise NotImplementedError("translate token does not support type %s of %s" % (type(t), t))

        def extract_binops(q):
            def extract_cond(cond):
                key = list(cond.keys())
                assert(len(key) == 1)
                key = key[0]
                # TODO: does not handle exist for now
                lhs, rhs = cond[key][0], cond[key][1]
                if key == "and" :
                    return z3.And(extract_cond(lhs), extract_cond(rhs))
                elif key == "or":
                    return z3.Or(extract_cond(lhs), extract_cond(rhs))
                elif key in ["gt", "eq", "lt"]:
                    lhs, rhs = translate_token(lhs), translate_token(rhs)
                    if key == "gt":
                        return lhs > rhs
                    elif key == "eq":
                        return lhs == rhs
                    elif key == "lt":
                        return lhs < rhs

            def extract_join():
                pass

            conditions = []
            if 'where' in q:
                conditions.append(extract_cond(q['where']))
            if 'join' in q:
                conditions += extract_join(q['join'])
            return conditions

        def extract_constraints():
            conditions = []
            for c in self.constraints:
                if isinstance(c, NumericalConstraint):
                    tmp = z3.Real(c.field)
                    tokens.append(tmp)
                    if c.min is not None and c.max is not None:
                        conditions.append(z3.And(tmp >= c.min, tmp <= c.max))
                        tokens.append(c.min)
                        tokens.append(c.max)
                    elif c.min is not None:
                        conditions.append(tmp >= c.min)
                        tokens.append(c.min)
                    elif c.max is not None:
                        conditions.append(tmp <= c.max)
                        tokens.append(c.max)
            return conditions


        def deduct(binops):
            candidates = []
            for lhs in set(tokens):
                for rhs in set(tokens):
                    if not (isinstance(lhs, z3.z3.ArithRef) or isinstance(rhs, z3.z3.ArithRef)):
                        continue
                    if lhs is not rhs:
                        candidates.append(lhs > rhs)
                        candidates.append(lhs == rhs)
            print(candidates)
            cond = None
            for binop in binops:
                if cond is None:
                    cond = binop
                else:
                    cond = z3.And(cond, binop)

            variables = [x for x in set(tokens) if isinstance(x, z3.z3.ArithRef)]
            
            validate_candidates = []
            for candidate in candidates:
                s = z3.Solver()
                s.add(z3.ForAll(variables, z3.Implies(cond, candidate)))
                if s.check() == z3.sat:
                    validate_candidates.append(candidate)
            return validate_candidates

        # extract binary operations from where and join conditions
        # the output of binary operations is in z3 format
        binops = extract_binops(q)

        # extarct constraints
        # and translate into z3 format
        binops += extract_constraints()

        candidate_predicates = deduct(binops)

        rewritten_qs = []
        def z3op_to_json(binop):
            op_map = {
                '>' : 'gt',
                '==' : 'eq',
                '<' : 'lt'
            }
            return {op_map[str(binop.decl())]: binop.children()}

        print(candidate_predicates)
        # add candidate predicates to q
        for candidate in candidate_predicates:
            rq = copy.deepcopy(q)
            org_pred = rq['where']
            rq['where'] = {'and': [org_pred, z3op_to_json(candidate)]}
            rewritten_qs.append(rq)
        return rewritten_qs
