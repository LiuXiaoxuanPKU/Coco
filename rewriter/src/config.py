from pathlib import Path
from enum import Enum, IntEnum
from dataclasses import dataclass
from typing import List
from mo_sql_parsing import format

class FileType(IntEnum):
    RAW_QUERY = 0
    CONSTRAINT = 1
    DATABASE_SCHEMA = 2
   
    REWRITE_META = 3
    REWRITTEN_QUERY = 4
    
    ENUMERATE_CNT = 5
    ENUMERATE_TIME = 6
    REWRITE_STATS = 7
    ENUMERATE_ROOT = 8
    
    BENCH_REWRITE_PERF = 9
    BENCH_STR2INT_NUM = 10
    BENCH_STR2INT_PERF = 11
    
    GRAPH_REWRITE_PERF = 12
    GRAPH_TYPE_PERF = 13
    GRAPH_CONSTRAINT_DIS = 14
    GRAPH_CONSTRAINT_COMPARE = 15
  
def get_path(_type: FileType, appname: str, datadir: str, cost_include_eq=True) -> Path:
    cost_path = "cost_less_eq" if cost_include_eq else "cost_less"
 
    m = {
            # input query, constraint, create table sql
            FileType.RAW_QUERY : Path(f"{datadir}/queries/{appname}/{appname}.pk"),
            FileType.CONSTRAINT : Path(f"{datadir}/constraints/{appname}"),
            FileType.DATABASE_SCHEMA : Path(f"{datadir}/app_create_sql/{appname}.sql"),
            
            # output sqls from rewrite and tests
            FileType.REWRITTEN_QUERY: Path(f"{datadir}/rewrites/{appname}/{cost_path}/sqls/"),
            FileType.REWRITE_META: Path(f"{datadir}/rewrites/{appname}/{cost_path}/metadata/"),
            
            # meta data (rewrite count/time) of rewrites
            FileType.ENUMERATE_CNT: Path(f"{datadir}/rewrites/{appname}/enumerate_cnts"),
            FileType.ENUMERATE_TIME: Path(f"{datadir}/rewrites/{appname}/enumerate_times"),
            FileType.REWRITE_STATS: Path(f"{datadir}/rewrites/{appname}/rewrite_stats"),
            
            # benchmark results dir
            FileType.BENCH_REWRITE_PERF: Path(f"{datadir}/{appname}_rewrite_perf"),
            FileType.BENCH_STR2INT_NUM: Path(f"{datadir}/{appname}_str2int_count"),
            FileType.BENCH_STR2INT_PERF: Path(f"{datadir}/{appname}_str2int_perf"),
            
            # graphs
            FileType.GRAPH_REWRITE_PERF: Path(f"{datadir}/{appname}_rewrite_perf.pdf"),
            FileType.GRAPH_TYPE_PERF: Path(f"{datadir}/{appname}_type_perf.pdf"),
            FileType.GRAPH_CONSTRAINT_DIS: Path(f"{datadir}/figures/constraint_dis.pdf"),
            FileType.GRAPH_CONSTRAINT_COMPARE: Path(f"{datadir}/figures/constraint_compare.pdf")
    }
    return m[_type]

CONNECT_MAP = {
    "redmine" : "dbname=redmine_develop",
    "forem" : "dbname=Forem_development",
    "openproject" : "dbname=openproject_dev",
    "mastodon": "dbname=mastodon_development",
    "spree": "dbname=spree_core_spree_test",
    "openstreetmap": "dbname=openstreetmap"
}
   
class RewriteType(Enum):
    AddPredicate = "PI/E"
    RewriteNullPredicate = "ES"
    RemovePredicate = "PI/E"
    RemoveJoin = "JI/E"
    RemoveDistinct = "RD"
    AddLimitOne = "AL"
    ReplaceOuterJoin = "JI/E"
    UnionToUnionAll = "UA"
    
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
