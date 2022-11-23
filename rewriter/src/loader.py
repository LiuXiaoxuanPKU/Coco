from pathlib import Path
import pickle
from mo_sql_parsing import parse, format
import json
from config import RewriteQuery
from tqdm import tqdm

from typing import Any
from funcy import dropwhile, nth, ldistinct, lmap, keep

from shared import EvalQuery
from constraint import *

def read_queries(file: str, offset: int, cnt: int) -> list[str]:
    with open(file, "rb") as f:
        queries = pickle.load(f)
    print(f"Total # of raw queries: {len(queries)}")
    queries = ldistinct(queries)
    print(f"Total # of unique raw queries: {len(queries)}")
    queries.sort(key=len)
    queries = queries[offset:offset+cnt]
    rewrite_qs = []
    fail_raw_queries = []
    for line in tqdm(queries):
        if len(line) >= 25000: continue
        if 'SELECT 1 AS one' in line and 'LIMIT' in line:
            # HACK: Find and replace the token after `LIMIT`
            tokens = line.split(' ')
            idx = tokens.index('LIMIT')
            token = tokens[idx + 1]
            line = line.replace(token, '1')
        try:
            q_obj = parse(line)
            q = RewriteQuery(format(q_obj), q_obj)
            rewrite_qs.append(q)
        except Exception:
            fail_raw_queries.append(line)
    print(f"===========[Success] Parsing {len(rewrite_qs)} unique queries")
    print(f"===========[Fail]    Parsing {len(fail_raw_queries)} queries")
    return rewrite_qs
    
def read_constraints(file: Path) -> list[Constraint]:
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
    with open(file, "r") as f:
        constraints = (decode_constraint(table["table"], obj) for table in json.load(f) for obj in table["constraints"])
        return ldistinct(keep(constraints))

def read_rewrites(meta_folder: Path, queries_folder: Path, include_eq: bool) -> list[EvalQuery]:
    # Read out and cleanup id of rewrite
    def extract_id(res_file: Path):
        with open(res_file, "r") as f:
            if f.readline().strip().lower() == "true":
                return res_file.parent.name.removesuffix(".batch"), int(res_file.name.removesuffix(".res")) - 1

    # Prune away ignored rewrite
    def prune_rewrite(id: tuple[str, int]):
        if include_eq:
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
    
    return lmap(read_rewrite, filter(prune_rewrite, keep(extract_id, queries_folder.glob("*.batch/*.res"))))

def read_bench_results(file: Path) -> list[EvalQuery]:
    with open(file, "br") as f:
        return pickle.load(f)

def write_bench_results(file: Path, rewrites: list[EvalQuery]):
    file.parent.mkdir(parents=True, exist_ok=True)
    with open(file, "bw+") as f:
        pickle.dump(rewrites, f)