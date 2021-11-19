import functools
from .constraint import *


def get_unique_constraints_fields(constraints):
    unique_constraints = list(
        filter(lambda x: isinstance(x, UniqueConstraint), constraints))

    def add_tablename_to_field(table, fields):
        return list(map(lambda x: "%s.%s" % (table, x), fields))
    fields = list(functools.reduce(lambda acc, x: acc + [add_tablename_to_field(x.table, [x.field] + x.scope)],
                                   unique_constraints, []))
    return fields


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
        if key == "eq" or (key == "in" and len(predicates[key][1]) == 1):
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


def add_limit_one(self, q, constraints):
    if 'limit' in q or 'where' not in q:
        return False, q

    where_clause = q['where']
    keys, values = list(where_clause.keys()), list(where_clause.values())
    has_inner_join = self.check_query_has_join(q)
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
        fields_list = get_unique_constraints_fields(constraints)
        for fields in fields_list:
            if set(fields).issubset(set(full_used_fields)):
                return True
        return False

    # case 1: no join
    table = q['from']
    if not has_inner_join:
        # handle nested single query
        if isinstance(table, dict) and isinstance(table['value'], dict):
            rewritten, _ = self.rewrite_single_query(
                table['value'], constraints)
            table['value'] = rewritten
        # case 1: no join, only has one predicate
        if check_predicate_return_one_tuple(where_clause, table):
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
                    where_clause, table)
            if return_one:
                rewrite_q = q.copy()
                rewrite_q['limit'] = 1
                return True, rewrite_q
    # has inner join
    else:
        join_tables = self.get_query_tables(q)
        predicates = q['where']
        ok, _ = check_connect_by_and_equal(predicates)
        if not ok:
            return False, q

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
            fields_list = get_unique_constraints_fields(constraints)
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
                # rewrite nested query
                if isinstance(table, dict) and isinstance(table['value'], dict):
                    rewritten, _ = self.rewrite_single_query(
                        table['value'], constraints)
                    table['value'] = rewritten
                # get predicates on that relation
                table_predicates = get_table_predicates(predicates, table)
                for predicate in table_predicates:
                    return_one = check_predicate_return_one_tuple(
                        predicate, table)
                    can_rewrite = can_rewrite or return_one
            if not can_rewrite:
                return False, q
            rewrite_q = q.copy()
            rewrite_q['limit'] = 1
            return True, rewrite_q
        # case 3: inner join, join on any columns
        # each of the relation returns no more than 1 tuple
        else:
            for table in join_tables:
                # rewrite nested query
                if isinstance(table, dict) and isinstance(table['value'], dict):
                    rewritten, _ = self.rewrite_single_query(
                        table['value'], constraints)
                    table['value'] = rewritten
                # get predicates on that relation
                table_predicates = get_table_predicates(predicates, table)
                for predicate in table_predicates:
                    return_one = check_predicate_return_one_tuple(
                        predicate, table)
                    if not return_one:
                        return False, q
            rewrite_q = q.copy()
            rewrite_q['limit'] = 1
            return True, rewrite_q

    return False, q
