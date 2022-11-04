import argparse
import traceback
from config import CONNECT_MAP
from constraint import Constraint, NumericalConstraint, PresenceConstraint, UniqueConstraint
from shared import EvalQuery, Stage
from loader import read_rewrites, read_constraints, write_bench_results
from tqdm import tqdm
from funcy import keep

from evaluator import Evaluator


def eval(rewrites: list[EvalQuery], connection: str, stage: Stage, repeat=1):
    for rewrite in tqdm(rewrites):
        query = rewrite.before if stage in [
            Stage.BASE, Stage.CONSTRAINT] else rewrite.after
        rewrite.timer[stage], rewrite.rows = Evaluator.evaluate_actual_time(query, connection, repeat)

def process_constraints(constraints: list[Constraint]):
    def process_constraint(c: Constraint):
        match c:
            case Constraint(table=None): return None
            case UniqueConstraint():
                name = str(c)
                install = f"ALTER TABLE {c.table} ADD CONSTRAINT {name} UNIQUE ({', '.join(c.field)});"
                cleanup = f"ALTER TABLE {c.table} DROP CONSTRAINT IF EXISTS {name};"
            case PresenceConstraint():
                name = str(c)
                install = f"ALTER TABLE {c.table} ALTER COLUMN {c.field} SET NOT NULL;"
                cleanup = f"ALTER TABLE {c.table} ALTER COLUMN {c.field} DROP NOT NULL;"
            case NumericalConstraint():
                name = str(c)
                match (c.min, c.max):
                    case (min, None) if min is not None:
                        install = f"ALTER TABLE {c.table} ADD CONSTRAINT {name} CHECK ({c.field} >= {min});"
                    case (None, max) if max is not None:
                        install = f"ALTER TABLE {c.table} ADD CONSTRAINT {name} CHECK ({c.field} <= {max});"
                    case (min, max) if min is not None and max is not None:
                        install = f"ALTER TABLE {c.table} ADD CONSTRAINT {name} CHECK ({c.field} >= {min} AND {c.field} <= {max});"
                cleanup = f"ALTER TABLE {c.table} DROP CONSTRAINT IF EXISTS {name};"
            case _: return None
        return install, cleanup
    return zip(*keep(map(process_constraint, constraints)))

def exec_statements(sqls: list[str], connection: str):
    for sql in sqls:
        try:
            Evaluator.evaluate_query(sql, connection)
        except Exception:
            print(f"Failed to execute statement:\n{sql}.")
            print(traceback.format_exc())

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--app")
    parser.add_argument("--exclude_eq", default=False, action="store_true")
    args = parser.parse_args()
    rewrites = read_rewrites(args.app, args.exclude_eq)
    connection = CONNECT_MAP[args.app]
    installs, cleanups = process_constraints(read_constraints(args.app))
    print("========  Cleanup constraints  ========")
    exec_statements(cleanups, connection)
    print("========  Org  ========")
    eval(rewrites, connection, Stage.BASE)
    print("========  Rewrite  ========")
    eval(rewrites, connection, Stage.REWRITE)
    print("========  Install constraints  ========")
    exec_statements(installs, connection)
    print("========  DB Constriant  ========")
    eval(rewrites, connection, Stage.CONSTRAINT)
    print("========  Rewrite Constraint  ========")
    eval(rewrites, connection, Stage.CONSTRAINT_REWRITE)
    write_bench_results(rewrites, args.app)
