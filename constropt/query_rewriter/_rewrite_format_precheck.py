import functools
from .constraint import *


def strformat_precheck(self, q, constraints):
    if 'where' not in q:
        return False, None
    strformat_fields = self.get_constraint_fields(
        constraints, FormatConstraint)
    predicate = q['where']
    has_join = self.check_query_has_join(q)
    if not has_join:
        strformat_fields = list(
            map(lambda x: x.split('.')[1], strformat_fields))
    format_precheck_fields = functools.reduce(lambda acc, item: acc + [item] if self.find_field_in_predicate(
        item, predicate) else acc, strformat_fields, [])
    can_rewrite = len(format_precheck_fields) > 0
    return can_rewrite, format_precheck_fields
