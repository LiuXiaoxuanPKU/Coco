import functools
from .constraint import *


def str2int(self, q, constraints):
    rewrite_type_set = self.rewrite_all_subqueries(q['from'], constraints, set())
    if 'where' not in q:
        return False, None
    enum_fields = self.get_constraint_fields(constraints, InclusionConstraint)
    predicate = q['where']
    # if q does not have join, field does not need prefix (table name)
    has_join = self.check_query_has_join(q)
    no_name_enum_fields = []
    if not has_join:
        no_name_enum_fields = list(map(lambda x: x.split('.')[1], enum_fields))
    no_name_enum_fields += enum_fields
    str2_int_fields = functools.reduce(lambda acc, item: acc + [item] if self.find_field_in_predicate(
        item, predicate) else acc, no_name_enum_fields, [])
    if len(str2_int_fields) > 0:
        rewrite_type_set.add(self.RewriteType.STRING_TO_INT)
    return rewrite_type_set, str2_int_fields
