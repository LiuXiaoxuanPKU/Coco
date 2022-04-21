from evaluator import evaluate_query, evaluate_actual_time
from extract_rule import ExtractQueryRule
import utils

# 1. run all the queries has inclusion constraints with original table
#     input: a list of sqls with inclusion constraints in it 
#     output: average timing for each query

# 2. copy phisical table
#     input: list of pairs of table-column in inclusion constraints
     
# 3. create enum type, convert inclusion constraint columns to enum type
#    input: inclusion constraints
#    output: a list of sqls to execute

# 4. generate new queries. e.g. change table_name to table_name_new

# 5. run new queries in new table
# =================================================================


# ===================== static variables ==========================
appname = "redmine"

# ===================== helper functions ==========================
# get a list of sqls to evaluate 
def get_sqls() -> list:
    pass

# generate a list of new sqls to evaluate performance
def generate_new_sqls() -> list:
    pass

# generate a list of sqls to create new enum type
def genrate_enum_type() -> list:
    pass

def covert_type() -> list:
    pass

# =================================================================
if __name__ == "__main__":
    pass