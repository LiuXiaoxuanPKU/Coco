
import rule
from loader import Loader
from rewriter import Rewriter
from evaluator import Evaluator
from ProveVerifier import ProveVerifier
from TestVerifier import TestVerifier
from mo_sql_parsing import parse, format
from tqdm import tqdm
import time
from utils import exp_recorder, generate_query_params
from multiprocessing import Pool

from config import CONNECT_MAP

if __name__ == '__main__':
    appname = "redmine"
    constraint_filename = "../constraints/%s" % appname
    query_filename = "../queries/%s/%s.pk" % (appname, appname)
    out_dir = "app_create_sql/provable/remove_predicate"
    offset = 3692 + 450
    query_cnt = 10000
    rules = [rule.RemovePredicate, rule.RemoveDistinct, rule.AddLimitOne, rule.RemoveJoin, rule.AddPredicate]

    constraints = Loader.load_constraints(constraint_filename)
    queries = Loader.load_queries(query_filename, offset, query_cnt)
    rewriter = Rewriter()
    rewriter.set_rules(rules)

    rewrite_time = []
    candidate_cnt = []
    rewrite_cnt = 0
    total_candidate_cnt = 0
    total_verified_cnt = 0
    only_rewrite = False
    for q in tqdm(queries):
        start = time.time()
        try:
            rewritten_queries = rewriter.rewrite(constraints, q)
        except:
            print("[Error rewrite]", format(q))
            continue
        rewrite_time.append(time.time() - start)
        candidate_cnt.append(len(rewritten_queries))
        if len(rewritten_queries) == 0:
            continue
        
        print("============Start Verify==================")
        # use tests to check equivalence
        param_q, param_verified_queries = TestVerifier().verify(appname, q, constraints, rewritten_queries, out_dir)
        
        if len(param_verified_queries) == 0:
            continue
        
        if only_rewrite:
            continue
        rewrite_cnt += 1
        total_candidate_cnt += len(rewritten_queries)
        total_verified_cnt += len(param_verified_queries)
        print("%d All candidates %d, verified candidates %d" % (rewrite_cnt, len(rewritten_queries), len(param_verified_queries)))
        # if len(rewritten_queries) > 1 and len(verified_queries) * 1.0 / len(rewritten_queries) > 0.8:
        #     print("org")
        #     print(format(q))
        #     print("rewrite")
        #     for rq in rewritten_queries:
        #         print(format(rq))
        
        # TODO: verify rewritten queries
        # verified_queries = ProveVerifier().verify(appname, q, constraints, rewritten_queries, out_dir)

        print("===========Start Evaluate Cost==============")
        # evaluate query performance
        org_cost = Evaluator.evaluate_cost(param_q, CONNECT_MAP[appname])
        min_cost = org_cost
        best_q = q
        for vq in param_verified_queries:
            cost = Evaluator.evaluate_cost(vq, CONNECT_MAP[appname])
            if cost < min_cost:
                min_cost, best_q = cost, vq

        if min_cost < org_cost:
            exp_recorder.record("id", rewrite_cnt)
            exp_recorder.record("org_cost", org_cost)
            exp_recorder.record("min_cost", min_cost)
            exp_recorder.record("org_q", param_q)
            exp_recorder.record("rewrite_q", best_q)
            exp_recorder.dump("log/%s_test_rewrite" % appname)
    
        print("Org q %s, org cost %f" % (param_q, org_cost))
        print("Best q %s, best cost %f" % (best_q, min_cost))
        

    print("Rewrite Number %d" % rewrite_cnt)
    print("Total candidate cnt %d" % total_candidate_cnt)
    print("Total verified cnt %d" % total_verified_cnt)
    # exp_recorder.record("rules", [str(r.__name__) for r in rules])
    # exp_recorder.record("rewrite_time", rewrite_time)
    # exp_recorder.record("candidate_cnt", candidate_cnt)
    # exp_recorder.dump("log/time_info")
