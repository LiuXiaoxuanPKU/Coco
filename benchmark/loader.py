import os
import json
from typing import Any
from funcy import dropwhile, nth, ldistinct, lmap, keep

from config import get_filename, FileType, EvalQuery
from constraint import ForeignKeyConstraint, FormatConstraint, InclusionConstraint, LengthConstraint, NumericalConstraint, PresenceConstraint, UniqueConstraint


def read_constraints(app: str, datadir: str):
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
    with open(get_filename(FileType.CONSTRAINT, app, datadir), "r") as f:
        constraints = (decode_constraint(
            table["table"], obj) for table in json.load(f) for obj in table["constraints"])
        return ldistinct(keep(constraints))


def read_rewrites(app: str, datadir: str, exclude_eq: bool):
    meta_folder = get_filename(FileType.REWRITE_OUTPUT_META, app, datadir)
    queries_folder = get_filename(FileType.REWRITE_OUTPUT_SQL_EQ, app, datadir)
    verifier_folder = queries_folder

    # Read out and cleanup ids of rewrite
    def extract_id(batch_folder: str):
        for pair in os.listdir(f"{verifier_folder}/{batch_folder}"):
            if not pair.endswith("res"):
                continue
            with open(f"{verifier_folder}/{batch_folder}/{pair}", "r") as f:
                provable = bool(f.readline())
            if provable:
                return batch_folder.split(".")[0], int(pair.split(".")[0]) - 1
        return None, None

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

    queries = []
    for file in os.listdir(verifier_folder):
        if not file.endswith("batch"):
            continue
        batch, id = extract_id(file)
        if id is None:
            continue
        if keep_rewrite((batch, id)):
            queries.append(read_rewrite((batch, id)))
    return queries
