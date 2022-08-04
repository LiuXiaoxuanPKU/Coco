from ast import arg
import json
import sys, os
from time import time
import traceback

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from evaluator import Evaluator
from loader import Loader
from utils import exp_recorder
from config import CONNECT_MAP, get_filename, FileType
import matplotlib.pyplot as plt
from bench_utils import install_constraints, roll_back
import argparse
import seaborn as sns
import numpy as np
class EvalQuery:
    def __init__(self, before_sql, after_sql) -> None:
        self.raw = before_sql
        self.rewrite = after_sql
        self.t_db = 0
        self.t_rewrite = 0
        self.t_db_constraint = 0
        self.t_rewrite_constraint = 0
     
def dump_results(queries, app):
    filename = "log/%s_perf" % app
    exp_recorder.clear(filename)
    for q in queries:
        exp_recorder.record("raw", q.raw) 
        exp_recorder.record("rewrite", q.rewrite) 
        exp_recorder.record("t_db", q.t_db) 
        exp_recorder.record("t_rewrite", q.t_rewrite) 
        exp_recorder.record("t_db_constraint", q.t_db_constraint) 
        exp_recorder.record("t_rewrite_constraint", q.t_rewrite_constraint) 
        exp_recorder.dump(filename)

def load_results(app):
    filename = "log/%s_cost_perf" % app
    queries = []
    with open(filename, 'r') as f:
        lines = f.readlines()
    for l in lines:
        obj = json.loads(l)
        q = EvalQuery(obj["raw"], obj["rewrite"])
        q.t_db, q.t_rewrite, q.t_db_constraint, q.t_rewrite_constraint = \
            obj['t_db'], obj['t_rewrite'], obj['t_db_constraint'], obj['t_rewrite_constraint'] 
        queries.append(q)
    return queries

def parse_result(APP):
    folder = "log/{}/cosette".format(APP)
    output = open("{}/verifier-result".format(folder), "r")
    out_file = "{}/result.sql".format(folder)
    exp_recorder.clear(out_file)
    first = False
    for line in output:
        file, num = line.split(":")
        with open("{}/eq_unique/{}.sql".format(folder, file)) as q:
            found = False
            for q_line in q:
                if first:
                    exp_recorder.record("before", q_line)
                    first = False
                if found:
                    num -= 1
                    if num == 0:
                        exp_recorder.record("after", q_line)
                        exp_recorder.dump(out_file)
                        break
                if 'Original Query' in q_line:
                    first = True
                if 'Rewritten Queries' in q_line:
                    found = True
                    num = int(num)

    output.close()
  
def load_queries(app):
    folder = "log/{}/cosette".format(app)
    out_file = "{}/result.sql".format(folder) 
    with open(out_file, 'r') as f:
        lines = f.readlines()
    queries = []
    for line in lines:
        obj = json.loads(line)
        queries.append(EvalQuery(obj['before'], obj['after']))
    return queries

def eval_queries(queries, connect_str, stage):
    repeat = 30
    times = {}
        
    for t in range(repeat):
        for i, q in enumerate(queries):
            try:
                if i not in times:
                    times[i] = []
                if stage in ["org", "db_constraint"]:
                    # Evaluator.evaluate_query("set jit=off", connect_str)
                    times[i].append(Evaluator.evaluate_actual_time(q.raw, connect_str))
                elif stage in ["rewrite", "rewrite_constraint"]:
                    # Evaluator.evaluate_query("set jit=off", connect_str)
                    times[i].append(Evaluator.evaluate_actual_time(q.rewrite, connect_str))
                else:
                    assert(False)
            except:
                print(traceback.format_exc())
    
    for i, t in enumerate(times):
        avg_time = np.median(times[i][1:i])
        if stage == "org":
            queries[i].t_db = avg_time
        elif stage == "rewrite":
            queries[i].t_rewrite = avg_time
        elif stage == "db_constraint":
            queries[i].t_db_constraint = avg_time
        elif stage == "rewrite_constraint":
            queries[i].t_rewrite_constraint = avg_time
        else:
            print(traceback.format_exc())
            exit(0)
    return queries 
 
    
