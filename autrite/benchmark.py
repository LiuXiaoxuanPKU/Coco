import os.path
import json

from fileinput import filename
from loader import Loader
from evaluator import Evaluator
import numpy as np
from utils import exp_recorder, generate_query_params
from config import CONNECT_MAP

def get_rewrite_perf(appname):
    rewrite_file = "log/%s_test_rewrite" % appname
    if not os.path.isfile(rewrite_file):
        print("[Error] Please first generate rewrite")
    with open(rewrite_file, "r") as f:
        lines = f.readlines()
        
    connect_str = CONNECT_MAP[appname]
    for line in lines:
        obj = json.loads(line)
        org_q, rewrite_q = obj["org_q"], obj["rewrite_q"]
        org_exec_t = Evaluator.evaluate_actual_time(org_q, connect_str)
        rewrite_exec_t = Evaluator.evaluate_actual_time(rewrite_q, connect_str)
        exp_recorder.record("id", obj["id"])
        exp_recorder.record("org_cost", obj["org_cost"])
        exp_recorder.record("rewrite_cost", obj["min_cost"])
        exp_recorder.record("org_t", org_exec_t)
        exp_recorder.record("rewrite_t", rewrite_exec_t)
        exp_recorder.record("org_q", org_q)
        exp_recorder.record("rewrite_q", rewrite_q)
        exp_recorder.dump("log/%s_exec_time" % (appname))


def get_slow_queries(appname, queries, ratio):
    ts = []
    for q in queries:
        if len(q) < 5:
            ts.append(-1)
            continue
        try:
            ts.append(Evaluator.evaluate_actual_time(q, connect_string=CONNECT_MAP[appname]))
        except:
            print("[Fail to execute]", q)
            ts.append(-1)
    ts_array = np.array(ts)
    percentile_t = np.percentile(ts_array[ts_array>0], (1 - ratio)*100)
    slow_queries = []
    slow_ts = []
    for i, t in enumerate(ts):
        if t > percentile_t:
            slow_queries.append(queries[i])
            slow_ts.append(t)
    return slow_queries, slow_ts


if __name__ == "__main__":
    appname = "redmine"
    bench_slow_queries = False
    bench_rewrite_perf = True
    
    if bench_slow_queries:
        filename = "../queries/redmine.pk"
        queries = Loader.load_queries_raw(filename, cnt=1000)
        queries = generate_query_params(queries, CONNECT_STRING)
        slow_queries, slow_ts = get_slow_queries(queries, 0.1)
        
        for q,t in zip(slow_queries, slow_ts):
            exp_recorder.record("time(ms)", t)
            exp_recorder.record("queries", q)
            exp_recorder.dump("logs/slow_queries")
            
    if bench_rewrite_perf:
        get_rewrite_perf(appname)