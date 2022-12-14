import traceback
from shared import Stage, EvalQuery

from tqdm import tqdm
import clize
import loader
from constraint import Constraint, NumericalConstraint, PresenceConstraint, UniqueConstraint
from evaluator import Evaluator
from config import CONNECT_MAP, get_path, FileType
from funcy import keep


def collect(data_dir: str, app: str):
    include_eq = True
    rewrites = loader.read_rewrites(
        get_path(FileType.REWRITE_META, app, data_dir, include_eq),
        get_path(FileType.REWRITTEN_QUERY, app, data_dir, include_eq),
        include_eq
    )
    print(f"Collect {len(rewrites)} provable rewrites.")

def main():
    clize.run(collect)
    
if __name__ == "__main__":
    main()
