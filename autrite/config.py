from enum import Enum

class FileType(Enum):
    RAW_QUERY = 1
    REWRITE = 2
    CONSTRAINT = 3
    PARAM_QUERY = 4
    REWRITE_PERF = 5
    DB_PERF = 6
    REWRITE_DB_PERF = 7
    VERIFIER_INPUT = 8
    EMPTY_RESULT_QUERY = 9
    
def get_filename(_type, appname):
    m = {
            FileType.RAW_QUERY : "../queries/%s/%s.pk" % (appname, appname),
            FileType.REWRITE : "log/%s/%s_test_rewrite"  % (appname, appname),
            FileType.CONSTRAINT : "../constraints/%s"  % (appname),
            FileType.PARAM_QUERY : "log/%s/all_queries" % appname,
            FileType.REWRITE_PERF : "log/%s/rewrite_perf" % appname,
            FileType.DB_PERF : "log/%s/db_perf" % appname,
            FileType.REWRITE_DB_PERF : "log/%s/db_rewrite_perf" % appname,
            FileType.VERIFIER_INPUT : "app_create_sql/all/%s/" % appname,      
            FileType.EMPTY_RESULT_QUERY: "log/%s/empty_query" % appname 
    }
    return m[_type]

CONNECT_MAP = {
    "redmine" : "user=redmine password=my_password dbname=redmine_develop",
    "redmine_test" : "user=redmine password=my_password dbname=redmine_test",
    "forem" : "user=ubuntu password=my_password dbname=Forem_development",
    "openproject" : "user=openproject password=my_password dbname=openproject_dev"
}

class RewriteQuery:
    def __init__(self, q) -> None:
        self.q = q
        self.rewrites = []
        self.sql_param = None
        
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

REWRITE_LIMIT = 10000
