from constraint import UniqueConstraint
from mo_sql_parsing import parse, format
import json


def find_constraint(constraints, table, field, constraint_type):
    re = list(filter(lambda x: isinstance(x, constraint_type)
              and x.table == table and x.field == field, constraints))
    return len(list(re)) > 0


def add_limit_one(q, constraints):
    if 'limit' in q:
        return False, None
    where_clause = q['where']
    keys, values = list(where_clause.keys()), list(where_clause.values())
    table = q['from']
    assert(len(keys) == 1)
    key = keys[0]

    def check_predicate_return_one_tuple(key, table, field):
        return key == 'eq' and find_constraint(constraints, table, field, UniqueConstraint)

    if check_predicate_return_one_tuple(key, table, values[0][0]):
        rewrite_q = q.copy()
        rewrite_q['limit'] = 1
        return True, rewrite_q
    elif key in ["and"]:
        # as long as all predicates are connected by 'and'
        # and there exists one predicate that returns only one tuple
        predicates = where_clause['and']
        return_one = False
        for pred in predicates:
            return_one = return_one or check_predicate_return_one_tuple(
                list(pred.keys())[0], table, list(pred.values())[0][0])
        if return_one:
            rewrite_q = q.copy()
            rewrite_q['limit'] = 1
            return True, rewrite_q
    return False, None


def remove_distinct(q, constraints):
    pass


def str2int(q, constraints):
    pass


def strlen_precheck(q, constraints):
    pass


def strformat_precheck(q, constraints):
    pass


def rewrite(q, constraints):
    can_add_limit_one, rewrite_q = add_limit_one(q, constraints)
    if can_add_limit_one:
        print("Add limit 1 ", format(rewrite_q))


if __name__ == "__main__":
    filename = "query.sql"
    constraints = [UniqueConstraint("users", "name")]
    with open(filename, 'r') as f:
        sqls = f.readlines()
    for sql in sqls:
        print(sql.strip())
        sql_obj = parse(sql.strip())
        rewrite(sql_obj, constraints)
