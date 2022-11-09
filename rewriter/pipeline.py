import os
import traceback
import argparse
import pickle
import operator
from pathlib import Path

import rule
from loader import Loader
from rewriter import Rewriter
from evaluator import Evaluator
from Provedumper import ProveDumper
from TestVerifier import TestVerifier
from mo_sql_parsing import format, parse
from tqdm import tqdm
import time
from utils import exp_recorder, generate_query_param_rewrites, generate_query_param_single, get_sqlobj_table

from config import CONNECT_MAP, FileType, RewriteQuery, get_filename

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--app', default='redmine')
    parser.add_argument('--db', action='store_true', \
            help='only use db constraints to perform optimization')
    parser.add_argument('--only_rewrite', action='store_true', default=False, help='only rewrite queries based on constraints,\
                         does not run any tests, do not have communication with the database')
    parser.add_argument('--cnt', type=int, default=100000, help='number of queries to rewrite')
    parser.add_argument('--include_eq',  action='store_true', default=False,  help='when filtering rewrites, include rewrites, \
                        with the same cost as the original sql' )
    args = parser.parse_args()
    
    projectdir = Path(__file__).parent.parent.absolute()
    datadir = os.path.join(projectdir, "data")
    
    appname =  args.app
    query_filename = get_filename(FileType.RAW_QUERY, appname) 
    constraint_filename = get_filename(FileType.CONSTRAINT, appname)
    rules = [rule.RemovePredicate, rule.RemoveDistinct, rule.RewriteNullPredicate,
             rule.RemoveJoin, rule.ReplaceOuterJoin, rule.AddLimitOne]
    constraints = Loader.load_constraints(constraint_filename)
    if args.db:
        print("========Only use DB constraints to perform optimization======")
        print("[Before filtering DB constraints] ", len(constraints))
        constraints = [c for c in constraints if c.db == True]
        print("[After filtering DB constraints] ", len(constraints))
    
    offset = 0
    query_cnt = args.cnt
    queries = Loader.load_queries(query_filename, offset, query_cnt)
    rewriter = Rewriter()
    rewriter.set_rules(rules)
 
    used_tables = []
    if args.only_rewrite:
        enumerate_cnts = []
        enumerate_times = []
        for q in tqdm(queries):
            start = time.time()
            # =================Enumerate Candidates================
            enumerate_queries = []
            try:
                enumerate_queries = rewriter.rewrite(constraints, q)
            except:
                print("[Error rewrite]", q.q_raw)
                print(traceback.format_exc())
                continue
            if len(enumerate_queries) == 0:
                continue
            enumerate_cnts.append(len(enumerate_queries))
            end = time.time()
            enumerate_time = end-start
            enumerate_times.append(enumerate_time)
            start = end 
            used_tables += get_sqlobj_table(q.q_obj)

        with open(get_filename(FileType.ENUMERATE_CNT, appname), "wb") as f:
            pickle.dump(enumerate_cnts, f)
        with open(get_filename(FileType.ENUMERATE_TIME, appname), "wb") as f:
            pickle.dump(enumerate_times, f)
    else:
        rewrite_cnt = 0
        total_candidate_cnt = []

        enumerate_cnt = 0
        lower_cost_cnt = 0
        lower_cost_pass_test_cnt = 0 
        
        enumerate_time = 0
        get_cost_time = 0
        run_test_time = 0
        connect_str = CONNECT_MAP[appname]
        # create rewrite result dir if not exists
        Path(get_filename(FileType.ENUMERATE_ROOT, appname)).mkdir(parents=True, exist_ok=True)
        for q in tqdm(queries):
            with open(get_filename(FileType.REWRITE_STATS, appname), "w+") as f:
                f.write("%d, %d, %d" % (enumerate_cnt, lower_cost_cnt, lower_cost_pass_test_cnt))
            start = time.time()
            # =================Enumerate Candidates================
            enumerate_queries = []
            try:
                enumerate_queries = rewriter.rewrite(constraints, q)
            except:
                # print("[Error rewrite]", q.q_raw)
                # print(traceback.format_exc())
                continue
            if len(enumerate_queries) == 0:
                continue
            end = time.time()
            enumerate_time = end - start
            start = end
            enumerate_cnt += 1  

            # =================Try to generate param first========
            try:
                q_raw = generate_query_param_single(q.q_raw, connect_str, {})
                Evaluator.evaluate_query(q_raw, connect_str)
            except:
                continue 
            
            # ======== Estimate cost and retain those with lower cost than original ======
            rewritten_queries_lower_cost = []
            if args.include_eq:
                cmp_op = operator.le
            else:
                cmp_op = operator.lt
            
            # replace placeholder with actual parameters for org and rewrites
            rewritten_queries = enumerate_queries
            succ = generate_query_param_rewrites(q, rewritten_queries, connect_str)
            if not succ:
                continue
            # remove rewrites that fail to generate parameters
            rewritten_queries = [rq for rq in rewritten_queries if rq.q_raw_param is not None]
            if len(rewritten_queries) == 0:
                continue
            # retain rewrites with lower cost
            try:
                org_cost = Evaluator.evaluate_cost(q.q_raw_param, connect_str)
                q.estimate_cost = org_cost
            except:
                print("[Error] Fail to evaluate %s" % q.q_raw_param)
                continue
            
            for rq in rewritten_queries:
                try:
                    estimate_cost = Evaluator.evaluate_cost(rq.q_raw_param, connect_str) 
                    if cmp_op(estimate_cost, org_cost):
                        rq.estimate_cost = estimate_cost 
                        rewritten_queries_lower_cost.append(rq)
                    else:
                        pass
                        # print("[Warning] rewrite get slower")
                        # print("[Org] %f %s" % (org_cost, q.q_raw_param))
                        # print("[Rewrite] %f %s" % (estimate_cost, rq.q_raw_param))
                except:
                    # rewrite might have wrong syntax
                    continue
            if len(rewritten_queries_lower_cost) == 0:
                continue
            lower_cost_cnt += 1
    
            end = time.time()
            get_cost_time = end - start
            start = end
            
            # ======== Run test and retain those that pass =========
            rewritten_queries_lower_cost_after_test = []
            not_eq_qs = []
            # use tests to check equivalence
            rewritten_queries_lower_cost_after_test, not_eq_qs = TestVerifier().verify(appname, q, constraints, rewritten_queries_lower_cost)
            
            if len(rewritten_queries_lower_cost_after_test) == 0:
                continue
            lower_cost_pass_test_cnt += 1
        
            end = time.time()
            run_test_time = end - start
            exp_recorder.record("enumerate", enumerate_time)
            exp_recorder.record("get_cost", get_cost_time)
            exp_recorder.record("test", run_test_time)
            # exp_recorder.dump(get_filename(FileType.REWRITE_TIME, appname))
            
            # ========= Sort rewrites that pass tests ============
            # Sort the list in place
            rewritten_queries_lower_cost_after_test.sort(key=lambda x: x.estimate_cost, reverse=False)
            
            # ========== Dump outputs to cosette ==========
            rewrite_cnt += 1
            total_candidate_cnt.append(len(rewritten_queries_lower_cost_after_test))
            ProveDumper.dump_param_rewrite(appname, q, rewritten_queries_lower_cost_after_test, rewrite_cnt, args.include_eq)
            ProveDumper.dump_metadaba(appname, q, rewritten_queries_lower_cost_after_test, rewrite_cnt, args.include_eq)