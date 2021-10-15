from constraint import LengthConstraint
from constraint import UniqueConstraint, InclusionConstraint, FormatConstraint
from mo_sql_parsing import parse, format
import functools
import json


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

    if isinstance(values[0], str):
        return field in values
    return functools.reduce(lambda acc, item: acc or find_field_in_predicate(field, item), values, False)


def check_query_has_join(q):
    table = q['from']
    return functools.reduce(
        lambda acc, item: acc or ('inner join' in item) or ('left outer join' in item), table, False)


def add_limit_one(q, constraints):
    if 'limit' in q:
        return False, None
    where_clause = q['where']
    keys, values = list(where_clause.keys()), list(where_clause.values())
    has_join = check_query_has_join(q)
    assert(len(keys) == 1)
    key = keys[0]

    def check_predicate_return_one_tuple(key, table, field):
        return key == 'eq' and find_constraint(constraints, table, field, UniqueConstraint)

    # case 1: no join, only has one predicate
    if not has_join and check_predicate_return_one_tuple(key, q['from'], values[0][0]):
        rewrite_q = q.copy()
        rewrite_q['limit'] = 1
        return True, rewrite_q
    # case 2: no join, predicates are connected by 'and'
    elif not has_join and key in ["and"]:
        # as long as all predicates are connected by 'and'
        # and there exists one predicate that returns only one tuple
        predicates = where_clause['and']
        return_one = False
        table = q['from']
        for pred in predicates:
            return_one = return_one or check_predicate_return_one_tuple(
                list(pred.keys())[0], table, list(pred.values())[0][0])
        if return_one:
            rewrite_q = q.copy()
            rewrite_q['limit'] = 1
            return True, rewrite_q
    # case 3: inner join, each relation returns no more than 1 tuple
    elif has_join:
        pass

    return False, None

#=================================================================================================================
# helper functions for remove distinct

def check_join_conditions(table, u_in1, u_in2, alias_to_table):
    '''Check whether there is a join condition that implies joining on two unique columns.'''
    success = True
    #potentially fail if there is a join condition
    if 'on' in table:
        #assume uniqueness is only maintained on equality join condition
        if 'eq' not in table['on']:
            success = False
            #check for potential equality conditions within the and
            if 'and' in table['on']:
                for d in table['on']['and']:
                    if 'eq' in d:
                        #check that equality is on two unique columns
                        success = True
                        for col in d['eq']:
                            col = unalias(alias_to_table, col)
                            success &= col in u_in1 or col in u_in2
                        break
        else:
            #check that equality is on two unique columns
            for col in table['on']['eq']:
                col = unalias(alias_to_table, col)
                success &= col in u_in1 or col in u_in2
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
    '''
    if isinstance(r_in, dict):
        # case for handling AS 
        if 'name' in r_in:
            alias_to_table[r_in['name']] = r_in = r_in['value']
        # case for handing nested query
        else:
            #rewrite the nested query
            #rewritten = rewrite(r_in['value'], constraints)
            #r_in['value'] = rewritten
            rewritten = r_in['value']
            # u_out from the nested query will be u_in
            return query_to_u_out(rewritten, constraints, {})
    u_in = set()
    for constraint in constraints:
        if constraint.table == r_in and isinstance(constraint, UniqueConstraint):
            u_in.add(constraint.table + '.' + constraint.field)
            u_in.add(constraint.field)
    return u_in

def query_to_u_out(q, constraints, alias_to_table):
    '''Gets the set of unique columns U_out after going through the entire query, save for projections.'''
    tables = q['from']
    # no joins case
    if not isinstance(tables, list):
        tables = [tables]
    r_in1 = tables[0]
    u_in1 = r_in_to_u_in(r_in1, constraints, alias_to_table)
    for t in tables[1:]:
        if 'inner join' in t:
            #get table 2 and its unique set
            r_in2 = t['inner join']
            u_in2 = r_in_to_u_in(r_in2, constraints, alias_to_table)
            #check fail: u_out is empty set. else, u_out is union of u_in1 and u_in2.
            if check_join_conditions(t, u_in1, u_in2, alias_to_table):
                u_in1 = u_in1.union(u_in2)
            else:
                u_in1 = set()
        elif 'left outer join' in t:
            #get table 2 and its unique set
            r_in2 = t['left outer join']
            u_in2 = r_in_to_u_in(r_in2, constraints, alias_to_table)
            #check fail: u_out is empty set. else, u_out is u_in1.
            if not check_join_conditions(t, u_in1, u_in2, alias_to_table):
                u_in1 = set()
    return u_in1

def remove_distinct(q, constraints):
    def contain_distinct(q):
        """return True if sql contain 'distinct' key word."""
        if not isinstance(q['select'], dict) or 'distinct' not in q['select']['value']:
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
    {'value': ['users.name', 'users.id']}
    [{'value': 'users.name'}, {'value': 'projects.id'}]
    '''
    projections = q['select']['value']['distinct']
    if isinstance(projections, dict):
        if isinstance(projections['value'], list):
            for col in projections['value']:
                if unalias(alias_to_table, col) in u_in:
                    rewrite_q = q.copy()
                    rewrite_q['select'] = projections['value']
                    return True, rewrite_q
        elif projections['value'] == '*' and u_in or unalias(alias_to_table, projections['value']) in u_in:
            rewrite_q = q.copy()
            rewrite_q['select'] = projections['value']
            return True, rewrite_q
    elif isinstance(projections, list):
        for d in projections:
            if unalias(alias_to_table, d['value']) in u_in:
                rewrite_q = q.copy()
                rewrite_q['select'] = projections
                return True, rewrite_q
    return False, None

# end remove distinct
#=================================================================================================================

def str2int(q, constraints):
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


def rewrite(q, constraints):
    can_add_limit_one, rewrite_q = add_limit_one(q, constraints)
    if can_add_limit_one:
        print("Add limit 1 ", format(rewrite_q))
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


if __name__ == "__main__":
    filename = "query.sql"
    constraints = [UniqueConstraint("users", "name"), UniqueConstraint("projects", "id"), UniqueConstraint("users", "project")]
    with open(filename, 'r') as f:
        sqls = f.readlines()
    for sql in sqls:
        print(sql.strip())
        sql_obj = parse(sql.strip())
        print(json.dumps(sql_obj, indent=4))
        rewrite(sql_obj, constraints)
