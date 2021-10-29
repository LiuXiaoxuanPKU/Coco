import json
import functools
from constropt.query_rewriter.constraint import LengthConstraint, UniqueConstraint, InclusionConstraint, FormatConstraint
# from constraint import LengthConstraint, UniqueConstraint, InclusionConstraint, FormatConstraint
from mo_sql_parsing import parse, format


def find_constraint(constraints, table, field, constraint_type):
    re = list(filter(lambda x: isinstance(x, constraint_type)
              and x.table == table and x.field == field, constraints))
    return len(list(re)) > 0


def get_constraint_fields(constraints, constraint_type):
    selected_constraints = filter(
        lambda x: isinstance(x, constraint_type), constraints)
    return list(map(lambda x: x.table + "." + x.field, selected_constraints))


def find_field_in_predicate(field, predicate):
    keys = list(predicate.keys())
    assert(len(keys) == 1)
    key = keys[0]
    values = list(predicate[key])

    # case: where 1=1
    if isinstance(values[0], int):
        return False
    if isinstance(values[0], str):
        return field in values
    return functools.reduce(lambda acc, item: acc or find_field_in_predicate(field, item), values, False)


def get_query_tables(q):
    table = q['from']
    return list(functools.reduce(
        lambda acc, item: acc + [item['inner join']] if ('inner join' in item) else acc, table, []))


def check_query_has_join(q):
    return len(get_query_tables(q)) > 0


def check_connect_by_and_equal(predicates):
    '''
    check relations only has and operators, or does not have connect operators, and predicates are equation predicates
    '''
    keys = list(predicates.keys())
    assert(len(keys) == 1)
    key = keys[0]
    # TODO: handle exist
    if isinstance(predicates[key], list) and isinstance(predicates[key][0], str):
        return key == "eq"
    res = True
    if not key == "and":
        return False
    for predicate in predicates[key]:
        res = res and check_connect_by_and_equal(predicate)
    return res


def get_table_predicates(predicates, table):
    '''
    get predicates of the given table
    '''
    keys = list(predicates.keys())
    assert(len(keys) == 1)
    key = keys[0]
    if isinstance(predicates[key][0], str):
        tmp = predicates[key][0].split('.')
        # if the predicate does not contain table name (column = ?)
        if len(tmp) == 1:
            return [predicates]
        # if the predicate contains table name (table.column = ?)
        if len(tmp) == 2 and table == tmp[0]:
            return [predicates]
        assert(len(tmp) <= 2)
        return []

    table_predicates = []
    for predicate in predicates[key]:
        p = get_table_predicates(predicate, table)
        table_predicates += p

    return table_predicates


def add_limit_one(q, constraints):
    if 'limit' in q or 'where' not in q:
        return False, None

    where_clause = q['where']
    keys, values = list(where_clause.keys()), list(where_clause.values())
    has_inner_join = check_query_has_join(q)
    assert(len(keys) == 1)
    key = keys[0]

    def check_predicate_return_one_tuple(key, table, field):
        '''
        check if after applying the predicate, only one record is returned
        key : compare key
        table : table name
        field : column name, should not include table name
        '''
        return key == 'eq' and find_constraint(constraints, table, field, UniqueConstraint)

    # case 1: no join, only has one predicate
    if not has_inner_join and check_predicate_return_one_tuple(key, q['from'], values[0][0]):
        rewrite_q = q.copy()
        rewrite_q['limit'] = 1
        return True, rewrite_q
    # case 2: no join, predicates are connected by 'and'
    elif not has_inner_join and key in ["and"]:
        # as long as all predicates are connected by 'and'
        # and there exists one predicate that returns only one tuple
        predicates = where_clause['and']
        return_one = False
        table = q['from']

        for pred in predicates:
            # TODO: does not handle exits for now
            if 'exists' in pred:
                return False, None
            return_one = return_one or check_predicate_return_one_tuple(
                list(pred.keys())[0], table, list(pred.values())[0][0])
        if return_one:
            rewrite_q = q.copy()
            rewrite_q['limit'] = 1
            return True, rewrite_q
    # case 3: inner join, each relation returns no more than 1 tuple
    elif has_inner_join:
        join_tables = get_query_tables(q)
        predicates = q['where']

        if not check_connect_by_and_equal(predicates):
            return False, None

        # for each join table, only return one tuple from that table
        for table in join_tables:
            # get predicates on that relation
            table_predicates = get_table_predicates(predicates, table)
            return_one = False
            for predicate in table_predicates:
                keys = list(predicate.keys())
                assert(len(keys) == 1)
                cmp_key, field = keys[0], predicate[keys[0]][0]
                # field should contain table name
                tokens = field.split('.')
                if len(tokens) == 1:
                    field = tokens[0]
                else:
                    field = tokens[1]
                return_one = check_predicate_return_one_tuple(
                    cmp_key, table, field)
                if return_one:
                    break
            if not return_one:
                return False, None
        rewrite_q = q.copy()
        rewrite_q['limit'] = 1
        return True, rewrite_q

    return False, None

