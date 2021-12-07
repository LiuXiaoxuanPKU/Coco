from enum import Enum
import functools


class Rewriter:
    class RewriteType(Enum):
        ADD_LIMIT_ONE = 1
        REMOVE_DISTINCT = 2
        LENGTH_PRECHECK = 3
        FORMAT_PRECHECK = 4
        REMOVE_PREDICATE_NULL = 5
        REMOVE_PREDICATE_NUMERICAL = 6
        STRING_TO_INT = 7

    def __init__(self) -> None:
        self.queryset = set()

    def get_constraint_fields(self, constraints, constraint_type):
        '''
        return the full name of constraint, field name is in the format of xx.xx
        '''
        selected_constraints = filter(
            lambda x: isinstance(x, constraint_type), constraints)
        return list(map(lambda x: x.table + "." + x.field, selected_constraints))

    def get_join_tables(self, q):
        table = q['from']
        join_tables = list(functools.reduce(
            lambda acc, item: acc + [item['inner join']] if ('inner join' in item) else acc, table, []))
        return join_tables

    def get_query_tables(self, q):
        join_tables = self.get_join_tables(q)
        table = q['from']
        org_table = [t for t in table if isinstance(t, str)]
        return join_tables + org_table

    def check_query_has_join(self, q):
        return len(self.get_join_tables(q)) > 0

    def find_field_in_predicate(self, field, predicate):
        if not isinstance(predicate, dict):
            return False
        keys = list(predicate.keys())
        assert(len(keys) == 1)
        key = keys[0]
        values = list(predicate[key])

        # case: where 1=1
        if key == "coalesce":
            return False
        if isinstance(values[0], int):
            return False
        if isinstance(values[0], str):
            return field in values
        return functools.reduce(lambda acc, item: acc or self.find_field_in_predicate(field, item), values, False)

    from ._rewrite_add_limit_one import add_limit_one
    from ._rewrite_remove_distinct import remove_distinct
    from ._rewrite_str2int import str2int
    from ._rewrite_remove_predicate import remove_predicate_numerical, remove_predicate_null
    from ._rewrite_strlen_precheck import strlen_precheck
    from ._rewrite_format_precheck import strformat_precheck

    def rewrite_all_subqueries(self, from_clause, constraints, rewrite_type_set):
        def rewrite_subquery(subquery):
            if isinstance(subquery, dict) and 'value' in subquery and isinstance(subquery['value'], dict):
                sub_rewritten, sub_rewrite_type = self.rewrite_single_query(
                    subquery['value'], constraints)
                subquery['value'] = sub_rewritten
                return sub_rewrite_type
            return set()

        if isinstance(from_clause, list):
            for subquery in from_clause:
                rewrite_type_set.update(rewrite_subquery(subquery))
        elif isinstance(from_clause, dict):
            rewrite_type_set.update(rewrite_subquery(from_clause))
        return rewrite_type_set

    def rewrite_single_query(self, q, constraints):
        rewrite_type = set()
        rewrite_set_add_limit_one, rewrite_q = self.add_limit_one(
            q, constraints)
        rewrite_type.update(rewrite_set_add_limit_one)
        if rewrite_set_add_limit_one:
            # print("Add limit 1 ", format(rewrite_q))
            q = rewrite_q
        rewrite_set_str2int, _ = self.str2int(q, constraints)
        rewrite_type.update(rewrite_set_str2int)
        # if rewrite_set_str2int:
        # print("String to Int", format(q), rewrite_fields)
        rewrite_set_strlen_precheck, _ = self.strlen_precheck(q, constraints)
        rewrite_type.update(rewrite_set_strlen_precheck)
        # if rewrite_set_strlen_precheck:
        # print("Length precheck", format(q), lencheck_fields)
        rewrite_set_strformat_precheck, formatcheck_fields = self.strformat_precheck(
            q, constraints)
        rewrite_type.update(rewrite_set_strformat_precheck)
        # if rewrite_set_strformat_precheck:
        #     print("String format precheck", format(q), formatcheck_fields)
        rewrite_set_remove_distinct, rewrite_q = self.remove_distinct(
            q, constraints)
        rewrite_type.update(rewrite_set_remove_distinct)
        if rewrite_set_remove_distinct:
            self.queryset.add(format(rewrite_q))
            # print("Remove Distinct", format(rewrite_q))
            q = rewrite_q

        rewrite_set_remove_predicate, rewrite_q = self.remove_predicate_null(
            q.copy(), constraints)
        rewrite_type.update(rewrite_set_remove_predicate)
        if rewrite_set_remove_predicate:
            # print("Remove Predicate", format(rewrite_q))
            q = rewrite_q

        rewrite_set_remove_predicate_numerical, rewrite_q = self.remove_predicate_numerical(
            q.copy(), constraints)
        rewrite_type.update(rewrite_set_remove_predicate_numerical)
        if rewrite_set_remove_predicate_numerical:
            # print("Remove Predicate", format(rewrite_q))
            q = rewrite_q
        return q, rewrite_type
