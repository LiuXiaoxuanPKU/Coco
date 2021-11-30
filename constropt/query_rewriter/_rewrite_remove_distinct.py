from .constraint import UniqueConstraint

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


def r_in_to_u_in(self, r_in, constraints, col_to_table_dot_col):
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
            rewritten, _ = self.rewrite_single_query(r_in['value'], constraints)
            r_in['value'] = rewritten
            # u_out from the nested query will be u_in
            u_out = query_to_u_out(self, rewritten, constraints, {})
            # handle case with nested query + AS: map the aliased name to internal name in col_to_table_dot_col
            if 'name' in r_in:
                alias = r_in['name']
                for fset in u_out:
                    for col in fset:
                        alias_dot_col = alias + '.' + col.split('.')[-1]
                        col_to_table_dot_col[alias_dot_col] = col
            return u_out
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
            if "eq" in cond and valid_filter_condition(cond['eq']):
                cond_column = unalias(col_to_table_dot_col, cond["eq"][0]) # table_name.id, id
                # remove cond_column from each subset in u_in
                for subset in u_in:
                    # id, table_name.id, t.id -> remove them all
                    subset = set(subset)
                    subset.discard(cond_column)
                    subset.discard(cond_column.split(".")[-1])
                    subset = frozenset(subset)
    # only one condition in where
    elif "eq" in where and valid_filter_condition(where["eq"]):
        cond_column = unalias(col_to_table_dot_col, where["eq"][0]) # table_name.id, id
        # remove cond_column from each subset in u_in
        for subset in u_in:
            # id, table_name.id, t.id -> remove them all
            subset = set(subset)
            subset.discard(cond_column)
            subset.discard(cond_column.split(".")[-1])
            subset = frozenset(subset)


def query_to_u_out(self, q, constraints, col_to_table_dot_col):
    '''Gets the set of unique columns U_out after going through the entire query, save for projections.'''
    tables = q['from']
    # no joins case
    if not isinstance(tables, list):
        tables = [tables]
    r_in1 = tables[0]
    u_in1 = r_in_to_u_in(self, r_in1, constraints, col_to_table_dot_col)
    # single table case filter
    u_in_after_filter(q, u_in1, col_to_table_dot_col)
    for t in tables[1:]:
        if 'inner join' in t or 'join' in t:
            # get table 2 and its unique set
            if 'inner join' in t:
                r_in2 = t['inner join']
            else:
                r_in2 = t['join']
            u_in2 = r_in_to_u_in(self, r_in2, constraints, col_to_table_dot_col)
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
            u_in2 = r_in_to_u_in(self, r_in2, constraints, col_to_table_dot_col)
            u_in_after_filter(q, u_in2, col_to_table_dot_col)
            # check fail: u_out is empty set. else, u_out is u_in1.
            if not check_join_conditions(t, u_in1, u_in2, col_to_table_dot_col):
                u_in1 = set()
        # deal with filter after join
        u_in_after_filter(q, u_in1, col_to_table_dot_col)
    return u_in1


def remove_distinct(self, q, constraints):
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

    # if add limit 1 in query, we skip remove distinct check
    if 'limit' in q and q['limit'] == 1:
        rewrite_q = q.copy()
        projections = q['select']['value']['distinct']
        if isinstance(projections, dict):
            val = projections['value']
            rewrite_q['select'] = val
        elif isinstance(projections, list):
            rewrite_q['select'] = projections
        return True, rewrite_q

    col_to_table_dot_col = {}
    u_out = query_to_u_out(self, q, constraints, col_to_table_dot_col)
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