# =================================================================================================================
# helper functions for remove distinct

def check_join_conditions(table, u_in1, u_in2, alias_to_table):
    '''Check whether there is a join condition that implies joining on two unique columns.'''
    success = True
    # potentially fail if there is a join condition
    if 'on' in table:
        # assume uniqueness is only maintained on equality join condition
        if 'eq' not in table['on']:
            success = False
            # check for potential equality conditions within the and
            if 'and' in table['on']:
                for d in table['on']['and']:
                    if 'eq' in d:
                        # check that equality is on two unique columns
                        success = True
                        for col in d['eq']:
                            col = unalias(alias_to_table, col)
                            # TODO: temporary handler for constants
                            success &= {col} in u_in1 or {col} in u_in2 or col[0] == '$'
                        break
        else:
            # check that equality is on two unique columns
            for col in table['on']['eq']:
                col = unalias(alias_to_table, col)
                success &= {col} in u_in1 or {col} in u_in2 or col[0] == '$'
    return success


def unalias(alias_to_table, col):
    '''Uses alias_to_table to translate a potential aliased column col 
    into its equivalent internal representation.'''
    if '.' in col:
        table, field = col.split('.')
        if table in alias_to_table:
            col = alias_to_table[table] + '.' + field
    return col


def r_in_to_u_in(r_in, constraints, alias_to_table):
    '''Gets the set of unique columns U_in for the input relation R_in.
    R_in possible formats:
    'users'
    {'value': 'users', 'name': 'u'}
    {'value': {'select': ..., 'from': ...}}
    {'value': {'select': ..., 'from': ...}, 'name': 'u'}
    '''
    if isinstance(r_in, dict):
        # case for handing nested query
        if isinstance(r_in['value'], dict):
            # rewrite the nested query
            rewritten, _ = rewrite_single_query(r_in['value'], constraints)
            r_in['value'] = rewritten
            # u_out from the nested query will be u_in
            u_out = query_to_u_out(rewritten, constraints, {})
            # handle case with nested query + AS: the alias becomes the internal name
            # and as such is not included in the alias_to_table mapping but rather u_in
            u_in = u_out
            if 'name' in r_in:
                u_in = set()
                alias = r_in['name']
                for col in u_out:
                    if '.' not in col:
                        u_in.add(alias + '.' + col)
                    u_in.add(col)
            return u_in
        # case for handling AS
        elif 'name' in r_in:
            alias_to_table[r_in['name']] = r_in = r_in['value']
    u_in = set()
    for constraint in constraints:
        if constraint.table == r_in and isinstance(constraint, UniqueConstraint):
            unique_lst = [constraint.field] + constraint.scope
            unique_set = set(unique_lst + [constraint.table + '.' + col for col in unique_lst])
            u_in.add(unique_set)
    return u_in

# SELECT customerName, customercity, customermail, salestotal
# FROM onlinecustomers AS oc
#    INNER JOIN
#    orders AS o
#    ON oc.customerid = o.customerid
#    INNER JOIN
#    sales AS s
#    ON o.orderId = s.orderId
#    WHERE s.id = 1

