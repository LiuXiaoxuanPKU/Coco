from config import REWRITE_LIMIT, RewriteQuery
from constraint import *
from rule import AddPredicate, RemoveDistinct, AddLimitOne, RemoveJoin, RemovePredicate, RewriteNullPredicate, UnionToUnionAll, ReplaceOuterJoin
from mo_sql_parsing import format

class Rewriter:
    def __init__(self) -> None:
        self.rules = []

    def set_rules(self, rules):
        self.rules = rules

    def rewrite(self, constraints, q):
        # identify constraints in q
        constraints = Rewriter.get_q_constraints(constraints, q.q_obj)
        if not len(constraints):
            return []
        
        # use constraints to generate potential rules
        rules = self.get_rules(constraints)

        # order rules, apply slow rules (add predicate, remove predicate) first
        rules.sort()

        rewritten_queries = self.bfs(rules, q)

        return rewritten_queries

    
    # select * from R where a = 1
    # UniqueConstraint(a)
    @staticmethod
    def get_q_constraints(constraints, q):
        def extract_q_field(q):
            q_str = format(q)
            def table_in_field():
                for t in q_str.split(' '):
                    if len(t.split('.')) > 1:
                        return True
                return False
            
            # TODO: extract all the fields insteaf of all the tokens
            tokens = [t.lower().split('.')[-1] for t in q_str.split(' ')]
            #if there are table names in the field
            if table_in_field():
                table_field_name = [t for t in q_str.split(' ') if len(t.split('.')) > 1]
                tables = [t.lower().split('.')[0] for t in table_field_name]
            else: # does not have join
                assert(isinstance(q['from'], str))
                tables = [q['from'].lower()]
            return tokens, list(set(tables))
                

        def get_field_constraint(table_field, constraints, all_used_fields, tables):
            field_constraints = []
            for c in constraints:
                if isinstance(c.field, str) and c.field == table_field and c.table in tables:
                    field_constraints.append(c)
                elif isinstance(c.field, list) and \
                    set(c.field).issubset(all_used_fields) and \
                    set([c.table.lower()]).issubset(tables):
                    field_constraints.append(c)
            return field_constraints

        # extract fields in q
        fields, tables = extract_q_field(q)
        q_constraints = []
        # print(fields, tables)
        for table_field in fields:
            cs = get_field_constraint(table_field, constraints, fields, tables)
            q_constraints += cs
        
        return list(set(q_constraints))

    def get_rules(self, constraints):
        constraint_rule_map = {
            UniqueConstraint : [RemoveDistinct, AddLimitOne],
            NumericalConstraint : [AddPredicate, RemovePredicate],
            PresenceConstraint : [RewriteNullPredicate, ReplaceOuterJoin, RemoveJoin],
            InclusionConstraint : [], 
            LengthConstraint : [],
            FormatConstraint : [],
            ForeignKeyConstraint : [RemoveJoin]
            }
        rules = []
        for c in constraints:
            rules += [r(c) for r in constraint_rule_map[type(c)]]
        # always add remove distinct
        rules += [RemoveDistinct(None)]
        rules = set(rules)
        if self.rules != []:
            return [r for r in rules if type(r) in self.rules]
        else:
            return list(rules) 

    def bfs(self, rules, q):
        rewritten_queries = [q]
        for rule in rules:
            if len(rewritten_queries) > REWRITE_LIMIT:
                break
            rule_rewritten_q_objs = []
            for rq in rewritten_queries:
                rule_rewrites = rule.apply(rq.q_obj)
                for rule_rewrite in rule_rewrites:
                    rewrite_q = RewriteQuery(format(rule_rewrite), rule_rewrite)
                    rewrite_q.rewrites = rq.rewrites + [rule]
                    rule_rewritten_q_objs.append(rewrite_q)
                    
            rewritten_queries += rule_rewritten_q_objs
    
        return rewritten_queries[1:]




