import json
import argparse
from enum import Enum
import pandas as pd

import seaborn as sns
import pandas as pd
import matplotlib.pyplot as plt
pd.set_option('display.max_colwidth', None)
import numpy as np
from numpy import median
from matplotlib.offsetbox import AnchoredText


suffix = "pdf"

rm_cnt = 0
sp_cnt = 0
install_sp_cnt = 0
APP_NAME = {
    "redmine" : "Redmine",
    "forem" : "Dev.to",
    "openproject" : "OpenProject",
    "mastodon": "Mastodon",
    "spree" : "Spree",
    "openstreetmap": "Openstreetmap"
}

tick_size = 14
label_size = 16   
class EvalQuery:
    def __init__(self, before_sql, after_sql) -> None:
        self.raw = before_sql
        self.rewrite = after_sql
        self.t_db = 0
        self.t_rewrite = 0
        self.t_db_constraint = 0
        self.t_rewrite_constraint = 0
        
        self.rewrite_types = []
    
class RewriteType(Enum):
    ADD_LIMIT_1 = 1
    REMOVE_DISTINCT = 2
    REMOVE_JOIN = 3
    PREDICATE = 4
    EMPTY_SET = 5
    CHANGE_JOIN = 6
    ERROR = 7

TYPE_TO_NAME = {
   RewriteType.ADD_LIMIT_1 : "AL",
   RewriteType.REMOVE_DISTINCT : "RD",
   RewriteType.REMOVE_JOIN : "JI/E",
   RewriteType.PREDICATE : "PI/E",
   RewriteType.EMPTY_SET : "ES",
   RewriteType.CHANGE_JOIN : "JI/E",
   RewriteType.ERROR: "Error"
}

def load_sql(idx, dir):
    file, rewrite_id = [int(i) for i in idx.split(':')]
    file = "%s/%d.json" % (dir, file)
    with open(file, 'r') as f:
        obj = json.load(f)
    before = obj['org']['sql']
    after_obj = obj['rewrites'][rewrite_id-1]
    return before, after_obj['sql'], after_obj['rewrite_types']

def load_results_csv(result_dir, sql_dir):
    data = pd.read_csv(result_dir)
    data = data.groupby(["run"]).mean()
    queries = []
    for index, row in data.iterrows():
        before, after, rewrite_type = load_sql(index, sql_dir)
        q = EvalQuery(before, after)
        q.t_db, q.t_rewrite, q.t_db_constraint, q.t_rewrite_constraint = \
            row['base'], row['rewrite'], row['constraint'], row['rewrite_constraint']
        queries.append(q)
    return queries
  
def load_results(app: str) -> list[EvalQuery]:
    filename = "log/perf_leq/%s_perf" % app
    queries = []
    with open(filename, 'r') as f:
        lines = f.readlines()
    for l in lines:
        if l.startswith("#"):
            continue
        obj = json.loads(l)
        q = EvalQuery(obj["raw"], obj["rewrite"])
        q.t_db, q.t_rewrite, q.t_db_constraint, q.t_rewrite_constraint = \
            obj['t_db'], obj['t_rewrite'], obj['t_db_constraint'], obj['t_rewrite_constraint'] 
        queries.append(q)
    return queries

def get_type(before, after):
    types = []
    if before.lower().count("limit") != after.lower().count("limit"):
        types.append(RewriteType.ADD_LIMIT_1)
    if before.lower().count("distinct") != after.lower().count("distinct"):
        types.append(RewriteType.REMOVE_DISTINCT)
    if before.lower().count("join") != after.lower().count("join"):
        types.append(RewriteType.REMOVE_JOIN)
    if before.lower().count(">") != after.lower().count(">") or \
       before.lower().count("=") != after.lower().count("=") or \
       before.lower().count(">=") != after.lower().count(">=") or \
       before.lower().count("<") != after.lower().count("<") or \
       before.lower().count("<=") != after.lower().count("<="):
           types.append(RewriteType.PREDICATE)
    if before.lower().count("inner") != after.lower().count("inner"):
        types.append(RewriteType.CHANGE_JOIN)
    if before.lower().count("null") != after.lower().count("null"):
        types.append(RewriteType.EMPTY_SET)
    if len(types) == 0:
        print("[Error] Same rewrite!!!!============")
        print(before)
        print(after)
        print("=======================")
        types.append("ERROR")
        return types
        # assert(False)
        
    if len(types) > 1:
        types = [TYPE_TO_NAME[t] for t in types] 
        types.append("MIX")
        return types
    return [TYPE_TO_NAME[types[0]]]

