import json
import functools
from enum import Enum
from typing import ValuesView
from constropt.query_rewriter.constraint import LengthConstraint, NumericalConstraint, PresenceConstraint, UniqueConstraint, InclusionConstraint, FormatConstraint
# from constraint import LengthConstraint, UniqueConstraint, InclusionConstraint, FormatConstraint
from mo_sql_parsing import parse, format
import z3


class RewriteType(Enum):
    ADD_LIMIT_ONE = 1
    REMOVE_DISTINCT = 2
    LENGTH_PRECHECK = 3
    FORMAT_PRECHECK = 4
    REMOVE_PREDICATE = 5
    STRING_TO_INT = 6


def find_constraint(constraints, table, field, constraint_type):
    # field name can be xx.xx or xx
    re = list(filter(lambda x: isinstance(x, constraint_type)
              and x.table == table and x.field == field
                     or (isinstance(field, str) and x.field == field.split(".")[-1]), constraints))
    return len(list(re)) > 0


def get_unqiue_constraints_fields(constraints):
    unique_constraints = list(
        filter(lambda x: isinstance(x, UniqueConstraint), constraints))

    def add_tablename_to_field(table, fields):
        return list(map(lambda x: "%s.%s" % (table, x), fields))
    fields = list(functools.reduce(lambda acc, x: acc + [add_tablename_to_field(x.table, [x.field] + x.scope)],
                                   unique_constraints, []))
    return fields


def get_constraint_fields(constraints, constraint_type):
    '''
    return the full name of constraint, field name is in the format of xx.xx
    '''
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


def get_join_tables(q):
    table = q['from']
    join_tables = list(functools.reduce(
        lambda acc, item: acc + [item['inner join']] if ('inner join' in item) else acc, table, []))
    return join_tables


def get_query_tables(q):
    join_tables = get_join_tables(q)
    table = q['from']
    org_table = [t for t in table if isinstance(t, str)]
    return join_tables + org_table


def check_query_has_join(q):
    return len(get_join_tables(q)) > 0


def check_connect_by_and_equal(predicates):
    '''
    check relations only has and operators, or does not have connect operators, and predicates are equation predicates
    '''
    keys = list(predicates.keys())
    assert(len(keys) == 1)
    key = keys[0]
    # TODO: handle exist
    if isinstance(predicates[key], list) and isinstance(predicates[key][0], str):
        # key = in, predicates[key] = ['users.type', '$1'],
        if key == "eq" or (key == "in" and isinstance(predicates[key][1], str)):
            return True, [predicates[key][0]]
    res = True
    if not key == "and":
        return False, None
    used_fields = []
    for predicate in predicates[key]:
        ok, fields = check_connect_by_and_equal(predicate)
        if ok:
            used_fields += fields
        res = res and ok
        if not res:
            return False, None
    return res, used_fields


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

    def check_predicate_return_one_tuple(predicates, table):
        '''
        check if after applying the predicate, only one record is returned
        key : compare key
        table : table name
        field : column name, should not include table name
        '''
        connect_by_and_equal, used_fields = check_connect_by_and_equal(
            predicates)
        if not connect_by_and_equal:
            return False
        full_used_fields = []
        for field in used_fields:
            if "." not in field:
                field = "%s.%s" % (table, field)
            full_used_fields.append(field)
        fields_list = get_unqiue_constraints_fields(constraints)
        for fields in fields_list:
            if set(fields).issubset(set(full_used_fields)):
                return True
        return False

    # case 1: no join
    if not has_inner_join and check_predicate_return_one_tuple(where_clause, q['from']):
        rewrite_q = q.copy()
        rewrite_q['limit'] = 1
        return True, rewrite_q
    elif has_inner_join:
        join_tables = get_query_tables(q)
        predicates = q['where']
        ok, _ = check_connect_by_and_equal(predicates)
        if not ok:
            return False, None

        join_predicates = [ele for ele in q['from'] if 'inner join' in ele]
        join_predicate = [ele for ele in join_predicates if 'on' in ele][0]
        join_predicate = join_predicate['on']

        def check_join_predicate(join_predicate):
            # only handle equal join
            keys = list(join_predicate.keys())
            assert(len(keys) == 1)
            key = keys[0]
            if key != 'eq':
                return False
            # equal join on unique columns
            join_columns = join_predicate[key]
            fields_list = get_unqiue_constraints_fields(constraints)
            for col in join_columns:
                col_unique = False
                # id column is unique by itself
                if col.split('.')[-1] == "id":
                    col_unique = True
                # uniqueness indicated by the unique constraint
                for fields in fields_list:
                    if len(fields) == 1 and fields[0] == col:
                        col_unique = True
                if not col_unique:
                    return False
            return True

        # case 2: inner join, join on unique columns
        # any of the relation returns no more than 1 tuple and join on unique columns
        if check_join_predicate(join_predicate):
            # for each join table, only return one tuple from that table
            can_rewrite = False
            for table in join_tables:
                # get predicates on that relation
                table_predicates = get_table_predicates(predicates, table)
                for predicate in table_predicates:
                    return_one = check_predicate_return_one_tuple(
                        predicate, table)
                    can_rewrite = can_rewrite or return_one
            if not can_rewrite:
                return False, None
            rewrite_q = q.copy()
            rewrite_q['limit'] = 1
            return True, rewrite_q
        # case 3: inner join, join on any columns
        # each of the relation returns no more than 1 tuple
        else:
            for table in join_tables:
                # get predicates on that relation
                table_predicates = get_table_predicates(predicates, table)
                for predicate in table_predicates:
                    return_one = check_predicate_return_one_tuple(
                        predicate, table)
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

