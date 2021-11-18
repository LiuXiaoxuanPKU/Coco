from .constraint import *
import functools


def strlen_precheck(self, q, constraints):
    if 'where' not in q:
        return False, None
    strlen_fields = self.get_constraint_fields(constraints, LengthConstraint)
    predicate = q['where']
    has_join = self.check_query_has_join(q)
    if not has_join:
        strlen_fields = list(map(lambda x: x.split('.')[1], strlen_fields))
    len_precheck_fields = functools.reduce(lambda acc, item: acc + [item] if self.find_field_in_predicate(
        item, predicate) else acc, strlen_fields, [])
    can_rewrite = len(len_precheck_fields) > 0
    return can_rewrite, len_precheck_fields
