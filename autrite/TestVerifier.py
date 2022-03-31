from tqdm import tqdm
from evaluator import Evaluator
from utils import generate_query_param_single, test_query_result_equivalence
from mo_sql_parsing import format
from config import CONNECT_MAP, RewriteQuery

class TestVerifier:
    def __init__(self) -> None:
        pass

    def get_connect_str(self, appname):
        return CONNECT_MAP[appname]

    def verify(self, appname, q, constraints, rewritten_queries):
        connect_str = self.get_connect_str(appname)
        cache = {}
        q.sql_param = generate_query_param_single(format(q.q), connect_str, cache)
        if q.sql_param is None:
            return []
        
        try:
            org_result = Evaluator.evaluate_query(q.sql_param, connect_str)
        except:
            # print("Fail to execute %s" % format(q))
            return []
        
        eq_qs = []
        for rq in rewritten_queries:        
            rq.sql_param = generate_query_param_single(format(rq.q), connect_str, cache)
            
        for rq in tqdm(rewritten_queries):
            if rq.sql_param is None:
                continue
            rq_result = Evaluator.evaluate_query(rq.sql_param, connect_str)
            if test_query_result_equivalence(org_result, rq_result):
                eq_qs.append(rq)
        return eq_qs