# where (a = 1 or b = 9) and (c = 8 or d = 7)
def u_in_after_filter(q, u_in, alias_to_table):
    # check if q has where clause
    if not 'where' in q:
        return
    # check only AND in where clause
    where = q["where"]
    if not ("and" in where or "eq" in where):
        return
    if "and" in where:
        where_conditions = where["and"]
        for cond in where_conditions:
            # only take care field = constant
            if "eq" in cond and "$" == cond["eq"][1][0]:
                cond_column = cond["eq"][0]
                # remove cond_column from each subset in u_in
                for subset in u_in:
                    # id, table_name.id, t.id -> remove them all
                    cond_column = unalias(cond_column) # table_name.id, id
                    subset.discard(cond_column)
                    subset.discard(cond_column.split(".")[-1])

    # only one condition in where
    elif "eq" in where and "$" == where["eq"][1][0]:
        cond_column = where["eq"][0]
        # remove cond_column from each subset in u_in
        for subset in u_in:
            # id, table_name.id, t.id -> remove them all
            cond_column = unalias(cond_column)  # table_name.id, id
            subset.discard(cond_column)
            subset.discard(cond_column.split(".")[-1])


# select id from a where project_id = 1
# [id, project_id]

def query_to_u_out(q, constraints, alias_to_table):
    '''Gets the set of unique columns U_out after going through the entire query, save for projections.'''
    tables = q['from']
    # no joins case
    if not isinstance(tables, list):
        tables = [tables]
    r_in1 = tables[0]
    u_in1 = r_in_to_u_in(r_in1, constraints, alias_to_table)
    # single table case filter
    u_in_after_filter(q, u_in1, alias_to_table)
    for t in tables[1:]:
        if 'inner join' in t or 'join' in t:
            # get table 2 and its unique set
            if 'inner join' in t:
                r_in2 = t['inner join']
            else:
                r_in2 = t['join']
            u_in2 = r_in_to_u_in(r_in2, constraints, alias_to_table)
            u_in_after_filter(q, u_in2, alias_to_table)
            # check fail: u_out is empty set. else, u_out is union of u_in1 and u_in2.
            if check_join_conditions(t, u_in1, u_in2, alias_to_table):
                u_in1 = u_in1.union(u_in2)
            else:
                u_in1 = set()
        elif 'left outer join' in t or 'left join' in t:
            # get table 2 and its unique set
            if 'left outer join' in t:
                r_in2 = t['left outer join']
            else:
                r_in2 = t['left join']
            u_in2 = r_in_to_u_in(r_in2, constraints, alias_to_table)
            u_in_after_filter(q, u_in2, alias_to_table)
            # check fail: u_out is empty set. else, u_out is u_in1.
            if not check_join_conditions(t, u_in1, u_in2, alias_to_table):
                u_in1 = set()
        # deal with filter after join
        u_in_after_filter(q, u_in1, alias_to_table)
    return u_in1


def remove_distinct(q, constraints):
    def contain_distinct(q):
        """return True if sql contain 'distinct' key word."""
        # 'select': {'value': 1, 'name': 'one'}
        if not isinstance(q['select'], dict) or \
                isinstance(q['select']['value'], int) or \
                'distinct' not in q['select']['value']:
            return False
        return True

    if not contain_distinct(q):
        return False, None

    alias_to_table = {}
    u_out = query_to_u_out(q, constraints, alias_to_table)
    return remove_distinct_projection(q, u_out, alias_to_table)


def remove_distinct_projection(q, u_in, alias_to_table):
    '''Only the "Project" step of the remove distinct algorithm.
    Projections possible formats:
    {'value': 'name'}
    {'value': 'users.name'}
    {'value': 'u.name'}
    {'value': '*'}
    {'value': 'users.*'}
    {'value': 'u.*'}
    {'value': ['users.name', 'users.id']}
    [{'value': 'users.name'}, {'value': 'projects.id'}]
    '''
    projections = q['select']['value']['distinct']
    if isinstance(projections, dict):
        val = projections['value']
        if isinstance(val, list):
            for col in val:
                if unalias(alias_to_table, col) in u_in:
                    rewrite_q = q.copy()
                    rewrite_q['select'] = val
                    return True, rewrite_q
        elif '.*' in val:
            table_dot = dealias_dot = val[0:-1]
            if val[0:-2] in alias_to_table:
                dealias_dot = alias_to_table[val[0:-2]] + '.'
            # for col in u_in:
            for subset in u_in:
                if table_dot in subset[0] or dealias_dot in subset[0]:
                # if table_dot in col or dealias_dot in col:
                    rewrite_q = q.copy()
                    rewrite_q['select'] = val
                    return True, rewrite_q
        elif val == '*' and u_in or unalias(alias_to_table, val) in u_in:
            rewrite_q = q.copy()
            rewrite_q['select'] = val
            return True, rewrite_q
        # {'value': 'name'} case: check if {name} in u_in
    elif isinstance(projections, list):
    # [{'value': 'users.name'}, {'value': 'projects.id'}]
        proj_set = set([unalias(alias_to_table, d['value']) for d in projections])
        for subset in u_in:
            if subset <= proj_set:
                rewrite_q = q.copy()
                rewrite_q['select'] = projections
                return True, rewrite_q
    return False, None

