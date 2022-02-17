import random

from fileinput import filename
from loader import Loader
from evaluator import Evaluator
import numpy as np

CONNECT_STRING = "user=redmine password=my_password"

def generate_query_params(queries):
    def get_field_value(table_field):
        table, field = table_field.split('.')
        SQL = "SELECT %s FROM %s ORDER BY RANDOM() LIMIT 1" % (table_field, table)
        return Evaluator.evaluate_query(SQL, CONNECT_STRING)

    def generate_single(q):
        if '$' not in q:
            return q
        tokens = q.split(" ")
        for i, token in enumerate(tokens):
            if '$' in token:
                if tokens[i-1] == "LIMIT":
                    tokens[i] = str(random.randint(0, 100))
                elif tokens[i-1] == "=":
                    re = get_field_value(tokens[i-2])
                    if len(re) == 0:
                        return None
                    tokens[i] = re[0]
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
        ts.append(Evaluator.evaluate_actual_time(q, connect_string=CONNECT_STRING))
    percentile_t = np.percentile(ts, 1-ratio)
    slow_queries = []
    slow_ts = []
    for i, t in enumerate(ts):
        if t > percentile_t:
            slow_queries.append(queries[i])
            slow_ts.append(t)
    return slow_queries, slow_ts


if __name__ == "__main__":
    filename = "../queries/redmine.sql"
    queries = Loader.load_queries_raw(filename, cnt=100)
    queries = generate_query_params(queries)
    get_slow_queries(queries, 0.1)