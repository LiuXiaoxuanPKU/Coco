import copy
from mo_sql_parsing import parse, format

class Rule:
    def __init__(self, name) -> None:
        self.name = name

    def __str__(self) -> str:
        return self.name

    @staticmethod
    def keyword_nested(keyword, q):
        if keyword in ["select", "select_distinct"]:
            if keyword in q and isinstance(q[keyword], dict):
                return q[keyword]['value']
        
        if keyword == 'from' and 'from' in q and isinstance(q['from'], dict):
            return q['from']

        return None
    
    @staticmethod
    def replace_keyword_nested(org_q, keyword, sub_q):
        if keyword == "select" or keyword == 'select_distinct':
            org_q[keyword]['value'] = sub_q
        elif  keyword in ['from', 'where', 'having']:
            org_q[keyword] = sub_q
        return org_q


    @classmethod
    def get_name(cls):
        return str(cls)

    # rewrite the entire query, call apply_single
    # handle nested queries
    @classmethod
    def apply(cls, q):
        if not isinstance(q, dict):
            return []

        # subquery happens in WHERE, FROM, SELECT, HAVING
        rewritten_qs = [q]
        outer_rewritten_q =  cls.apply_single(q)
        if len(outer_rewritten_q):
            rewritten_qs += outer_rewritten_q

        # SELECT, FROM
        for k in ["select", "select_distinct", "from"]:
            tmp_rewritten_qs = []
            for rq in rewritten_qs:
                keyword_sub = Rule.keyword_nested(k, rq)
                if keyword_sub:
                    rewritten_keyword_subs = cls.apply(keyword_sub)
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
                    rewritten_rhs = cls.apply(rhs)
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
    @staticmethod
    def apply_single(q):
        raise NotImplementedError("Sub class must override apply_single")


class RemoveDistinct(Rule):
    @staticmethod
    def apply_single(q):
        if 'select_distinct' in q:
            rewritten_q =  copy.deepcopy(q)
            rewritten_q['select'] = rewritten_q['select_distinct']
            del rewritten_q['select_distinct']
            return [rewritten_q]
        return None


class AddLimitOne(Rule):
    @staticmethod
    def apply_single(q):
        if 'limit' not in q:
            rewritten_q =  copy.deepcopy(q)
            rewritten_q['limit'] = 1
            return [rewritten_q]

        return None

class RemoveJoin(Rule):
    pass

class UnionToUnionAll(Rule):
    @staticmethod
    def apply_single(q):
        return None

class RemovePredicate(Rule):
    @staticmethod
    def apply_single(q):
        return None

class AddPredicate(Rule):
    @staticmethod
    def apply_single(q):
        # extract binary operations from q
        binops = extract_binops(q)

        # translate binary operations into z3 format
        z3_ops = translate_z3(binops)

        # generate candidate predicates
        candidate_predicates = deduct(z3_ops)

        # add candidate predicates to q
        return None