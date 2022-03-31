from loader import Loader
from config import CONNECT_MAP, FileType, get_filename, RewriteQuery
import constraint 
from collections import defaultdict

# This script is for extracting all the queries 
# has the table column with the inclusion constraints
# return filtered query objects 

################################
# load constraints and queries #
################################
appname = "redmine"
constraint_filename = get_filename(FileType.CONSTRAINT, appname)
query_filename = get_filename(FileType.RAW_QUERY, appname)
offset = 30
query_cnt = 1
constraints = Loader.load_constraints(constraint_filename)
queries = Loader.load_queries(query_filename, offset, query_cnt)
print(queries)

# filter out only inclusion constraints
inclusion_constraints = [c for c in constraints if isinstance(c, constraint.InclusionConstraint)]

def get_table_and_field(constraints):
    # get table & field names and their maps
    tables = set()
    fields = set()
    table_to_field = defaultdict(lambda: "")
    for c in constraints:
        tables.add(c.table)
        fields.add(c.field)
        table_to_field[c.table] = c.field
    return tables, fields, table_to_field

tables, fields, table_to_field = get_table_and_field(inclusion_constraints)
print(tables)
print(fields)
print(table_to_field)


######################
# filter out queries #
######################

# {'select': {'value': 1, 'name': 'one'}, 'from': 'attachments', 
# 'where': {'and': [{'eq': ['disk_filename', {'literal': '060719210727_archive.zip'}]}, 
# {'neq': ['id', 21]}]}, 'limit': '$1'}

# first check if it has tables 
def include_table(q, tables):
    q_table = q['where']
    if isinstance(q_table, str):
        return q_table in tables
    return bool(tables & set(q_table))
    
# if not, return false
# then check if it has columns 
def include_fields(q, fields):
    where = q['where']
    select = q['select']
    return bool(set(where) & set(select) & fields)
# if has, return true
# check if table and column has corresponding relationship

def filter_query(queries) -> list:
    # queries is a list of queries, return a list of filtered queries
    filtered_q = []
    for q in queries:
        if include_table(q, tables) and include_fields(q, fields):
            filtered_q.append(q)
    return filtered_q

