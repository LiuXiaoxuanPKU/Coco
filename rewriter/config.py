import os
from pathlib import Path
from enum import IntEnum
from dataclasses import dataclass
from typing import List
from mo_sql_parsing import format

class FileType(IntEnum):
    RAW_QUERY = 0
    CONSTRAINT = 1
    VERIFIER_INPUT = 2
   
    REWRITE_OUTPUT_META = 3
    REWRITE_OUTPUT_SQL_EQ = 4
    
    ENUMERATE_CNT = 5
    ENUMERATE_TIME = 6
    REWRITE_STATS = 7
    ENUMERATE_ROOT = 8
  
def get_filename(_type: FileType, appname: str, cost_include_eq=True) -> str:
    projectdir = Path(__file__).parent.parent.absolute()
    datadir = os.path.join(projectdir, "data")
    cost_path = "cost_less_eq" if cost_include_eq else "cost_less"
 
    m = {
            # input query, constraint, create table sql
            FileType.RAW_QUERY : "%s/queries/%s/%s.pk" % (datadir, appname, appname),
            FileType.CONSTRAINT : "%s/constraints/%s"  % (datadir, appname),
            FileType.VERIFIER_INPUT : "%s/app_create_sql/%s.sql" %(datadir, appname),
            
            # output sqls from rewrite and tests
            FileType.REWRITE_OUTPUT_SQL_EQ: "%s/rewrites/%s/%s/sqls/" % (datadir, appname, cost_path),
            FileType.REWRITE_OUTPUT_META: "%s/rewrites/%s/%s/metadata/" % (datadir, appname, cost_path),
            
            # meta data (rewrite count/time) of rewrites
            FileType.ENUMERATE_ROOT: "%s/rewrites/%s/" % (datadir, appname),
            FileType.ENUMERATE_CNT: "%s/rewrites/%s/enumerate_cnts" % (datadir, appname),
            FileType.ENUMERATE_TIME: "%s/rewrites/%s/enumerate_times" % (datadir, appname),
            FileType.REWRITE_STATS: "%s/rewrites/%s/rewrite_stats" % (datadir, appname),
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

REWRITE_LIMIT = 100
