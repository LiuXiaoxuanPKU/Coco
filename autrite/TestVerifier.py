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

    def verify(self, appname, q, constraints, rewritten_queries, show_progress=False):
        connect_str = self.get_connect_str(appname)
        cache = {}
        q.q_raw_param = generate_query_param_single(q.q_raw, connect_str, cache)
        if q.q_raw_param is None:
            print("[Fail] generate param")
            return []
        
        try:
            org_result = Evaluator.evaluate_query(q.q_raw_param, connect_str)
        except:
            # print("Fail to execute %s" % format(q))
            return []
        
        eq_qs = []
        if show_progress:
            iter = tqdm(rewritten_queries)
        else:
            iter = rewritten_queries
        for rq in iter:
            rq.q_raw_param = generate_query_param_single(rq.q_raw, connect_str, cache)
            if rq.q_raw_param is None:
                continue
            try:
                # rewrite might be wrong, so we need try except error here
                rq_result = Evaluator.evaluate_query(rq.q_raw_param, connect_str)
                if test_query_result_equivalence(org_result, rq_result):
                    eq_qs.append(rq)
            except:
                # print("Fail to execute %s" % format(rq))
                pass
        return eq_qs




