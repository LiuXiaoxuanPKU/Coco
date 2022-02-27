import traceback
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

from config import CONNECT_MAP, FileType, get_filename, RewriteQuery

if __name__ == '__main__':
    appname = "redmine"
    constraint_filename = get_filename(FileType.CONSTRAINT, appname)
    query_filename = get_filename(FileType.RAW_QUERY, appname)
    # query_filename = "../queries/redmine/redmine_remove_predicate.sql"
    offset = 0
    query_cnt = 10000
    # rules = [rule.RemovePredicate, rule.RemoveDistinct, rule.RewriteNullPredicate,
    #          rule.AddLimitOne, rule.RemoveJoin, rule.AddPredicate]
    rules = [rule.RemovePredicate, rule.RewriteNullPredicate, rule.AddPredicate]

    constraints = Loader.load_constraints(constraint_filename)
    queries = Loader.load_queries(query_filename, offset, query_cnt)
    queries = [RewriteQuery(q) for q in queries]
    rewriter = Rewriter()
    rewriter.set_rules(rules)

    rewrite_time = []
    candidate_cnt = []
    rewrite_cnt = 0
    total_candidate_cnt = 0
    total_verified_cnt = 0
    only_rewrite = False
    for i,q in tqdm(enumerate(queries)):
        start = time.time()
        try:
            rewritten_queries = rewriter.rewrite(constraints, q)
        except:
            print("[Error rewrite]", format(q.q))
            print(traceback.format_exc())
            continue
        rewrite_time.append(time.time() - start)
        candidate_cnt.append(len(rewritten_queries))
        if len(rewritten_queries) == 0:
            continue
        
        print("============Start Test ==================")
        # use tests to check equivalence
        param_verified_queries = TestVerifier().verify(appname, q, constraints, rewritten_queries)
        
        if len(param_verified_queries) == 0 or q.sql_param is None:
            continue
        
        if only_rewrite:
            continue
        
        rewrite_cnt += 1
        total_candidate_cnt += len(rewritten_queries)
        total_verified_cnt += len(param_verified_queries)
        print("%d All candidates %d, verified candidates %d" % 
                (rewrite_cnt, len(rewritten_queries), len(param_verified_queries)))
        
        
        # print("============Start Prove==================")
        # # TODO: verify rewritten queries
        # verified_queries = ProveVerifier().verify(appname, param_q, constraints, param_verified_queries)

        print("===========Start Evaluate Cost==============")
        # evaluate query performance
        org_cost = Evaluator.evaluate_cost(q.sql_param, CONNECT_MAP[appname])
        min_cost = org_cost
        best_q = None
        for vq in param_verified_queries:
            cost = Evaluator.evaluate_cost(vq.sql_param, CONNECT_MAP[appname])
            if cost < min_cost:
                min_cost, best_q = cost, vq

        if min_cost < org_cost:
            exp_recorder.record("id",  get_str_hash(format(q.q)))
            exp_recorder.record("org_cost", org_cost)
            exp_recorder.record("min_cost", min_cost)
            exp_recorder.record("rules", list(set([r.get_name() for r in best_q.rewrites])))
            exp_recorder.record("org_q", q.sql_param)
            exp_recorder.record("rewrite_q", best_q.sql_param)
            exp_recorder.record("template",  format(q.q))
            exp_recorder.dump(get_filename(FileType.REWRITE, appname))
    
        if best_q is not None:
            print("Org q %s, org cost %f" % (q.sql_param, org_cost))
            print("Best q %s, best cost %f" % (best_q.sql_param, min_cost))
        

    print("Rewrite Number %d" % rewrite_cnt)
    print("Total candidate cnt %d" % total_candidate_cnt)
    print("Total verified cnt %d" % total_verified_cnt)
    # exp_recorder.record("rules", [str(r.__name__) for r in rules])
    # exp_recorder.record("rewrite_time", rewrite_time)
    # exp_recorder.record("candidate_cnt", candidate_cnt)
    # exp_recorder.dump("log/time_info")
