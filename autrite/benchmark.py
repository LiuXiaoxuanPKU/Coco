from cmath import exp

from fileinput import filename
from loader import Loader
from evaluator import Evaluator
import numpy as np
from utils import exp_recorder, generate_query_params

CONNECT_STRING = "user=redmine password=my_password dbname=redmine_develop"

def get_slow_queries(queries, ratio):
    ts = []
    for q in queries:
        if len(q) < 5:
            ts.append(-1)
            continue
        try:
            ts.append(Evaluator.evaluate_actual_time(q, connect_string=CONNECT_STRING))
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
    filename = "../queries/redmine.pk"
    queries = Loader.load_queries_raw(filename, cnt=1000)
    queries = generate_query_params(queries, CONNECT_STRING)
    slow_queries, slow_ts = get_slow_queries(queries, 0.1)
    
    for q,t in zip(slow_queries, slow_ts):
        exp_recorder.record("time(ms)", t)
        exp_recorder.record("queries", q)
        exp_recorder.dump("logs/slow_queries")