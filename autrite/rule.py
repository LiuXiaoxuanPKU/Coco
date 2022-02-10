import copy
from multiprocessing import Condition
import z3
from constraint import NumericalConstraint
from mo_sql_parsing import parse, format

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
        return []

class RemovePredicate(Rule):
    def apply_single(self, q):
        return []

class AddPredicate(Rule):

    def apply_single(self, q):
        def extract_binops(q):
            def extract_cond(cond):
                key = list(cond.keys())
                assert(len(key) == 1)
                key = key[0]
                if key == "and" :
                    pass
                elif key == "or":
                    pass
                elif key in ["gt", "eq", "lt"]:
                    pass 

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
                    if c.min is not None and c.max is not None:
                        conditions.append(z3.And(tmp >= c.min, tmp <= c.max))
                    elif c.min is not None:
                        conditions.append(tmp >= c.min)
                    elif c.max is not None:
                        conditions.append(tmp <= c.max)
            return conditions


        # extract binary operations from where and join conditions
        # the output of binary operations is in z3 format
        binops = extract_binops(q)

        # extarct constraints
        # and translate into z3 format
        binops += extract_constraints()


        # TODO: generate candidate predicates
        # candidate_predicates = deduct(z3_ops)

        # add candidate predicates to q
        return []