def valid_filter_condition(cond) -> bool:
    """
    Take format from condition["eq"] or condition["in"].
    Return True if condition contains only one constant. Example shown in the following:
    "user.status = $3"  --> ["user.status", "$3"]
    "user.id = 6"  -->  ["user.id", 6]
    "users.type IN ($1, $2)"
    "1 = 1" --> [1, 1]
    """
    if isinstance(cond[1], str):
        return cond[1][0] == "$"
    elif isinstance(cond[1], int):
        return isinstance(cond[0], str)
    elif isinstance(cond[1], list):
        return len(cond[1]) == 1
    return False


def u_in_after_filter(q, u_in, col_to_table_dot_col):
    """
    Set u_in based on filter condition.
    If after filter, there's only one row in table, add every column in table to unique constraint.
    If u_in is {{A, B, C}, {D}} before filter, condition is A = 3, then after filter u_in is {{B, C}, {D}}
    """
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
            # TODO: constant can take format "user.status = $3"; "user.id = 6"; "user.type IN ($1)"
            if "eq" in cond and valid_filter_condition(cond['eq']):
                cond_column = unalias(col_to_table_dot_col, cond["eq"][0]) # table_name.id, id
                # remove cond_column from each subset in u_in
                subset_after_change = set()
                for subset in u_in:
                    # id, table_name.id, t.id -> remove them all
                    subset = set(subset)
                    subset.discard(cond_column)
                    subset.discard(cond_column.split(".")[-1])
                    subset_after_change.add(frozenset(subset))
                u_in.union(subset_after_change)
    # only one condition in where
    elif "eq" in where and valid_filter_condition(where["eq"]):
        cond_column = unalias(col_to_table_dot_col, where["eq"][0]) # table_name.id, id
        # remove cond_column from each subset in u_in
        subset_after_change = set()
        for subset in u_in:
            # id, table_name.id, t.id -> remove them all
            subset = set(subset)
            subset.discard(cond_column)
            subset.discard(cond_column.split(".")[-1])
            subset_after_change.add(frozenset(subset))
        u_in.union(subset_after_change)


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
    no_name_enum_fields = []
    if not has_join:
        no_name_enum_fields = list(map(lambda x: x.split('.')[1], enum_fields))
    no_name_enum_fields += enum_fields
    str2_int_fields = functools.reduce(lambda acc, item: acc + [item] if find_field_in_predicate(
        item, predicate) else acc, no_name_enum_fields, [])
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

