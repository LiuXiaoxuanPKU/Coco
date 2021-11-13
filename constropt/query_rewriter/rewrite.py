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

    if not has_inner_join:
        # handle nested single query
        table = q['from']
        if isinstance(table, dict) and isinstance(table['value'], dict):
            rewritten, _ = rewrite_single_query(table['value'], constraints)
            table['value'] = rewritten
        # case 1: no join, only has one predicate
        if check_predicate_return_one_tuple(key, table, values[0][0]):
            rewrite_q = q.copy()
            rewrite_q['limit'] = 1
            return True, rewrite_q
        # case 2: no join, predicates are connected by 'and'
        elif key in ["and"]:
            # as long as all predicates are connected by 'and'
            # and there exists one predicate that returns only one tuple
            predicates = where_clause['and']
            return_one = False

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
    else:
        join_tables = get_query_tables(q)
        predicates = q['where']

        if not check_connect_by_and_equal(predicates):
            return False, None

        # for each join table, only return one tuple from that table
        for table in join_tables:
            # rewrite nested query
            if isinstance(table, dict) and isinstance(table['value'], dict):
                rewritten, _ = rewrite_single_query(table['value'], constraints)
                table['value'] = rewritten
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

def check_join_conditions(table, u_in1, u_in2, col_to_table_dot_col):
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
                            col = unalias(col_to_table_dot_col, col)
                            # handler for constants
                            success &= check_single_column_in_u_in(u_in1, col) or check_single_column_in_u_in(u_in2, col) or isinstance(col, str) and col[0] == '$'
                        break
        else:
            # check that equality is on two unique columns
            for col in table['on']['eq']:
                col = unalias(col_to_table_dot_col, col)
                success &= check_single_column_in_u_in(u_in1, col) or check_single_column_in_u_in(u_in2, col) or isinstance(col, str) and col[0] == '$'
    return success


def unalias(col_to_table_dot_col, col):
    '''Uses col_to_table_dot_col to translate a potential aliased column col 
    into its equivalent internal representation in the table.col form.'''
    if col in col_to_table_dot_col:
        return col_to_table_dot_col[col]
    return col


def r_in_to_u_in(r_in, constraints, col_to_table_dot_col):
    '''Gets the set of unique columns U_in for the input relation R_in.
    R_in possible formats:
    'users'
    {'value': 'users', 'name': 'u'}
    {'value': {'select': ..., 'from': ...}}
    {'value': {'select': ..., 'from': ...}, 'name': 'u'}
    '''
    alias = None
    if isinstance(r_in, dict):
        # case for handing nested query
        if isinstance(r_in['value'], dict):
            # rewrite the nested query
            rewritten, _ = rewrite_single_query(r_in['value'], constraints)
            r_in['value'] = rewritten
            # u_out from the nested query will be u_in
            u_out = query_to_u_out(rewritten, constraints, {})
            # handle case with nested query + AS: the alias becomes the internal name
            # and as such is not included in the col_to_table_dot_col mapping but rather u_in
            u_in = u_out
            if 'name' in r_in:
                u_in = set()
                alias = r_in['name']
                for col in u_out:
                    # print("col is", col)
                    # if '.' not in col:
                    #     u_in.add(alias + '.' + col)
                    u_in.add(col)
            return u_in
        # case for handling AS
        elif 'name' in r_in:
            r_in, alias = r_in['value'], r_in['name']
    u_in = set()
    for constraint in constraints:
        if constraint.table == r_in and isinstance(constraint, UniqueConstraint):
            unique_lst = [constraint.field] + constraint.scope
            table_unique_lst = []
            if alias:
                col_to_table_dot_col[alias + '.*'] = r_in + '.*'
            for col in unique_lst:
                col_to_table_dot_col[col] = r_in + '.' + col
                if alias:
                    col_to_table_dot_col[alias + '.' + col] = r_in + '.' + col
                table_unique_lst.append(col_to_table_dot_col[col])
            u_in.add(frozenset(table_unique_lst))
    return u_in


