from enum import Enum


class Stage(Enum):
    BASE = 1
    REWRITE = 2
    CONSTRAINT = 3
    CONSTRAINT_REWRITE = 4


class EvalQuery:
    id: tuple[str, int]
    before: str
    after: str
    timer: dict[Stage, float]
    rows: int
    rewrite_types: list[str]

    def __init__(self, id, before_sql, after_sql, rows, rewrite_types = []):
        self.id = id
        self.before = before_sql
        self.after = after_sql
        self.timer = {}
        self.rows = rows
        self.rewrite_types = rewrite_types