def group_by(queries, gb, for_type = True):
    def find_group(sp):
        for i, v in enumerate(gb):
            if sp >= v and ((i == len(gb) - 1) or sp < gb[i+1]):
                return v
        assert(False)
        
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
    
    if for_type:
        for q in queries:
            db_sp = q.t_db / q.t_db_constraint
            if within_range(db_sp):
                types += ["install constraints"]
                speedups += [db_sp]
                sqls += [q.raw] 
                rewrite_types += [None]
                groups += [find_group(db_sp)]
                        
            rewrite_sp = q.t_db / q.t_rewrite
            if within_range(rewrite_sp):
                current_rewrite_type = get_type(q.raw, q.rewrite)
                for t in current_rewrite_type:
                    types += ["rewrite"]
                    speedups += [rewrite_sp]
                    sqls += [q.rewrite] 
                    rewrite_types += [t] 
                    groups += [find_group(rewrite_sp)]
                
            rewrite_constraint_sp = q.t_db / q.t_rewrite_constraint
            if within_range(rewrite_constraint_sp):
                current_rewrite_type = get_type(q.raw, q.rewrite)
                global rm_cnt
                if "RD" in current_rewrite_type:
                    rm_cnt += 1
                for t in current_rewrite_type:
                    types += ["install constraints + rewrite"]
                    speedups += [rewrite_constraint_sp]
                    sqls += [q.rewrite] 
                    rewrite_types += [t]  
                    groups += [find_group(rewrite_constraint_sp)]
    else:
        for q in queries:
            db_sp = q.t_db / q.t_db_constraint
            if db_sp > 2:
                global install_sp_cnt
                install_sp_cnt += 1
            t = get_type(q.raw, q.rewrite)
            if t[0] == 'JI/E':
                continue
            if t[0] is None:
                continue
            rewrite_sp = q.t_db / q.t_rewrite, 0.1
            if within_range(db_sp):
                types += ["install constraints"]
                speedups += [db_sp]
                sqls += [q.raw] 
                rewrite_types += [None]
                groups += [find_group(db_sp)]
                        
            rewrite_sp = q.t_db / q.t_rewrite
            if within_range(rewrite_sp):
                t = get_type(q.raw, q.rewrite)
                types += ["rewrite"]
                speedups += [rewrite_sp]
                sqls += [q.rewrite] 
                rewrite_types += [t[0]] 
                groups += [find_group(rewrite_sp)]
                
            rewrite_constraint_sp = q.t_db / q.t_rewrite_constraint
            if rewrite_constraint_sp >= 2:
                global sp_cnt
                sp_cnt += 1 
            if within_range(rewrite_constraint_sp):
                t = get_type(q.raw, q.rewrite)
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
                sqls += [q.rewrite] 
                rewrite_types += [t[0]]  
                groups += [find_group(rewrite_constraint_sp)]
        for t in slowdown_types:
            print(t, np.median(slowdown_types[t]))
        for t in speedup_types:
            print(t, np.median(speedup_types[t]))
    
    return pd.DataFrame({"sp":speedups, "type": types, "group" : groups, "sql":sqls, "rewrite_type":rewrite_types})

