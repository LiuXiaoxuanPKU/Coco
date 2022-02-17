
from loader import Loader
from rewriter import Rewriter
import rule
from evaluator import Evaluator
from verifier import Verifier
from mo_sql_parsing import parse, format
from tqdm import tqdm
import time
from utils import exp_recorder

if __name__ == '__main__':
    appname = "redmine"
    constraint_filename = "../constraints/%s" % appname
    query_filename = "../queries/%s.sql" % appname 
    query_cnt = 1000
    rules = [rule.AddPredicate]

    constraints = Loader.load_constraints(constraint_filename)
    queries = Loader.load_queries(query_filename, query_cnt)
    rewriter = Rewriter()
    rewriter.set_rules(rules)

    rewrite_time = []
    candidate_cnt = []
    for q in tqdm(queries):
        start = time.time()
        rewritten_queries = rewriter.rewrite(constraints, q)
        rewrite_time.append(time.time() - start)
        candidate_cnt.append(len(rewritten_queries))
        if len(rewritten_queries) == 0:
            continue
        
        # TODO: verify rewritten queries
        verified_queries = Verifier().verify(appname, q, constraints, rewritten_queries)

        # # evaluate query performance
        # org_cost = Evaluator.evaluate(q)
        # min_cost = org_cost
        # best_q = q
        # for vq in verified_queries:
        #     cost = Evaluator.evaluate(vq)
        #     if cost < min_cost:
        #         min_cost, best_q = cost, vq

        # print("Org q %s, org cost %d" % (format(q), org_cost))
        # print("Best q %s, best cost %d" % (format(best_q), min_cost))

    exp_recorder.record("rules", [str(r.__name__) for r in rules])
    exp_recorder.record("rewrite_time", rewrite_time)
    exp_recorder.record("candidate_cnt", candidate_cnt)
    exp_recorder.dump("log/time_info")
