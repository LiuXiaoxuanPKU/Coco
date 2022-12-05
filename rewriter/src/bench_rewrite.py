import traceback
from shared import Stage, EvalQuery

from tqdm import tqdm
import clize
import loader
from constraint import Constraint, NumericalConstraint, PresenceConstraint, UniqueConstraint
from evaluator import Evaluator
from config import CONNECT_MAP, get_path, FileType
from funcy import keep


def eval(rewrites: list[EvalQuery], connection: str, stage: Stage, repeat):
    for rewrite in tqdm(rewrites):
        query = rewrite.before if stage in [
            Stage.BASE, Stage.CONSTRAINT] else rewrite.after
        rewrite.timer[stage] = Evaluator.evaluate_actual_time(
            query, connection, repeat)


def exec_statements(sqls: list[str], connection: str):
    for sql in sqls:
        try:
            Evaluator.evaluate_query(sql, connection)
        except Exception:
            pass
            print(f"Failed to execute statement:\n{sql}.")
            print(traceback.format_exc())


def process_constraints(constraints: list[Constraint]) -> tuple[list[str], list[str]]:
    def process_constraint(c: Constraint):
        name = str(c)
        match c:
            case UniqueConstraint():
                install = f"ALTER TABLE {c.table} ADD CONSTRAINT {name} UNIQUE ({', '.join(c.field)});"
                cleanup = f"ALTER TABLE {c.table} DROP CONSTRAINT IF EXISTS {name};"
                return install, cleanup
            case PresenceConstraint():
                install = f"ALTER TABLE {c.table} ALTER COLUMN {c.field} SET NOT NULL;"
                cleanup = f"ALTER TABLE {c.table} ALTER COLUMN {c.field} DROP NOT NULL;"
                return install, cleanup
            case NumericalConstraint():
                match (c.min, c.max):
                    case (min, None) if min is not None:
                        install = f"ALTER TABLE {c.table} ADD CONSTRAINT {name} CHECK ({c.field} >= {min});"
                    case (None, max) if max is not None:
                        install = f"ALTER TABLE {c.table} ADD CONSTRAINT {name} CHECK ({c.field} <= {max});"
                    case (min, max) if min is not None and max is not None:
                        install = f"ALTER TABLE {c.table} ADD CONSTRAINT {name} CHECK ({c.field} >= {min} AND {c.field} <= {max});"
                cleanup = f"ALTER TABLE {c.table} DROP CONSTRAINT IF EXISTS {name};"
                return install, cleanup
            case _: return None
    return zip(*keep(map(process_constraint, constraints)))


def benchmark(data_dir: str, app: str, *, include_eq: bool = False, repeat=100):
    rewrites = loader.read_rewrites(
        get_path(FileType.REWRITE_META, app, data_dir, include_eq),
        get_path(FileType.REWRITTEN_QUERY, app, data_dir, include_eq),
        include_eq
    )
    connection = CONNECT_MAP[app]
    constraints = loader.read_constraints(
        get_path(FileType.CONSTRAINT, app, data_dir), include_all=False)
    installs, cleanups = process_constraints(constraints)
    print("========  Cleanup constraints  ========")
    exec_statements(cleanups, connection)
    print("========  Original queries  ========")
    eval(rewrites, connection, Stage.BASE, repeat)
    print("========  Rewritten queries  ========")
    eval(rewrites, connection, Stage.REWRITE, repeat)
    print("========  Install constraints  ========")
    exec_statements(installs, connection)
    print("========  Database constriant  ========")
    eval(rewrites, connection, Stage.CONSTRAINT, repeat)
    print("========  Rewrite constraint  ========")
    eval(rewrites, connection, Stage.CONSTRAINT_REWRITE, repeat)
    loader.write_bench_results(get_path(FileType.BENCH_REWRITE_PERF,
                        app, data_dir, include_eq), rewrites)

def main():
    clize.run(benchmark)
    
if __name__ == "__main__":
    main()