def u_in_after_filter(q, u_in, col_to_table_dot_col):
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
                cond_column = unalias(col_to_table_dot_col, cond["eq"][0]) # table_name.id, id
                # remove cond_column from each subset in u_in
                for subset in u_in:
                    # id, table_name.id, t.id -> remove them all
                    subset = set(subset)
                    subset.discard(cond_column)
                    subset.discard(cond_column.split(".")[-1])
                    subset = frozenset(subset)
    # only one condition in where
    elif "eq" in where and isinstance(where["eq"][1], str) and "$" == where["eq"][1][0]:
        cond_column = unalias(col_to_table_dot_col, where["eq"][0]) # table_name.id, id
        # remove cond_column from each subset in u_in
        for subset in u_in:
            # id, table_name.id, t.id -> remove them all
            subset = set(subset)
            subset.discard(cond_column)
            subset.discard(cond_column.split(".")[-1])
            subset = frozenset(subset)


def query_to_u_out(q, constraints, col_to_table_dot_col):
    '''Gets the set of unique columns U_out after going through the entire query, save for projections.'''
    tables = q['from']
    # no joins case
    if not isinstance(tables, list):
        tables = [tables]
    r_in1 = tables[0]
    u_in1 = r_in_to_u_in(r_in1, constraints, col_to_table_dot_col)
    # single table case filter
    u_in_after_filter(q, u_in1, col_to_table_dot_col)
    for t in tables[1:]:
        if 'inner join' in t or 'join' in t:
            # get table 2 and its unique set
            if 'inner join' in t:
                r_in2 = t['inner join']
            else:
                r_in2 = t['join']
            u_in2 = r_in_to_u_in(r_in2, constraints, col_to_table_dot_col)
            u_in_after_filter(q, u_in2, col_to_table_dot_col)
            # check fail: u_out is empty set. else, u_out is union of u_in1 and u_in2.
            if check_join_conditions(t, u_in1, u_in2, col_to_table_dot_col):
                u_in1 = u_in1.union(u_in2)
            else:
                u_in1 = set()
        elif 'left outer join' in t or 'left join' in t:
            # get table 2 and its unique set
            if 'left outer join' in t:
                r_in2 = t['left outer join']
            else:
                r_in2 = t['left join']
            u_in2 = r_in_to_u_in(r_in2, constraints, col_to_table_dot_col)
            u_in_after_filter(q, u_in2, col_to_table_dot_col)
            # check fail: u_out is empty set. else, u_out is u_in1.
            if not check_join_conditions(t, u_in1, u_in2, col_to_table_dot_col):
                u_in1 = set()
        # deal with filter after join
        u_in_after_filter(q, u_in1, col_to_table_dot_col)
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
    col_to_table_dot_col = {}
    u_out = query_to_u_out(q, constraints, col_to_table_dot_col)
    # print("u_out", u_out)
    return remove_distinct_projection(q, u_out, col_to_table_dot_col)

def check_single_column_in_u_in(u_in, val) -> bool:
    val = val.split(".")[-1]
    n = len(val)
    for subset in u_in:
        check_valid = True
        for value in subset:
            check_valid = check_valid and value[-n:] == val
        if check_valid: return True
    return False


def remove_distinct_projection(q, u_in, col_to_table_dot_col):
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
            proj_set = set()
            for col in val:
                proj_set.add(unalias(col_to_table_dot_col, col))
            for s in u_in:
                if s <= proj_set:
                    rewrite_q = q.copy()
                    rewrite_q['select'] = val
                    return True, rewrite_q
        elif '.*' in val:
            table_dot = unalias(col_to_table_dot_col, val)[:-1]
            for subset in u_in:
                if table_dot in ([s.split(".")[0] + "." for s in list(subset)]):
                    rewrite_q = q.copy()
                    rewrite_q['select'] = val
                    return True, rewrite_q
        elif val == '*' and u_in or check_single_column_in_u_in(u_in, unalias(col_to_table_dot_col, val)):
            rewrite_q = q.copy()
            rewrite_q['select'] = val
            return True, rewrite_q
        # {'value': 'name'} case: check if {name} in u_in
    elif isinstance(projections, list):
    # [{'value': 'users.name'}, {'value': 'projects.id'}]
        proj_set = set([unalias(col_to_table_dot_col, d['value']) for d in projections])
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
