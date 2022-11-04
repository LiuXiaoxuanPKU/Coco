import argparse
from shared import Stage
from loader import read_bench_results
import pandas as pd
import seaborn as sns
import numpy as np

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--app", required=True)
    parser.add_argument("--exclude_eq", default=False, action="store_true")
    args = parser.parse_args()
    rewrites = read_bench_results(args.app)
    rewrites = [(np.median(rw.timer[Stage.BASE]), np.median(rw.timer[Stage.REWRITE]), np.median(rw.timer[Stage.CONSTRAINT]), np.median(rw.timer[Stage.CONSTRAINT_REWRITE])) for rw in rewrites]
    ratios = [{
        "constraint": 1 - constraint / base,
        "rewrite": 1 - rewrite / base,
        "rewrite_constraint": 1 - constraint_rewrite / base
    } for base, rewrite, constraint, constraint_rewrite in rewrites]
    ratios = pd.DataFrame(ratios)
    ratios = ratios.applymap(lambda n: max(min(n, 1), -1))
    p = sns.displot(ratios, kde=True)
    p.savefig("performance.pdf")
    