# =================================================================================================================
# helper functions for remove predicate null


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


def remove_preciate_null(q, constraints):
    if 'where' not in q:
        return False, None
    exist_fields, missing_fields = find_exist_missing_fields(q['where'])
    presence_fields = get_constraint_fields(constraints, PresenceConstraint)
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
    return q_rewritten is not None, q_rewritten
# =================================================================================================================
# end remove predicate null


# =================================================================================================================
# helper functions for remove predicate numerical
def remove_predicate_numerical(q, constraints):
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
        s = z3.Solver()
        if c.min is not None and c.max is not None:
            precondition = z3.And(tmp >= c.min, tmp <= c.max)
        elif c.min is not None:
            precondition = tmp >= c.min
        elif c.max is not None:
            precondition = tmp <= c.max
        # solve(ForAll(x, Implies(constraint, x>2))))
        s.add(z3.ForAll(tmp, z3.Implies(precondition, eval(format(predicate)))))
        predicate[key][0] = field_name
        return s.check() == z3.sat

    def dfs(predicate):
        keys = predicate.keys()
        assert(len(keys) == 1)
        key = list(keys)[0]
        if not (key == "and" or key == "or"):
            # check if the variable is the constraint variable
            c = get_field_constraint(predicate[key][0])
            if c is None:
                return predicate
            if imply(predicate, c):
                return True, True
            else:
                return False, predicate
        new_children = []
        can_rewrite = False
        for child in predicate[key]:
            can_rewrite_child, new_child = dfs(child)
            can_rewrite = can_rewrite or can_rewrite_child
            new_children.append(new_child)
        predicate[key] = new_children
        return can_rewrite_child, predicate 

    can_rewrite, new_predicate = dfs(predicate)
    q['where'] = new_predicate
    return can_rewrite, q

# =================================================================================================================
# end remove predicate numerical


def rewrite_single_query(q, constraints):
    can_add_limit_one, rewrite_q = add_limit_one(q, constraints)
    rewrite_type = []
    if can_add_limit_one:
        print("Add limit 1 ", format(rewrite_q))
        q = rewrite_q
        rewrite_type.append(RewriteType.ADD_LIMIT_ONE)
    can_str2int, rewrite_fields = str2int(q, constraints)
    if can_str2int:
        # print("String to Int", format(q), rewrite_fields)
        rewrite_type.append(RewriteType.STRING_TO_INT)
    can_strlen_precheck, lencheck_fields = strlen_precheck(q, constraints)
    if can_strlen_precheck:
        # print("Length precheck", format(q), lencheck_fields)
        rewrite_type.append(RewriteType.LENGTH_PRECHECK)
    can_strformat_precheck, formatcheck_fields = strformat_precheck(
        q, constraints)
    if can_strformat_precheck:
        print("String format precheck", format(q), formatcheck_fields)
        rewrite_type.append(RewriteType.FORMAT_PRECHECK)
    can_remove_distinct, rewrite_q = remove_distinct(q, constraints)
    if can_remove_distinct:
        print("Remove Distinct", format(rewrite_q))
        q = rewrite_q
        rewrite_type.append(RewriteType.REMOVE_DISTINCT)
    can_remove_predicate, rewrite_q = remove_preciate_null(q, constraints)
    if can_remove_predicate:
        print("Remove Predicate", format(rewrite_q))
        q = rewrite_q
        rewrite_type.append(RewriteType.REMOVE_PREDICATE)
    return q, rewrite_type

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
    q = parse("select * from t where x > -1 and y > 1 or z < 10 or x > -5")
    c = NumericalConstraint('t', 'x', 0, 100)
    remove_predicate_numerical(q, [c])
    print(q['where'])