def plot_speedup(data, appname, bd):
    f, ax = plt.subplots()
    at = AnchoredText(
    APP_NAME[appname], prop=dict(size=18), frameon=False, loc='upper center')
    ax.add_artist(at)
    group_boundaries = [0, 1-bd/100.0, 1+bd/100.0, 1.1, 2]
    data = group_by(queries, group_boundaries, for_type=False)
    data = data[data['rewrite_type'] != 'JI/E']
    p = sns.catplot(x="group", y=None, 
                hue_order = ["install constraints", "rewrite", "install constraints + rewrite"],
                hue="type", data=data, 
                kind="count", 
                legend=False,
                height=3, aspect=6/3)

    plt.xticks([0, 1, 2, 3, 4], ["slowdown", '0$\pm$'+ str(bd) +'%', "<10%", "10~100%", ">100%"], size=tick_size)
    plt.yticks(fontsize=tick_size)
    # plt.yscale("log", base=2)
    plt.legend(prop={'size': 12})
    # plt.legend(loc='upper right', prop={'size': 11})
    if appname in ["redmine", "mastodon"]:
        # plt.yticks([0, 50, 100, 150, 200])
        plt.ylabel("Number of queries", size=label_size)
    else:
        plt.ylabel("")
    if appname == "openproject":
        plt.yticks([0, 150, 300, 450, 600])
    plt.xlabel("",  size=label_size)
    plt.title(APP_NAME[appname], pad=0, size=18) 
    plt.tight_layout()
    # plt.savefig('/home/ubuntu/ConstrOpt/figures/7.4/%s_perf.%s' % (appname, suffix), bbox_inches='tight')
    # plt.savefig('/home/ubuntu/ConstrOpt/figures/7.4/%s_perf.png' % (appname), bbox_inches='tight')
    data_r = data[data["type"] == "install constraints + rewrite"]
    data_s = data_r[data_r["group"] == 2]
    print(data_s.shape, data_r.shape, data_s["sp"].max())
    
def plot_rewrite_type(data, app):
    f, ax = plt.subplots()
    group_boundaries = [0, 1, 1.1, 2]
    data = group_by(queries, group_boundaries, for_type=True)
    data = data[data["sql"] != "none"]
    data = data[data["type"] != "install constraints"]
    p = sns.catplot(x="rewrite_type", y="sp", ci=75, capsize=.1,
                order=["AL", "ES", "PI/E", "JI/E", "RD", "MIX"],
                hue="type", kind="bar", data=data, 
                legend=False,
                height=3, aspect=6/3, # estimator=median,
                palette={"rewrite":"#ff7f0e", "install constraints + rewrite":"#2ca02c"})
    plt.ylabel("")
    plt.xlabel("", size=label_size)
    plt.yticks(fontsize=tick_size)
    plt.xticks(fontsize=tick_size)
    # plt.legend(loc='upper right', prop={'size': 11})
    plt.legend(prop={'size': 11})
    if app == "openproject":
       plt.yscale("log", base=10)
    #    plt.ylim(0,1300)
    if app == "redmine":
        plt.ylabel("Average Speedup", size=label_size)
        plt.yticks([0, 1, 2, 3, 4, 5, 6])
    elif app == "mastodon":
        plt.ylabel("Average Speedup", size=label_size)
    elif app == "forem":
        plt.yticks([0, 3, 6, 9, 12, 15])
    else:
        plt.ylabel("") 
    plt.grid(axis='y', color='grey')
    print("2.0 constropt sp", sp_cnt)
    print("2.0 db", install_sp_cnt)
    plt.title(APP_NAME[app], pad=0, size=18) 
    plt.tight_layout()
    # plt.savefig('/home/ubuntu/ConstrOpt/figures/7.4/%s_perf_rewrite_type.%s' % (app, suffix), )
    # plt.savefig('/home/ubuntu/ConstrOpt/figures/7.4/%s_perf_rewrite_type.png' % (app))
    
if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--app', default='openproject')
    parser.add_argument('--bd', default=5, type=int)
    args = parser.parse_args()
    bd = args.bd
    
    if args.app == "redmine":
        sql_dir = "/home/ubuntu/ConstrOpt/constropt/autrite/log/redmine/cosette/cost_less_eq_verify/metadata"
        result_dir = "/home/ubuntu/ConstrOpt/constropt/autrite/scripts/data.csv"
        queries = load_results_csv(result_dir, sql_dir)
    # elif args.app == "spree":
    #     sql_dir = "/home/ubuntu/ConstrOpt/constropt/autrite/log/spree/cosette/cost_less_eq/metadata"
    #     result_dir = "/home/ubuntu/ConstrOpt/constropt/autrite/scripts/spree-data.csv"
    #     queries = load_results_csv(result_dir, sql_dir)
    else:
        queries = load_results(args.app)
    plot_speedup(queries, args.app, bd)
    plot_rewrite_type(queries, args.app)
    
