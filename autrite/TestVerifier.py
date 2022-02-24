from tqdm import tqdm
from evaluator import Evaluator
from utils import generate_query_params, test_query_result_equivalence
from mo_sql_parsing import format
from config import CONNECT_MAP

class TestVerifier:
    def __init__(self) -> None:
        pass

    def get_connect_str(self, appname):
        return CONNECT_MAP[appname]

    def verify(self, appname, q, constraints, rewritten_queries, out_dir):
        connect_str = self.get_connect_str(appname)
        cache = {}
        q = generate_query_params([format(q)], connect_str, cache)
        if len(q) == 0:
            return None, []
        q = q[0]
        param_q = q
        
        try:
            org_result = Evaluator.evaluate_query(q, connect_str)
        except:
            # print("Fail to execute %s" % format(q))
            return None, []
        
        eq_qs = []
        rewritten_sql = [format(q) for q in rewritten_queries]
        rewritten_sql = generate_query_params(rewritten_sql, connect_str, cache)
        for rq in tqdm(rewritten_sql):
            rq_result = Evaluator.evaluate_query(rq, connect_str)
            if test_query_result_equivalence(org_result, rq_result):
                eq_qs.append(rq)
        return param_q, eq_qs




