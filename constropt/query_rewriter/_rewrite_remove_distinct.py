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
                            success &= col in u_in1 or col in u_in2 or col == '$1'
                        break
        else:
            # check that equality is on two unique columns
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
        if 'inner join' in t or 'join' in t:
            # get table 2 and its unique set
            if 'inner join' in t:
                r_in2 = t['inner join']
            else:
                r_in2 = t['join']
            u_in2 = r_in_to_u_in(r_in2, constraints, alias_to_table)
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
            # check fail: u_out is empty set. else, u_out is u_in1.
            if not check_join_conditions(t, u_in1, u_in2, alias_to_table):
                u_in1 = set()
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
            for col in u_in:
                if table_dot in col or dealias_dot in col:
                    rewrite_q = q.copy()
                    rewrite_q['select'] = val
                    return True, rewrite_q
        elif val == '*' and u_in or unalias(alias_to_table, val) in u_in:
            rewrite_q = q.copy()
            rewrite_q['select'] = val
            return True, rewrite_q
    elif isinstance(projections, list):
        for d in projections:
            if unalias(alias_to_table, d['value']) in u_in:
                rewrite_q = q.copy()
                rewrite_q['select'] = projections
                return True, rewrite_q
    return False, None
