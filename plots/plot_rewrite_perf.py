import argparse
import seaborn as sns
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from typing import List
from os.path import dirname, abspath, join
import sys
sys.path.append(join(dirname(dirname(abspath(__file__))), "rewriter/src/"))
from shared import EvalQuery, Stage
from config import RewriteType, FileType, get_path
from loader import read_bench_results


suffix = "pdf"

APP_NAME = {
    "redmine": "Redmine",
    "forem": "Dev.to",
    "openproject": "OpenProject",
    "mastodon": "Mastodon",
    "spree": "Spree",
    "openstreetmap": "Openstreetmap"
}

STAGE_NAME = {
    Stage.CONSTRAINT: "install constraints",
    Stage.REWRITE: "rewrite",
    Stage.CONSTRAINT_REWRITE: "install constraints + rewrite"
}

tick_size = 14
label_size = 16


def get_type(q):
    before, after = q.before, q.after
    types = []
    if before.lower().count("limit") != after.lower().count("limit"):
        types.append(RewriteType.AddLimitOne.value)
    if before.lower().count("distinct") != after.lower().count("distinct"):
        types.append(RewriteType.RemoveDistinct.value)
    if before.lower().count("join") != after.lower().count("join"):
        types.append(RewriteType.RemoveJoin.value)
    if before.lower().count(">") != after.lower().count(">") or \
       before.lower().count("=") != after.lower().count("=") or \
       before.lower().count(">=") != after.lower().count(">=") or \
       before.lower().count("<") != after.lower().count("<") or \
       before.lower().count("<=") != after.lower().count("<="):
           types.append(RewriteType.RemovePredicate.value)
    if before.lower().count("inner") != after.lower().count("inner"):
        types.append(RewriteType.ReplaceOuterJoin.value)
    if before.lower().count("null") != after.lower().count("null"):
        types.append(RewriteType.RewriteNullPredicate.value)
        
    if len(types) > 1:
        return "MIX"
    return types[0]

# def get_type(q):
#     if len(q.rewrite_types) > 1:
#         # print(q.rewrite_types)
#         # print(q.timer)
#         return "MIX"
#     return RewriteType[q.rewrite_types[0]].value

def group_by(queries: List[EvalQuery], group_boundaries: List[float]):
    def find_group(sp):
        for i, v in enumerate(group_boundaries):
            if sp >= v and ((i == len(group_boundaries) - 1) or sp < group_boundaries[i+1]):
                return v
        assert (False)

    speedups = []
    types = []
    groups = []
    sqls = []
    rewrite_types = []
    slowdown_type_qs = {}
    speedup_type_qs = {}

    for q in queries:
        for stage in [Stage.CONSTRAINT, Stage.REWRITE, Stage.CONSTRAINT_REWRITE]:
            speedup = q.timer[Stage.BASE][0] / q.timer[stage][0]
            speedups.append(speedup)
            sqls.append(q.before)
            groups.append(find_group(speedup))
            rewrite_type = get_type(q)
            rewrite_types.append(rewrite_type)
            types.append(STAGE_NAME[stage])

            if stage == Stage.CONSTRAINT_REWRITE and speedup <= 0.95:
                if rewrite_type not in slowdown_type_qs:
                    slowdown_type_qs[rewrite_type] = []
                slowdown_type_qs[rewrite_type].append(speedup)

            if stage == Stage.CONSTRAINT_REWRITE and speedup >= 1.05:
                if rewrite_type not in speedup_type_qs:
                    speedup_type_qs[rewrite_type] = []
                speedup_type_qs[rewrite_type].append(speedup)

    for t in slowdown_type_qs:
        print(t, np.median(slowdown_type_qs[t]))
    for t in speedup_type_qs:
        print(t, np.median(speedup_type_qs[t]))

    return pd.DataFrame({"sp": speedups, "type": types, "group": groups, "sql": sqls, "rewrite_type": rewrite_types})


def plot_speedup(data: List[EvalQuery], appname: str, interval: int, output_dir: str):
    f, ax = plt.subplots()
    group_boundaries = [0, 1-interval/100.0, 1+interval/100.0, 1.1, 2]
    data = group_by(queries, group_boundaries)
    p = sns.catplot(x="group", y=None,
                    hue_order=["install constraints", "rewrite",
                               "install constraints + rewrite"],
                    order=group_boundaries,
                    hue="type", data=data,
                    kind="count",
                    legend=False,
                    height=3, aspect=6/3)

    plt.xticks([0, 1, 2, 3, 4], ["slowdown", '0$\pm$' +
               str(interval) + '%', "<10%", "10~100%", ">100%"], size=tick_size)
    plt.yticks(fontsize=tick_size)
    plt.legend(prop={'size': 12})
    # plt.legend(loc='upper right', prop={'size': 11})
    if appname in ["redmine", "mastodon"]:
        plt.ylabel("Number of queries", size=label_size)
    else:
        plt.ylabel("")
    if appname == "openproject":
        plt.yticks([0, 150, 300, 450, 600])
    plt.xlabel("",  size=label_size)
    plt.title(APP_NAME[appname], pad=0, size=18)
    plt.tight_layout()
    plt.savefig(f"{output_dir}/figures/{appname}_perf.{suffix}", bbox_inches='tight')


def plot_rewrite_type(data: List[EvalQuery], appname: str, output_dir: str):
    f, ax = plt.subplots()
    group_boundaries = [0, 1, 1.1, 2]
    data = group_by(queries, group_boundaries)
    data = data[data["sql"] != "none"]
    data = data[data["type"] != "install constraints"]
    p = sns.catplot(x="rewrite_type", y="sp", ci=75, capsize=.1,
                    order=["AL", "ES", "PI/E", "JI/E", "RD", "MIX"],
                    hue="type", kind="bar", data=data,
                    legend=False,
                    height=3, aspect=6/3,  # estimator=median,
                    palette={"rewrite": "#ff7f0e", "install constraints + rewrite": "#2ca02c"})
    plt.ylabel("")
    plt.xlabel("", size=label_size)
    plt.yticks(fontsize=tick_size)
    plt.xticks(fontsize=tick_size)
    plt.legend(prop={'size': 11})
    if appname == "openproject":
        plt.yscale("log", base=10)
    #    plt.ylim(0,1300)
    if appname == "redmine":
        plt.ylabel("Average Speedup", size=label_size)
        # plt.yticks([0, 1, 2, 3, 4, 5, 6])
    elif appname == "mastodon":
        plt.ylabel("Average Speedup", size=label_size)
    elif appname == "forem":
        plt.yticks([0, 3, 6, 9, 12, 15])
    else:
        plt.ylabel("")
    plt.grid(axis='y', color='grey')
    plt.title(APP_NAME[appname], pad=0, size=18)
    plt.tight_layout()
    plt.savefig(f"{output_dir}/figures/{appname}_type_perf.{suffix}", bbox_inches='tight')

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--app', type=str, default='openproject')
    parser.add_argument('--data_dir', type=str, default='data')
    parser.add_argument('--interval', default=5, type=int)
    args = parser.parse_args()

    filename = get_path(FileType.BENCH_REWRITE_PERF, args.app, args.data_dir)
    queries = read_bench_results(filename)
    print(len(queries))
    for q in queries:
        print(q.before)
        print(q.after)
        print(q.rewrite_types)
    plot_speedup(queries, args.app, args.interval, args.data_dir)
    plot_rewrite_type(queries, args.app, args.data_dir)
