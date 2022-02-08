from mo_sql_parsing import parse, format

class Rule:
    def __init__(self, name) -> None:
        self.name = name

    def __str__(self) -> str:
        return self.name

    @staticmethod
    def get_nested_query(q):
        if 'from' in q and isinstance(q['from'], dict):
            return q['from']
        return None
    
    @staticmethod
    def replace_nested_query(org_q, sub_q):
        assert('from' in org_q)
        org_q['from'] = sub_q
        return org_q

class RemoveDistinct(Rule):
    @staticmethod
    def get_name():
        return str(RemoveDistinct)

    @staticmethod
    def apply(q):
        rewritten_qs = []
        rewritten_q = None
        if 'select_distinct' in q:
            rewritten_q = q.copy()
            rewritten_q['select'] = rewritten_q['select_distinct']
            del rewritten_q['select_distinct']
            rewritten_qs.append(rewritten_q)

        rewritten_sub_qs = []
        nested_query = Rule.get_nested_query(q)
        if nested_query:
            rewritten_sub_qs = RemoveDistinct.apply(nested_query)
        for sub_q in rewritten_sub_qs:
            rewritten_qs.append(Rule.replace_nested_query(q.copy(), sub_q))
            if rewritten_q:
                rewritten_qs.append(Rule.replace_nested_query(rewritten_q.copy(), sub_q))
        return rewritten_qs


class AddLimitOne(Rule):
    @staticmethod
    def get_name():
        return str(AddLimitOne)

    @staticmethod
    def apply(q):
        rewritten_qs = []
        rewritten_q = None
        if 'limit' not in q:
            rewritten_q = q.copy()
            rewritten_q['limit'] = 1
            rewritten_qs.append(rewritten_q)

        rewritten_sub_qs = []
        nested_query = Rule.get_nested_query(q)
        if nested_query:
            rewritten_sub_qs = AddLimitOne.apply(nested_query)
        for sub_q in rewritten_sub_qs:
            rewritten_qs.append(Rule.replace_nested_query(q.copy(), sub_q))
            if rewritten_q:
                rewritten_qs.append(Rule.replace_nested_query(rewritten_q.copy(), sub_q))
        return rewritten_qs

class RemoveJoin(Rule):
    pass

class UnionToUnionAll(Rule):
    pass

class RemovePredicate(Rule):
    pass

class AddPredicate(Rule):
    pass