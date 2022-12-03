from typing import Tuple, Dict, List
from enum import Enum


class Stage(Enum):
    BASE = 1
    REWRITE = 2
    CONSTRAINT = 3
    CONSTRAINT_REWRITE = 4


class EvalQuery:
    id: Tuple[str, int]
    before: str
    after: str
    timer: Dict[Stage, float]
    rows: int
    rewrite_types: List[str]

    def __init__(self, id, before_sql, after_sql, rows, rewrite_types = []):
        self.id = id
        self.before = before_sql
        self.after = after_sql
        self.timer = {}
        self.rows = rows
        self.rewrite_types = rewrite_types
