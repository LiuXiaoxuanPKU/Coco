from enum import Enum
import functools


class RewriteType(Enum):
    ADD_LIMIT_ONE = 1
    REMOVE_DISTINCT = 2
    LENGTH_PRECHECK = 3
    FORMAT_PRECHECK = 4
    REMOVE_PREDICATE_NULL = 5
    REMOVE_PREDICATE_NUMERICAL = 6
    STRING_TO_INT = 7


class Rewriter:
    def __init__(self) -> None:
        pass

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
        keys = list(predicate.keys())
        assert(len(keys) == 1)
        key = keys[0]
        values = list(predicate[key])

        # case: where 1=1
        if isinstance(values[0], int):
            return False
        if isinstance(values[0], str):
            return field in values
        return functools.reduce(lambda acc, item: acc or self.find_field_in_predicate(field, item), values, False)

    from ._rewrite_add_limit_one import add_limit_one
    from ._rewrite_remove_distinct import remove_distinct
    from ._rewrite_str2int import str2int
    from ._rewrite_remove_predicate import remove_predicate_numerical, remove_preciate_null
    from ._rewrite_strlen_precheck import strlen_precheck
    from ._rewrite_format_precheck import strformat_precheck

    def rewrite_single_query(self, q, constraints):
        can_add_limit_one, rewrite_q = self.add_limit_one(q, constraints)
        rewrite_type = []
        if can_add_limit_one:
            print("Add limit 1 ", format(rewrite_q))
            q = rewrite_q
            rewrite_type.append(RewriteType.ADD_LIMIT_ONE)
        can_str2int, _ = self.str2int(q, constraints)
        if can_str2int:
            # print("String to Int", format(q), rewrite_fields)
            rewrite_type.append(RewriteType.STRING_TO_INT)
        can_strlen_precheck, _ = self.strlen_precheck(q, constraints)
        if can_strlen_precheck:
            # print("Length precheck", format(q), lencheck_fields)
            rewrite_type.append(RewriteType.LENGTH_PRECHECK)
        can_strformat_precheck, formatcheck_fields = self.strformat_precheck(q, constraints)
        if can_strformat_precheck:
            print("String format precheck", format(q), formatcheck_fields)
            rewrite_type.append(RewriteType.FORMAT_PRECHECK)
        can_remove_distinct, rewrite_q = self.remove_distinct(q, constraints)
        if can_remove_distinct:
            print("Remove Distinct", format(rewrite_q))
            q = rewrite_q
            rewrite_type.append(RewriteType.REMOVE_DISTINCT)
        can_remove_predicate, rewrite_q = self.remove_preciate_null(q, constraints)
        if can_remove_predicate:
            print("Remove Predicate", format(rewrite_q))
            q = rewrite_q
            rewrite_type.append(RewriteType.REMOVE_PREDICATE_NULL)
        return q, rewrite_type