# end remove distinct
# =================================================================================================================


def str2int(q, constraints):
    if 'where' not in q:
        return False, None
    enum_fields = get_constraint_fields(constraints, InclusionConstraint)
    predicate = q['where']
    # if q does not have join, field does not need prefix (table name)
    has_join = check_query_has_join(q)
    if not has_join:
        enum_fields = list(map(lambda x: x.split('.')[1], enum_fields))
    str2_int_fields = functools.reduce(lambda acc, item: acc + [item] if find_field_in_predicate(
        item, predicate) else acc, enum_fields, [])
    can_rewrite = len(str2_int_fields) > 0
    return can_rewrite, str2_int_fields


def strlen_precheck(q, constraints):
    if 'where' not in q:
        return False, None
    strlen_fields = get_constraint_fields(constraints, LengthConstraint)
    predicate = q['where']
    has_join = check_query_has_join(q)
    if not has_join:
        strlen_fields = list(map(lambda x: x.split('.')[1], strlen_fields))
    len_precheck_fields = functools.reduce(lambda acc, item: acc + [item] if find_field_in_predicate(
        item, predicate) else acc, strlen_fields, [])
    can_rewrite = len(len_precheck_fields) > 0
    return can_rewrite, len_precheck_fields


def strformat_precheck(q, constraints):
    if 'where' not in q:
        return False, None
    strformat_fields = get_constraint_fields(constraints, FormatConstraint)
    predicate = q['where']
    has_join = check_query_has_join(q)
    if not has_join:
        strformat_fields = list(
            map(lambda x: x.split('.')[1], strformat_fields))
    format_precheck_fields = functools.reduce(lambda acc, item: acc + [item] if find_field_in_predicate(
        item, predicate) else acc, strformat_fields, [])
    can_rewrite = len(format_precheck_fields) > 0
    return can_rewrite, format_precheck_fields


def rewrite_single_query(q, constraints):
    can_rewrite = False
    can_add_limit_one, rewrite_q = add_limit_one(q, constraints)
    if can_add_limit_one:
        print("Add limit 1 ", format(rewrite_q))
        q = rewrite_q
    can_str2int, rewrite_fields = str2int(q, constraints)
    if can_str2int:
        print("String to Int", format(q), rewrite_fields)
    can_strlen_precheck, lencheck_fields = strlen_precheck(q, constraints)
    if can_strlen_precheck:
        print("Length precheck", format(q), lencheck_fields)
    can_strformat_precheck, formatcheck_fields = strformat_precheck(
        q, constraints)
    if can_strformat_precheck:
        print("String format precheck", format(q), formatcheck_fields)
    can_remove_distinct, rewrite_q = remove_distinct(q, constraints)
    if can_remove_distinct:
        print("Remove Distinct", format(rewrite_q))
        q = rewrite_q
    can_rewrite = can_add_limit_one or can_str2int or can_strlen_precheck or can_strformat_precheck or can_remove_distinct
    return q, can_rewrite

# handle nested query cases


def rewrite_query():
    pass


if __name__ == "__main__":
    filename = "constropt/query_rewriter/query.sql"
    constraints = [UniqueConstraint("users", "name"), UniqueConstraint(
        "projects", "id"), UniqueConstraint("users", "project"),
        InclusionConstraint("users", "gender", ['F', 'M'])]
    with open(filename, 'r') as f:
        sqls = f.readlines()
    for sql in sqls:
        print(sql.strip())
        sql_obj = parse(sql.strip())
        print(json.dumps(sql_obj, indent=4))
        # rewrite_single_query(sql_obj, constraints)
    # TODO : EXISTS, ANY
