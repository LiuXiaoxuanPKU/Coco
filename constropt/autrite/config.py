import os
from pathlib import Path
from enum import IntEnum
from dataclasses import dataclass
from typing import List

class FileType(IntEnum):
    TEST_PROVE_Q = 1
    RAW_QUERY = 2
    CONSTRAINT = 3
    VERIFIER_INPUT = 4
   
    REWRITE_OUTPUT_SQL_EQ = 6
    REWRITE_OUTPUT_SQL_NOT_EQ = 7

    VERIFIER_OUTPUT_IDX = 8
    VERIFIER_OUTPUT_SQL = 9

    REWRITE_PERF = 10
    DB_PERF = 11
    ENUM_EVAL = 12 
    
    EMPTY_RESULT_QUERY = 13
    PRECHECK_STR2INT_NUM =14
    REWRITE_TIME = 15
    VERIFIER_TIME = 16
  
def get_filename(_type, appname, rewrite_types=None):
    workdir = os.getcwd()
    path = Path(workdir)
    projectdir = path.parent.parent.absolute()
      
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
            FileType.PRECHECK_STR2INT_NUM : "log/precheck_strtoint_num",
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
   
class RewriteType(IntEnum):
    AddPredicate = 6
    RewriteNullPredicate = 5
    RemovePredicate = 4
    RemoveJoin = 3
    RemoveDistinct = 2
    AddLimitOne = 1
    ReplaceOuterJoin = 0
    UnionToUnionAll = -1
    
@dataclass
class RewriteQuery:
    q_raw: str
    q_obj: dict# json representation of the query
    rewrites:List[str] = None
    q_raw_param: str = ""
    estimate_cost: int = -1 # cost estimated by the verifier

    def __post_init__(self):
        if self.rewrites is None:
            self.rewrites = []
            
    def to_dict(self):
        if self.rewrites is None:
            return {
                "sql" : format(self.q_obj),
                "cost" : self.estimate_cost,
            }
        return {
            "sql" : format(self.q_obj),
            "cost" : self.estimate_cost,
            "rewrite_types" : [r.__class__.__name__.split('.')[-1] for r in self.rewrites]
        }
        
# REWRITE_LIMIT = 100000000
REWRITE_LIMIT = 100