def plot_speedup(queries, appname):
    f, axes = plt.subplots(3, 1)
    f.set_size_inches(8, 6)
    rewrite = {}
    rewrite['org+rewrite'] = [q.t_db / (q.t_rewrite + 1e-5) for q in queries]
    rewrite['constraint+db'] = [q.t_db / (q.t_db_constraint + 1e-5) for q in queries]
    rewrite['constraint+rewrite'] = [q.t_db / (q.t_rewrite_constraint + 1e-5) for q in queries]
    
    for i, q in enumerate(queries):
        if q.t_db / (q.t_rewrite + 1e-5) > 10:
            print("raw", q.raw)
            print("rewrite", q.rewrite)
            print("org rewrite", q.t_db / (q.t_rewrite + 1e-5))
            print("constraint db", q.t_db / (q.t_db_constraint + 1e-5))
            print("constraint rewrite", q.t_db / (q.t_rewrite_constraint + 1e-5))
             
    def print_big(l):
        for i in range(len(l)):
            if l[i] > 10:
                print(l[i])
    print("org+rewrite")
    print_big(rewrite["org+rewrite"]) 
    print("constraint+db")
    print_big(rewrite["constraint+db"]) 
    print("constraint+rewrite")
    print_big(rewrite["constraint+rewrite"])
    rewrite["org+rewrite"] = [x for x in rewrite["org+rewrite"] if x < 20 and x > 0]
    rewrite["constraint+db"] = [x for x in rewrite["constraint+db"] if x < 20 and x > 0]
    rewrite["constraint+rewrite"] = [x for x in rewrite["constraint+rewrite"] if x < 20 and x > 0]
    cnt1 = len([r for r in rewrite["constraint+rewrite"] if r >0 and r < 1])
    cnt2 = len([r for r in rewrite["constraint+rewrite"] if r >1 and r < 1.2])
    cnt3 = len([r for r in rewrite["constraint+rewrite"] if r >1.2 and r < 10])
    print("===========", cnt1, cnt2, cnt3)
    cnt1 = len([r for r in rewrite["constraint+db"] if r >0 and r < 1])
    cnt2 = len([r for r in rewrite["constraint+db"] if r >1 and r < 1.2])
    cnt3 = len([r for r in rewrite["constraint+db"] if r >1.2 and r < 10])
    print("===========", cnt1, cnt2, cnt3)
    
    print("Start plot")
    print(rewrite)
    sns.histplot(data=rewrite, x = "org+rewrite", bins=5000, kde=False, ax=axes[0], label = "No constraints,rewrite")
    sns.histplot(data=rewrite, x = "constraint+db", bins=5000, kde=False, ax=axes[1], label = "Add constraints, no rewrites")
    sns.histplot(data=rewrite, x = "constraint+rewrite", bins=5000, kde=False, ax=axes[2], label = "Add constraints, rewrites")
    for i in range(len(axes)):
        axes[i].legend(prop={'size': 12})
        axes[i].tick_params(axis='both', which='major', labelsize=10)
        axes[i].set_ylabel("Count", size=15)
        axes[i].set_xlim(0.95,2)
        # axes[i].set_xscale('symlog')
        # if appname == "openproject":
        axes[i].set_yscale('symlog')
    axes[2].set_xlabel("Speed Up", size=15)
    axes[0].set_title(appname, size = 18)
    
    plt.savefig('/home/ubuntu/ConstrOpt/figures/7.4/%s_cost_perf' % appname)
     
           
if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--app', default='redmine')
    parser.add_argument('--eval', action='store_true')
    args = parser.parse_args()
    
    if args.eval:
        parse_result(args.app) 
        queries = load_queries(args.app)
        print("=======Org======")
        eval_queries(queries, CONNECT_MAP[args.app], "org")
        queries = [q for q in queries if q.t_db is not None]
        print("=======Rewrite======")
        eval_queries(queries, CONNECT_MAP[args.app], "rewrite")
        
        constraint_file = get_filename(FileType.CONSTRAINT, args.app)
        constraints = Loader.load_constraints(constraint_file)
        constraints = [c for c in constraints if c.db is False]
        installed = install_constraints(constraints, args.app)
        print("=======DB Constriant======")
        eval_queries(queries, CONNECT_MAP[args.app], "db_constraint")
        print("=======Rewrite Constraint======")
        eval_queries(queries, CONNECT_MAP[args.app], "rewrite_constraint")
        roll_back(installed, args.app)
        dump_results(queries, args.app)

    # queries =  load_results(args.app)
    # plot_speedup(queries, args.app)
    
    