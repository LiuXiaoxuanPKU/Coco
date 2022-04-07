import rule


class ExtractInclusionRule(rule.Rule):
    def __init__(self, cs) -> None:
        # cs is a list of all inclusion constraints 
        # pre-filter constriants to use this function 
        super().__init__(cs)
        self.name = "ExtractInclusionQuery"
        self.table_to_field = self.get_inclusion_cs_map(cs)
        self.cs_tables = self.table_to_field.keys()

    def apply_single(self, q) -> list:
        if not 'from' in q:
            return []

        from_clause = q['from']
        select_clause = q['select'] if 'select' in q else q['select_distinct']

        # no JOIN case -> assume no table.field in anywhere (except table.*)
        if not self.contain_join(q):
            table = from_clause
            if not table in self.cs_tables:
                return []
            if self.check_select(select_clause, table):
                return [q] 
            # note the structure of orderby_clause is the same as select_clause
            if "orderby" in q:
                orderby_clause = q['orderby']
                if self.check_select(orderby_clause):
                    return [q]
            if not 'where' in q: # can stop here
                return []
            where_clause = q['where'] 
            if self.check_where_simple(where_clause, table):
                return [q]
            return []

        else: # JOIN case -> only need to check whether table.field fits the map 
            if self.check_select(select_clause):
                return [q]
            # note the structure of orderby_clause is the same as select_clause
            if "orderby" in q:
                orderby_clause = q['orderby']
                if self.check_select(orderby_clause):
                    return [q]
            from_clause = q['from']
            if self.check_join_from(from_clause):
                return [q]
            if not 'where' in q:
                return []
            where_clause = q['where']
            if self.check_where(where_clause):
                return [q]
            
        return []

    #=================== helper function ====================

    # return a map: table(str) -> fields(set) 
    def get_inclusion_cs_map(self, cs) -> dict:
        table_to_field = {}
        for c in cs:
            if not c.table in table_to_field.keys():
                table_to_field[c.table] = set()
            table_to_field[c.table].add(c.field)
        return table_to_field

    # return True if the query contain JOIN
    def contain_join(self, q) -> bool:
        if not 'from' in q:
            return False
        from_clause = q['from']
        return isinstance(from_clause, list)
  
    # select from no join simple case, only has one table
    def check_select(self, clause, table=None) -> bool:
        # {'value': 1, 'name': 'one'}
        # {'value': 'attachments.*'}
        # [{'value': 'attachments.filename', 'name': 'alias_0'}, {'value': 'projects.id'}]
        def check_value_clause(clause):
            value = clause['value']
            if isinstance(value, int):
                return False
            if "*" in value:
                return True
            elif table is not None and value in self.table_to_field[table]:
                return True
            elif "." in value:
                t, f = value.split(".")
                if t in self.cs_tables and f in self.table_to_field[t]:
                    return True
            else:
                return False

        if isinstance(clause, dict):
            return check_value_clause(clause)
        if isinstance(clause, list):
            for value_clause in clause:
                if check_value_clause(value_clause):
                    return True
        return False
    
    # check where in no join case
    def check_where_simple(self, clause, table) -> bool:
        # 'where': {'and': [{'eq': ['disk_filename', {'literal': '060719210727_archive.zip'}]}, {'neq': ['id', 21]}]}
        # {'eq': ['id', '$2']}
        op = list(clause.keys())[0]
        if op == "and" or op == "or":
            clause_list = clause[op]
            for item in clause_list:
                if self.check_where_simple(item, table):
                    return True
            return False
        else: # base case
            return clause[op][0] in self.table_to_field[table]

    # check on_clause inside from_clause
    def check_join_from(self, clause) -> bool:
        if "on" in clause[1].keys():
            on_clause = clause[1]["on"]
            if self.check_where(on_clause):
                return True
        return False

    # check where clauses, return true if where clause contain inclusion constraints, otherwise false
    def check_where(self, clause) -> bool:
        op = list(clause.keys())[0]
        if op == "and" or op == "or":
            clause_list = clause[op]
            for item in clause_list:
                if self.check_where(item):
                    return True
        # base case: does not contain and/or
        else:
            t, f = clause[op][0].split(".")
            return t in self.cs_tables and f in self.table_to_field[t]
        
    
    # assume if there is join there is table.column 

    # example:
    # {'select': {'value': 1, 'name': 'one'}, 'from': 'attachments', 
    # 'where': {'and': [{'eq': ['disk_filename', {'literal': '060719210727_archive.zip'}]}, 
    # {'neq': ['id', 21]}]}, 'limit': '$1'}