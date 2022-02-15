from collections import deque
from constraint import *
from rule import AddPredicate, RemoveDistinct, AddLimitOne, RemoveJoin, RemovePredicate, UnionToUnionAll
from mo_sql_parsing import format

class Rewriter:
    def __init__(self) -> None:
        pass

    def rewrite(self, constraints, q):
        # identify constraints in q
        constraints = self.get_q_constraints(constraints, q)
        if not len(constraints):
            return [q]
        
        # use constraints to generate potential rules
        rules = self.get_rules(constraints)
        # for c in set(constraints):
        #     print(str(c), hash(c))

        rewritten_queries = self.bfs(rules, q)

        return rewritten_queries

    
    # select * from R where a = 1
    # UniqueConstraint(a)
    def get_q_constraints(self, constraints, q):
        def extract_q_field(q):
            # TODO: extract all the fields insteaf of all the tokens
            q_str = format(q)
            tokens = [t.lower().split('.')[-1] for t in q_str.split(' ')]
            return tokens

        def get_field_constraint(field, constraints):
            field_constraints = []
            for c in constraints:
                if c.field == field:
                    field_constraints.append(c)
            return field_constraints

        # extract fields in q
        fields = extract_q_field(q)
        q_constraints = []
        for field in fields:
            cs = get_field_constraint(field, constraints)
            q_constraints += cs
        
        return list(set(q_constraints))

    def get_rules(self, constraints):
        constraint_rule_map = {
            UniqueConstraint : [RemoveDistinct, AddLimitOne],
            NumericalConstraint : [AddPredicate, RemovePredicate],
            PresenceConstraint : [],
            InclusionConstraint : [],
            LengthConstraint : [],
            FormatConstraint : []
            }
        rules = []
        for c in constraints:
            rules += [r(c) for r in constraint_rule_map[type(c)]]
        return list(set(rules))

    def bfs(self, rules, q):
        rewritten_queries = [q]
        for rule in rules:
            rule_rewritten_qs = []
            for rq in rewritten_queries:
                rule_rewritten_qs += rule.apply(rq)
            rewritten_queries += rule_rewritten_qs
    
        return rewritten_queries[1:]




