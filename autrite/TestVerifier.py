from evaluator import Evaluator
from utils import generate_query_params

class TestVerifier:
    def __init__(self) -> None:
        pass

    def get_connect_str(self, appname):
        connect_map = {
            "redmine" : "user=redmine password=my_password"
        }
        return connect_map[appname]

    def verify(self, appname, q, constraints, rewritten_queries, out_dir):
        def test_equivalence(r1, r2):
            if len(r1) != len(r2):
                return False

            r1_sort = sorted(r1, lambda x: x[0])
            r2_sort = sorted(r2, lambda x: x[0])
            for e1, e2 in zip(r1_sort, r2_sort):
                if e1 != e2:
                    return False
            return True

        connect_str = self.get_connect_str(appname)
        q = generate_query_params([q])[0]
        org_result = Evaluator.evaluate_query(q, connect_str)
        
        eq_qs = []
        rewritten_queries = generate_query_params(rewritten_queries)
        for rq in rewritten_queries:
            rq_result = Evaluator.evaluate_query(rq, connect_str)
            if test_equivalence(org_result, rq_result):
                eq_qs.append(rq)
        return eq_qs




