import traceback
import random
random.seed(0)

import rule
from loader import Loader
from rewriter import Rewriter
from evaluator import Evaluator
from ProveVerifier import ProveVerifier
from TestVerifier import TestVerifier
from mo_sql_parsing import format
from tqdm import tqdm
import time
from utils import exp_recorder, get_str_hash

from config import CONNECT_MAP, FileType, get_filename

if __name__ == '__main__':
    appname = "redmine"
    constraint_filename = get_filename(FileType.CONSTRAINT, appname)
    query_filename = get_filename(FileType.RAW_QUERY, appname)
    offset = 0
    query_cnt = 10000
    rules = [rule.RemovePredicate, rule.RemoveDistinct, rule.RewriteNullPredicate,
             rule.AddLimitOne, rule.RemoveJoin, rule.ReplaceOuterJoin]
    rules = [rule.RewriteNullPredicate]
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
    rewrite_faster_cnt = 0
    rewrite_slower_cnt = 0
    for q in tqdm(queries):
        start = time.time()
        try:
            rewritten_queries = rewriter.rewrite(constraints, q)
        except:
            print("[Error rewrite]", q.q_raw)
            print(traceback.format_exc())
            continue
        rewrite_time.append(time.time() - start)
        candidate_cnt.append(len(rewritten_queries))
        if len(rewritten_queries) == 0:
            continue
        print('[Org]', q.q_raw)
        for rq in rewritten_queries:
            print("[Rewrite]", rq.q_raw)

        print("============Start Test ==================")
        # use tests to check equivalence
        param_verified_queries = TestVerifier().verify(appname, q, constraints, rewritten_queries)
        # for rq in param_verified_queries:
        #     print("[Param Rewrite]", rq.q_raw)
         
        if len(param_verified_queries) == 0 or q.q_raw_param is None:
            continue
        
        if only_rewrite:
            continue
        
        rewrite_cnt += 1
        total_candidate_cnt += len(rewritten_queries)
        total_verified_cnt += len(param_verified_queries)
        print("%d All candidates %d, verified candidates %d" % 
                (rewrite_cnt, len(rewritten_queries), len(param_verified_queries)))
        
        print("============Start Prove==================")
        # TODO: verify rewritten queries
        # verified_queries = ProveVerifier().verify(appname, q, constraints, rewritten_queries)
        verified_queries = rewritten_queries
        
        print("===========Start Evaluate Cost==============")
        # evaluate query performance
        org_cost = Evaluator.evaluate_cost(q.q_raw_param, CONNECT_MAP[appname])
        # print("org", q.q_raw_param, org_cost)
        min_cost = org_cost
        best_q = None
        for vq in param_verified_queries:
            cost = Evaluator.evaluate_cost(vq.q_raw_param, CONNECT_MAP[appname])
            # print(vq.q_raw_param, cost)
            if cost < min_cost:
                min_cost, best_q = cost, vq

        if min_cost < org_cost:
            rewrite_faster_cnt += 1
            exp_recorder.record("id",  get_str_hash(q.q_raw))
            exp_recorder.record("org_cost", org_cost)
            exp_recorder.record("min_cost", min_cost)
            exp_recorder.record("rules", list(set([r.get_name() for r in best_q.rewrites])))
            exp_recorder.record("candidate_cnt", len(param_verified_queries))
            exp_recorder.record("org_q", q.q_raw_param)
            exp_recorder.record("rewrite_q", best_q.q_raw_param)
            exp_recorder.record("template",  q.q_raw)
            exp_recorder.dump(get_filename(FileType.REWRITE, appname))
        else:
            rewrite_slower_cnt += 1
    
        if best_q is not None:
            print("Org q %s, org cost %f" % (q.q_raw_param, org_cost))
            print("Best q %s, best cost %f" % (best_q.q_raw_param, min_cost))

    print("Rewrite Number %d" % rewrite_cnt)
    print("Rewrite Faster Number %d" % rewrite_faster_cnt)
    print("Rewrite Slower Number %d" % rewrite_slower_cnt)
    print("Total candidate cnt %d" % total_candidate_cnt)
    print("Total verified cnt %d" % total_verified_cnt)
    # exp_recorder.record("rules", [str(r.__name__) for r in rules])
    # exp_recorder.record("rewrite_time", rewrite_time)
    # exp_recorder.record("candidate_cnt", candidate_cnt)
    # exp_recorder.dump("log/time_info")
