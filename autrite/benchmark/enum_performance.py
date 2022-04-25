from evaluator import evaluate_query, evaluate_actual_time
from extract_rule import ExtractQueryRule
from utils import generate_query_param_single
from config import FileType, get_filename
from loader import Loader
from config import CONNECT_MAP

# 1. run all the queries has inclusion constraints with original table
#     input: a list of sqls with inclusion constraints in it 
#     output: average timing for each query

# 2. copy phisical table
#     input: list of pairs of table-column in inclusion constraints
     
# 3. create enum type, convert inclusion constraint columns to enum type
#    input: inclusion constraints
#    output: a list of sqls to execute

# 4. generate new queries. e.g. change table_name to table_name_new

# 5. run new queries in new table (each table run 5 times get the ave time, only record ave time)
# format: sql: ...; before: ...; after: ...; dump to log 
# =================================================================


# ===================== static variables ==========================
appname = "redmine"
offset = 0
query_cnt = 10

# ===================== helper functions ==========================
# alter column from enum to VarChar. 
# Input: a list of constraints; Output: a list of sqls
def enum_to_varchar(cs) -> list:
    sqls = []
    for c in cs:
        sql = "alter table {} alter column {} type varchar;".format(c.table, c.field)
        sqls.append(sql)
    return sqls

# create a copy of table schemas
def create_table(tables) -> list:
    sqls = []
    for t in tables:
        new_t = "_test_str2int".format(t)
        sql = "CREATE TABLE {} ( like {} INCLUDING DEFAULTS INCLUDING CONSTRAINTS INCLUDING INDEXES );".format(new_t, t)
        sqls.append(sql)
    return sqls

# insert values to the copied table
def insert_value(tables) -> list:
    sqls = []
    for t in tables:
        new_t = "{}_test_str2int".format(t)
        sql = "insert into {} select * from users;".format(new_t)
        sqls.append(sql)
    return sqls
    
# generate a list of sqls to create new enum type
def generate_enum_type(cs) -> list:
    # create TYPE table_column_value as ENUM ('value1', 'value2', 'value3', 'value4');
    def get_enum_value():
        pass

    # return a str list of possible values
    def parse_enum_value() -> list:
        pass
    
    sqls = []
    for c in cs:
        table = c.table
        field = c.field
        values = parse_enum_value()
        sql = "create TYPE {}_{}_values as ENUM ({});".format(table, field, values)
        sqls.append(sql)
    return sqls

# alter field type of the copied table to enum type
def alter_type(cs) -> list:
    # ALTER TABLE t_test_str2int ALTER COLUMN c TYPE table_column_value USING c::table_column_value;
    sqls = []
    for c in cs:
        new_t = "{}_test_str2int".format(c.table)
        field = c.field
        type_name = "{}_{}_values".format(c.table, c.field)
        sql = "ALTER TABLE {} ALTER COLUMN {} TYPE {} USING {}::{};".format(
            new_t, field, type_name, field, type_name)
        sqls.append(sql)
    return sqls

# generate a list of new sqls to evaluate performance [write a new apply to single?]
def generate_new_sqls(sqls, cs) -> list:

    # get inclusion tables as a set
    def get_tables(cs) -> set:
        return set([c.table for c in cs])

    def apply_single(sql, tables):
        for t in tables:
            if t in sql:
                new_t = "{}_test_str2int".format(t)
                sql = sql.replace(t, new_t)
        return sql

    tables = get_tables(cs)
    new_sqls = []
    for sql in sqls:
        new_sql = apply_single(sql, tables)
        new_sqls.append(new_sql)
    return new_sqls
    

# ============================= main ================================
if __name__ == "__main__":
    query_filename = get_filename(FileType.RAW_QUERY, appname)
    queries = Loader.load_queries(query_filename)