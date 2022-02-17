from cmath import exp
import random

from fileinput import filename
from loader import Loader
from evaluator import Evaluator
import numpy as np
from utils import exp_recorder

CONNECT_STRING = "user=redmine password=my_password dbname=redmine_develop"

def generate_query_params(queries):
    def get_field_value(table_field):
        if table_field.startswith("LOWER"):
            table_field = table_field[6:-1]
        table, field = table_field.split('.')
        SQL = "SELECT %s FROM %s ORDER BY RANDOM() LIMIT 1" % (table_field, table)
        ret =  Evaluator.evaluate_query(SQL, CONNECT_STRING)
        return ret

    def generate_single(q):
        if '$' not in q:
            return q
        tokens = q.split(" ")
        for i, token in enumerate(tokens):
            if '$' in token:
                if tokens[i-1] == "LIMIT":
                    tokens[i] = str(random.randint(0, 10))
                elif tokens[i-1] == "OFFSET":
                    tokens[i] = "1"
                elif tokens[i-1] in ["=", '!=', '>', '<']:
                    re = get_field_value(tokens[i-2])
                    if len(re) == 0 or re[0][0] is None:
                        return None
                    tokens[i] = re[0][0]
                    if isinstance(tokens[i], str):
                        tokens[i] = "'" + tokens[i] + "'"
                    else:
                        tokens[i] = str(tokens[i])
                elif tokens[i-1] == "IN":
                    end_idx = i
                    while ")" not in tokens[end_idx]:
                        end_idx += 1
                    for j in range(i, end_idx + 1):
                        re = get_field_value(tokens[i-2])
                        if len(re) == 0 or re[0][0] is None:
                            return None
                        tokens[j] = re[0][0]
                        if isinstance(tokens[j], str):
                            tokens[j] = "'" + tokens[j] + "'"
                        else:
                            tokens[j] = str(tokens[j])
                        tokens[j] += ","
                    tokens[i] = "(" + tokens[i]
                    tokens[end_idx] =  tokens[end_idx][:-1] + ")"
        q = " ".join(tokens)
        return q

    param_qs = []
    for q in queries:
        q_param = generate_single(q)
        if q_param is not None:
            param_qs.append(q_param)
    return param_qs

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
    queries = generate_query_params(queries)
    slow_queries, slow_ts = get_slow_queries(queries, 0.1)
    
    for q,t in zip(slow_queries, slow_ts):
        exp_recorder.record("time(ms)", t)
        exp_recorder.record("queries", q)
        exp_recorder.dump("log/slow_queries")