import os
from pathlib import Path
from enum import IntEnum

class FileType(IntEnum):
    TEST_PROVE_Q = 1
    RAW_QUERY = 2
    CONSTRAINT = 3
    VERIFIER_INPUT = 4
   
    REWRITE_OUTPUT_META = 5
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
  
def get_path(type_: FileType, app: str):
    proot = Path(os.path.abspath(__file__)).parent.parent.parent.parent
    log = proot.joinpath("constropt/autrite/log")
 
    m = {
            FileType.CONSTRAINT : Path(f"{proot}/constraints/{app}"),
            # output sqls from rewrite and tests
            FileType.REWRITE_OUTPUT_META: Path(f"{log}/{app}/cosette/cost_less_eq_verify/metadata/"),
            FileType.REWRITE_OUTPUT_SQL_EQ: Path(f"{log}/{app}/cosette/cost_less_eq_verify/sqls/"),
            
            # output sqls from cosette
            FileType.VERIFIER_OUTPUT_IDX: Path(f"{log}/{app}/cosette/verifier-result-leq"),
            FileType.REWRITE_PERF: Path(f"{log}/perf/{app}"),
    }
    return m[type_]

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