import z3
from mo_sql_parsing import format
from .constraint import *


def find_exist_missing_fields(predicate):
    if not isinstance(predicate, dict):
        return [], []

    key = list(predicate.keys())[0]
    values = predicate[key]
    if key == "missing":
        return [], [values]
    if key == "exists":
        return [values], []

    exist_fields = []
    missing_fields = []
    for value in values:
        cur_exist_fields, cur_missing_fields = find_exist_missing_fields(value)
        exist_fields += cur_exist_fields
        missing_fields += cur_missing_fields
    return exist_fields, missing_fields


def replace_predicate(q, field, value):
    def helper(predicate):
        if not isinstance(predicate, dict):
            return predicate
        key = list(predicate.keys())[0]
        children = predicate[key]
        if (key == "exists" and children == field):
            return value
        elif (key == "missing" and children == field):
            return value
        else:
            rewrite_predicates = []
            for child in children:
                rewrite_predicates.append(helper(child))
            return {key: rewrite_predicates}
    q['where'] = helper(q['where'])
    return q


def remove_preciate_null(self, q, constraints):
    rewrite_type_set = set()
    if 'where' not in q:
        return rewrite_type_set, None
    exist_fields, missing_fields = find_exist_missing_fields(q['where'])
    presence_fields = self.get_constraint_fields(
        constraints, PresenceConstraint)
    q_rewritten = None
    for field in presence_fields:
        field_without_tablename = field.split('.')[-1]
        if field in exist_fields:
            q_rewritten = replace_predicate(q, field, True)
        elif field_without_tablename in exist_fields:
            q_rewritten = replace_predicate(q, field_without_tablename, True)
        if field in missing_fields:
            q_rewritten = replace_predicate(q, field, False)
        elif field_without_tablename in missing_fields:
            q_rewritten = replace_predicate(q, field_without_tablename, False)
    if q_rewritten:
        rewrite_type_set.add(self.RewriteType.REMOVE_PREDICATE_NULL)
    return rewrite_type_set, q_rewritten


def remove_predicate_numerical(self, q, constraints):
    predicate = q['where']

    def get_field_constraint(field):
        c = list(filter(lambda c: isinstance(c, NumericalConstraint)
                        and c.field == field and c.table == q['from'], constraints))
        if len(c) == 1:
            return c[0]
        elif len(c) == 0:
            return None
        else:
            raise "multiple numerical constraints have the same field," + \
                str(c)

    def imply(predicate, c):
        # create variables
        keys = predicate.keys()
        key = list(keys)[0]
        field_name = predicate[key][0]
        tmp = z3.Real('x')
        predicate[key][0] = 'tmp'

        s_true = z3.Solver()
        if c.min is not None and c.max is not None:
            precondition = z3.And(tmp >= c.min, tmp <= c.max)
        elif c.min is not None:
            precondition = tmp >= c.min
        elif c.max is not None:
            precondition = tmp <= c.max
        # solve(ForAll(x, Implies(constraint, x>2))))
        s_true.add(z3.ForAll(tmp, z3.Implies(
            precondition, eval(format(predicate)))))

        s_false = z3.Solver()
        s_false.add(z3.ForAll(tmp, z3.Implies(
            precondition, z3.Not(eval(format(predicate))))))

        predicate[key][0] = field_name
        return s_true.check() == z3.sat, s_false.check() == z3.sat

    def dfs(predicate):
        keys = predicate.keys()
        assert(len(keys) == 1)
        key = list(keys)[0]
        if not (key == "and" or key == "or"):
            # check if the variable is the constraint variable
            c = get_field_constraint(predicate[key][0])
            if c is None:
                return predicate
            imply_true, imply_false = imply(predicate, c)
            if imply_true:
                return True, True
            elif imply_false:
                return True, False
            else:
                return False, predicate
        new_children = []
        can_rewrite = False
        for child in predicate[key]:
            can_rewrite_child, new_child = dfs(child)
            can_rewrite = can_rewrite or can_rewrite_child
            new_children.append(new_child)
        predicate[key] = new_children
        return can_rewrite, predicate

    can_rewrite, new_predicate = dfs(predicate)
    q['where'] = new_predicate
    return can_rewrite, q
