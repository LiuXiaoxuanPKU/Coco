from enum import IntEnum


class FileType(IntEnum):
    CONSTRAINT = 0
    REWRITE_OUTPUT_META = 1
    REWRITE_OUTPUT_SQL_EQ = 2
    BENCH_RESULT = 3
    
    GRAPH_REWRITE_PERF = 4
    GRAPH_TYPE_PERF = 5


def get_filename(_type: FileType, appname: str, datadir: str, cost_include_eq=True) -> str:
    cost_path = "cost_less_eq" if cost_include_eq else "cost_less"

    m = {
        FileType.CONSTRAINT: "%s/constraints/%s" % (datadir, appname),

        # output sqls from rewrite and tests
        FileType.REWRITE_OUTPUT_SQL_EQ: "%s/rewrites/%s/%s/sqls/" % (datadir, appname, cost_path),
        FileType.REWRITE_OUTPUT_META: "%s/rewrites/%s/%s/metadata/" % (datadir, appname, cost_path),

        FileType.BENCH_RESULT: "%s/benchmark/%s" % (datadir, appname),
        
        # plots
        FileType.GRAPH_REWRITE_PERF: "%s/figures/%s_rewrite_perf.png" % (datadir, appname),
        FileType.GRAPH_TYPE_PERF: "%s/figures/%s_type_perf.png" % (datadir, appname)
    }
    return m[_type]


CONNECT_MAP = {
    "redmine": "user=redmine password=my_password dbname=redmine_develop",
    "redmine_test": "user=redmine password=my_password dbname=redmine_test",
    "forem": "user=ubuntu password=my_password dbname=Forem_development",
    "openproject": "user=openproject password=my_password dbname=openproject_dev",
    "mastodon": "user=ubuntu password=my_password dbname=mastodon_development",
    "spree": "user=ubuntu password=my_password dbname=spree_core_spree_test",
    "openstreetmap": "user=ubuntu password=my_password dbname=openstreetmap"
}


class Stage(IntEnum):
    BASE = 1
    REWRITE = 2
    CONSTRAINT = 3
    CONSTRAINT_REWRITE = 4


class EvalQuery:
    id: tuple[str, int]
    before: str
    after: str
    timer: dict[Stage, list[float]]
    rows: int
    rewrite_types: list[str]

    def __init__(self, id, before_sql, after_sql, rows, rewrite_types=[]):
        self.id = id
        self.before = before_sql
        self.after = after_sql
        self.timer = {}
        self.rows = rows
        self.rewrite_types = rewrite_types

    def to_json(self):
        return {
            "id": self.id,
            "before": self.before,
            "after": self.after,
            "timer": self.timer,
            "rewrite_types": self.rewrite_types
        }

    @staticmethod
    def from_json(obj):
        q = EvalQuery(obj["id"], obj["before"], obj["after"],
                      None, obj["rewrite_types"])
        stage_dict = {}
        for s in Stage:
            stage_dict[s.value] = s
        q.timer = {}
        for k in obj["timer"]:
            q.timer[stage_dict[int(k)]] = obj['timer'][k]
        return q


class RewriteType(IntEnum):
    AddPredicate = 6
    RewriteNullPredicate = 5
    RemovePredicate = 4
    RemoveJoin = 3
    RemoveDistinct = 2
    AddLimitOne = 1
    ReplaceOuterJoin = 0
    UnionToUnionAll = -1
