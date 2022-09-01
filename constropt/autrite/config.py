import os
from pathlib import Path
from enum import Enum

class FileType(Enum):
    TEST_PROVE_Q = 1
    RAW_QUERY = 2
    CONSTRAINT = 3
    VERIFIER_INPUT = 4

    REWRITE_OUTPUT_SQL_EQ = 5
    REWRITE_OUTPUT_SQL_NOT_EQ = 6

    VERIFIER_OUTPUT_IDX = 7
    VERIFIER_OUTPUT_SQL = 8

    REWRITE_PERF = 9
    DB_PERF = 10
    ENUM_EVAL = 11 
    
    EMPTY_RESULT_QUERY = 12
    PRECHECK_STR2INT_NUM =13
    REWRITE_TIME = 14
    VERIFIER_TIME = 15
  
def get_filename(_type, appname):
    workdir = os.getcwd()
    path = Path(workdir)
    projectdir = path.parent.parent.parent.absolute()
    m = {
            # input query, constraint, create table sql
            FileType.TEST_PROVE_Q : "log/%s/prove.sql" % appname,
            FileType.RAW_QUERY : "%s/queries/%s/%s.pk" % (projectdir, appname, appname),
            FileType.CONSTRAINT : "%s/constraints/%s"  % (projectdir, appname),
            FileType.VERIFIER_INPUT : "log/%s/cosette/create.sql" % appname,
            
            # output sqls from rewrite and tests
            FileType.REWRITE_OUTPUT_SQL_EQ: "log/%s/cosette/eq/" % appname,
            FileType.REWRITE_OUTPUT_SQL_NOT_EQ: "log/%s/cosette/not_eq/" % appname, 
            
            # output sqls from cosette
            FileType.VERIFIER_OUTPUT_IDX: "log/%s/cosette/verifier-result" % appname,
            FileType.VERIFIER_OUTPUT_SQL : "log/%s/cosette/result.sql" % appname, 
                      
            # output performance file
            FileType.REWRITE_PERF : "log/%s_perf" % appname,
            FileType.DB_PERF : "log/db/%s_db_speedup" % appname,
            FileType.ENUM_EVAL : "log/%s/enum_evaluation_time" % appname,
            
            FileType.EMPTY_RESULT_QUERY: "log/%s/empty_query" % appname,
            FileType.PRECHECK_STR2INT_NUM : "../log/precheck_strtoint_num",
            FileType.REWRITE_TIME: "log/%s/rewrite_time" % appname,
            FileType.VERIFIER_TIME: "log/%s/verify_time" % appname
    }
    return m[_type]

CONNECT_MAP = {
    "redmine" : "user=redmine password=my_password dbname=redmine_develop",
    "redmine_test" : "user=redmine password=my_password dbname=redmine_test",
    "forem" : "user=ubuntu password=my_password dbname=Forem_development",
    "openproject" : "user=openproject password=my_password dbname=openproject_dev",
    "mastodon": "user=ubuntu password=my_password dbname=mastodon_development",
    "spree": "user=ubuntu password=my_password dbname=spree_core_spree_test",
    "openstreetmap": "user=ubuntu password=my_password dbname=openstreetmap"
}

class RewriteQuery:
    def __init__(self, q_raw, q_obj) -> None:
        self.q_raw = q_raw
        self.q_obj = q_obj # json representation of the query
        self.rewrites = []
        self.q_raw_param = None
        self.estimate_cost = None # cost estimated by the verifier
        
PRIORITY_MAP = {
    "AddPredicate" : 6,
    "RewriteNullPredicate" : 5,
    "RemovePredicate" : 4,
    "RemoveJoin" : 3,
    "RemoveDistinct" : 2,
    "AddLimitOne" : 1,
    "ReplaceOuterJoin": 0,
    "UnionToUnionAll" : -1
}

# REWRITE_LIMIT = 100000000
REWRITE_LIMIT = 100
