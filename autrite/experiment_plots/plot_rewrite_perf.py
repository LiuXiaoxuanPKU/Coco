import json
import argparse
from enum import Enum
from struct import pack

import seaborn as sns
import pandas as pd
import matplotlib.pyplot as plt
pd.set_option('display.max_colwidth', None)
import numpy as np
from numpy import median
from matplotlib.offsetbox import AnchoredText

parser = argparse.ArgumentParser()
parser.add_argument('--app', default='openproject')
args = parser.parse_args()
suffix = "png"

rm_cnt = 0
sp_cnt = 0
APP_NAME = {
    "redmine" : "Redmine",
    "forem" : "Dev.to",
    "openproject" : "Openproject"
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
    
class RewriteType(Enum):
    ADD_LIMIT_1 = 1
    REMOVE_DISTINCT = 2
    REMOVE_JOIN = 3
    PREDICATE = 4
    EMPTY_SET = 5
    CHANGE_JOIN = 6

TYPE_TO_NAME = {
   RewriteType.ADD_LIMIT_1 : "AL",
   RewriteType.REMOVE_DISTINCT : "RD",
   RewriteType.REMOVE_JOIN : "JI/E",
   RewriteType.PREDICATE : "PI/E",
   RewriteType.EMPTY_SET : "ES",
   RewriteType.CHANGE_JOIN : "JI/E"
}      
def load_results(app):
    filename = "log/%s_perf" % app
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
        print(before)
        print(after)
        assert(False)
    if len(types) > 1:
        types = [TYPE_TO_NAME[t] for t in types] 
        types.append("MIX")
        return types
    return [TYPE_TO_NAME[types[0]]]

def group_by(queries, gb, for_type = True):
    def find_group(sp):
        # if sp < 0.9:
        #     print(sp)
        for i, v in enumerate(gb):
            if sp >= v and ((i == len(gb) - 1) or sp < gb[i+1]):
                return v
        return -1
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
                
            # if db_sp > rewrite_constraint_sp and rewrite_constraint_sp < 0.95:
            #     print(db_sp, rewrite_constraint_sp)
            #     print(q.raw)
            #     print(q.rewrite)
            #     print("")
    else:
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
                t = get_type(q.raw, q.rewrite)
                types += ["rewrite"]
                speedups += [rewrite_sp]
                sqls += [q.rewrite] 
                rewrite_types += [t[0]] 
                groups += [find_group(rewrite_sp)]
                
            rewrite_constraint_sp = q.t_db / q.t_rewrite_constraint
            if rewrite_constraint_sp >= 1.5:
                global sp_cnt
                sp_cnt += 1 
            if within_range(rewrite_constraint_sp):
                t = get_type(q.raw, q.rewrite)
                types += ["install constraints + rewrite"]
                speedups += [rewrite_constraint_sp]
                sqls += [q.rewrite] 
                rewrite_types += [t[0]]  
                groups += [find_group(rewrite_constraint_sp)]
            if rewrite_constraint_sp < 0.95:
                print("db", db_sp, q.raw)
                print("rewrite", rewrite_sp, q.rewrite)
                print("cons + rewrite", rewrite_constraint_sp)
                print(db_sp, find_group(db_sp))
    
    return pd.DataFrame({"sp":speedups, "type": types, "group" : groups, "sql":sqls, "rewrite_type":rewrite_types})

def plot_speedup(data, appname):
    f, ax = plt.subplots()
    at = AnchoredText(
    APP_NAME[appname], prop=dict(size=18), frameon=False, loc='upper center')
    ax.add_artist(at)
    group_boundaries = [0.95, 1.05, 1.1, 2]
    data = group_by(queries, group_boundaries, for_type=False)
    # data = data[data["group"] != -1]
    # print(data)
    # print(data[data['group'] == 2])
    p = sns.catplot(x="group", y=None, 
                hue_order = ["install constraints", "rewrite", "install constraints + rewrite"],
                hue="type", data=data, 
                kind="count", legend=False,
                height=3, aspect=6/3)

    plt.xticks([0, 1, 2, 3, 4], ["slowdown", '0$\pm$5%', "<10%", "10~100%", ">100%"], size=tick_size)
    plt.yticks(fontsize=tick_size)
    # plt.yscale("log", base=2)
    # plt.legend(loc='upper left', prop={'size': 12})
    if appname == "redmine":
        plt.yticks([0, 20, 40, 60])
        plt.ylabel("Number of queries", size=label_size)
    else:
        plt.ylabel("")
    if appname == "openproject":
        plt.yticks([0, 150, 300, 450, 600])
    plt.xlabel("",  size=label_size)
    # at = AnchoredText(
    # APP_NAME[appname], prop=dict(size=18), frameon=False, loc='upper center', pad=0)
    # p.ax.add_artist(at)
    plt.title(APP_NAME[appname], pad=0, size=18) 
    plt.tight_layout()
    plt.savefig('/home/ubuntu/ConstrOpt/figures/7.4/%s_perf.%s' % (appname, suffix), bbox_inches='tight')
    data_r = data[data["type"] == "install constraints + rewrite"]
    data_s = data_r[data_r["group"] == 2]
    print(data_s.shape, data_r.shape, data_s["sp"].max())
    
def plot_rewrite_type(data, app):
    f, ax = plt.subplots()
    group_boundaries = [1, 1.1, 2]
    data = group_by(queries, group_boundaries, for_type=True)
    # data = data[data["group"] != -1]
    data = data[data["sql"] != "none"]
    data = data[data["type"] != "install constraints"]
    p = sns.catplot(x="rewrite_type", y="sp", ci=75, capsize=.1,
                order=["AL", "ES", "PI/E", "JI/E", "RD", "MIX"],
                hue="type", kind="bar", data=data, legend=False,
                height=3, aspect=6/3, # estimator=median,
                palette={"rewrite":"#ff7f0e", "install constraints + rewrite":"#2ca02c"})
    plt.ylabel("")
    plt.xlabel("", size=label_size)
    plt.yticks(fontsize=tick_size)
    plt.xticks(fontsize=tick_size)
    if app == "openproject":
       plt.yscale("log", base=10)
    #    plt.ylim(0,1300)
    if app == "redmine":
        plt.ylabel("Average Speedup", size=label_size)
        plt.yticks([0, 1, 2, 3, 4, 5, 6])
    else:
        plt.ylabel("") 
    plt.grid(axis='y', color='grey')
    # at = AnchoredText(
    # APP_NAME[app], prop=dict(size=18), frameon=False, loc='lower center', pad=0,
    # bbox_to_anchor=(0., 1.), bbox_transform=p.ax.transAxes)
    #print(data["rewrite_type"])
    #data_s = data[(data["rewrite_type"] == "RD") & (data["type"] == "install constraints + rewrite")]
    print("1.5 sp", sp_cnt)
    plt.title(APP_NAME[app], pad=0, size=18) 
    plt.tight_layout()
    plt.savefig('/home/ubuntu/ConstrOpt/figures/7.4/%s_perf_rewrite_type.%s' % (app, suffix), )
    
if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--app', default='openproject')
    args = parser.parse_args()
    
    queries = load_results(args.app)
    plot_speedup(queries, args.app)
    plot_rewrite_type(queries, args.app)
    
