import pickle
from typing import Any
import json
from constraint import ForeignKeyConstraint, FormatConstraint, InclusionConstraint, LengthConstraint, NumericalConstraint, PresenceConstraint, UniqueConstraint
from config import FileType, get_path
from funcy import dropwhile, nth, ldistinct, lmap, keep
from shared import EvalQuery


def read_constraints(app: str):
    def decode_constraint(table: str, obj: dict[str, Any]):
        match obj:
            case {"^o": "LengthConstraint", "field_name": field, "db": db, "min": min, "max": max}:
                return LengthConstraint(table, field, db, min, max)
            case {"^o": "UniqueConstraint", "cond": None | "", "type": type, "field_name": field, "db": db}:
                return UniqueConstraint(table, field, db, type, cond=None)
            case {"^o": "PresenceConstraint", "field_name": field, "db": db}:
                return PresenceConstraint(table, field, db)
            case {"^o": "InclusionConstraint", "field_name": field, "db": db, "values": values}:
                return InclusionConstraint(table, field, db, values)
            case {"^o": "FormatConstraint", "field_name": field, "db": db, "format": format}:
                return FormatConstraint(table, field, db, format)
            case {"^o": "NumericalConstraint", "field_name": field, "db": db, "min": min, "max": max} if not (min is None and max is None):
                return NumericalConstraint(table, field, db, min, max)
            case {"^o": "ForeignKeyConstraint", "fk_column_name": field, "db": db, "class_name": cls}:
                return ForeignKeyConstraint(table, field, db, cls)
            case _:
                print(f"Unsupported constraint: {obj}")
                return None
    with open(get_path(FileType.CONSTRAINT, app), "r") as f:
        constraints = (decode_constraint(
            table["table"], obj) for table in json.load(f) for obj in table["constraints"])
        return ldistinct(keep(constraints))

def read_rewrites(app: str, exclude_eq: bool):
    meta_folder = get_path(FileType.REWRITE_OUTPUT_META, app)
    queries_folder = get_path(FileType.REWRITE_OUTPUT_SQL_EQ, app)

    # Read out and cleanup ids of rewrite
    def extract_id(line: str):
        file, num = line.split(":")
        return file, int(num) - 1

    # Prune away ignored rewrites
    def keep_rewrite(id: tuple[str, int]):
        if not exclude_eq:
            return True
        with open(f"{meta_folder}/{id[0]}.json", "r") as f:
            obj = json.load(f)
            return obj["org"]["cost"] > obj["rewrites"][id[1]]["cost"]

    # Read actual rewrite pair
    def read_rewrite(id: tuple[str, int]):
        batch, i = id
        with open(f"{meta_folder}/{batch}.json", "r") as f:
            obj = json.load(f)
            rewrite_types = obj["rewrites"][i]["rewrite_types"]
        with open(f"{queries_folder}/{batch}.sql") as f:
            f = dropwhile(lambda l: "-- Original Query" not in l, f)
            before = nth(1, f)
            f = dropwhile(lambda l: "-- Rewritten Queries" not in l, f)
            after = nth(i + 1, f)
        return EvalQuery(id, before, after, 0, rewrite_types)

    with open(get_path(FileType.VERIFIER_OUTPUT_IDX, app), "r") as f:
        return lmap(read_rewrite, filter(keep_rewrite, map(extract_id, f)))

def read_bench_results(app: str) -> list[EvalQuery]:
    with open(get_path(FileType.REWRITE_PERF, app), "br") as f:
        return pickle.load(f)

def write_bench_results(rewrites: list[EvalQuery], app: str):
    output = get_path(FileType.REWRITE_PERF, app)
    output.parent.mkdir(parents=True, exist_ok=True)
    with open(output, "bw+") as f:
        pickle.dump(rewrites, f)
