from config import EvalQuery, get_filename, FileType, Stage, RewriteType
from matplotlib.offsetbox import AnchoredText
import json
import argparse
import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt
pd.set_option('display.max_colwidth', None)


suffix = "pdf"

rm_cnt = 0
sp_cnt = 0
install_sp_cnt = 0
APP_NAME = {
    "redmine": "Redmine",
    "forem": "Dev.to",
    "openproject": "OpenProject",
    "mastodon": "Mastodon",
    "spree": "Spree",
    "openstreetmap": "Openstreetmap"
}

tick_size = 14
label_size = 16

TYPE_TO_NAME = {
    RewriteType.AddLimitOne: "AL",
    RewriteType.RemoveDistinct: "RD",
    RewriteType.RemoveJoin: "JI/E",
    RewriteType.RemovePredicate: "PI/E",
    RewriteType.RewriteNullPredicate: "ES",
    RewriteType.ReplaceOuterJoin: "JI/E"
}


def load_results(app: str, datadir: str) -> list[EvalQuery]:
    filename = get_filename(FileType.BENCH_RESULT, app, datadir)
    queries = []
    with open(filename, 'r') as f:
        lines = f.readlines()
    for l in lines:
        queries.append(EvalQuery.from_json(json.loads(l)))
    return queries


def get_type(q):
    type_names = []
    for t in q.rewrite_types:
        type_names.append(TYPE_TO_NAME[RewriteType[t]])
    if len(q.rewrite_types) > 1:
        type_names.append("MIX")
    return type_names


def group_by(queries, gb):
    def find_group(sp):
        for i, v in enumerate(gb):
            if sp >= v and ((i == len(gb) - 1) or sp < gb[i+1]):
                return v
        assert (False)

    db_groups = {}
    rewrite_groups = {}
    rewrite_constraint_groups = {}
    for g in gb:
        db_groups[g] = []
        rewrite_groups[g] = []
        rewrite_constraint_groups[g] = []

    speedups = []
    types = []
    groups = []
    sqls = []
    rewrite_types = []
    slowdown_types = {}
    speedup_types = {}

    def within_range(c):
        return True
        return c < 0.95 or c > 1.05

    for q in queries:
        db_sp = q.timer[Stage.BASE] / q.timer[Stage.CONSTRAINT]
        if db_sp > 2:
            global install_sp_cnt
            install_sp_cnt += 1
        t = get_type(q)
        if t[0] == 'JI/E':
            continue
        if t[0] is None:
            continue

        rewrite_sp = q.timer[Stage.BASE] / q.timer[Stage.CONSTRAINT]
        if within_range(db_sp):
            types += ["install constraints"]
            speedups += [db_sp]
            sqls += [q.before]
            rewrite_types += [None]
            groups += [find_group(db_sp)]

        rewrite_sp = q.timer[Stage.BASE] / q.timer[Stage.REWRITE]
        if within_range(rewrite_sp):
            types += ["rewrite"]
            speedups += [rewrite_sp]
            sqls += [q.after]
            rewrite_types += [t[0]]
            groups += [find_group(rewrite_sp)]

        rewrite_constraint_sp = q.timer[Stage.BASE] / \
            q.timer[Stage.CONSTRAINT_REWRITE]
        if rewrite_constraint_sp >= 2:
            global sp_cnt
            sp_cnt += 1
        if within_range(rewrite_constraint_sp):
            if rewrite_constraint_sp <= 0.95:
                if t[0] not in slowdown_types:
                    slowdown_types[t[0]] = []
                slowdown_types[t[0]].append(rewrite_constraint_sp)
            if rewrite_constraint_sp >= 1.05:
                if t[0] not in speedup_types:
                    speedup_types[t[0]] = []
                speedup_types[t[0]].append(rewrite_constraint_sp)
            types += ["install constraints + rewrite"]
            speedups += [rewrite_constraint_sp]
            sqls += [q.after]
            rewrite_types += [t[0]]
            groups += [find_group(rewrite_constraint_sp)]
    for t in slowdown_types:
        print(t, np.median(slowdown_types[t]))
    for t in speedup_types:
        print(t, np.median(speedup_types[t]))

    return pd.DataFrame({"sp": speedups, "type": types, "group": groups, "sql": sqls, "rewrite_type": rewrite_types})


def plot_speedup(data, appname, datadir, bd):
    f, ax = plt.subplots()
    at = AnchoredText(
        APP_NAME[appname], prop=dict(size=18), frameon=False, loc='upper center')
    ax.add_artist(at)
    group_boundaries = [0, 1-bd/100.0, 1+bd/100.0, 1.1, 2]
    data = group_by(queries, group_boundaries)
    data = data[data['rewrite_type'] != 'JI/E']
    p = sns.catplot(x="group", y=None,
                    hue_order=["install constraints", "rewrite",
                               "install constraints + rewrite"],
                    hue="type", data=data,
                    kind="count",
                    legend=False,
                    height=3, aspect=6/3)

    plt.xticks([0, 1, 2, 3, 4], ["slowdown", '0$\pm$' + str(bd) +
               '%', "<10%", "10~100%", ">100%"], size=tick_size)
    plt.yticks(fontsize=tick_size)
    plt.legend(prop={'size': 12})
    if appname in ["redmine", "mastodon"]:
        plt.ylabel("Number of queries", size=label_size)
    else:
        plt.ylabel("")
    if appname == "openproject":
        plt.yticks([0, 150, 300, 450, 600])
    plt.xlabel("",  size=label_size)
    plt.title(APP_NAME[appname], pad=0, size=18)
    plt.tight_layout()
    plt.savefig(get_filename(FileType.GRAPH_REWRITE_PERF, appname, datadir), bbox_inches='tight')


def plot_rewrite_type(data, appname, datadir):
    def set_yticklabel(appname):
        if appname == "openproject":
            plt.yscale("log", base=10)
        #    plt.ylim(0,1300)
        if appname == "redmine":
            plt.ylabel("Average Speedup", size=label_size)
            plt.yticks([0, 1, 2, 3, 4, 5, 6])
        elif appname == "mastodon":
            plt.ylabel("Average Speedup", size=label_size)
        elif appname == "forem":
            plt.yticks([0, 3, 6, 9, 12, 15])
        else:
            plt.ylabel("")

    _, _ = plt.subplots()
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
    # set_yticklabel(appname)
    plt.legend(prop={'size': 11})
    plt.grid(axis='y', color='grey')
    print("2.0 constropt sp", sp_cnt)
    print("2.0 db", install_sp_cnt)
    plt.title(APP_NAME[appname], pad=0, size=18)
    plt.savefig(get_filename(FileType.GRAPH_TYPE_PERF, appname, datadir), bbox_inches='tight')


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--app', default='openproject')
    parser.add_argument('--data_dir')
    parser.add_argument('--bd', default=5, type=int)
    args = parser.parse_args()
    bd = args.bd

    queries = load_results(args.app, args.data_dir)
    plot_speedup(queries, args.app, args.data_dir, bd)
    plot_rewrite_type(queries, args.app, args.data_dir)
