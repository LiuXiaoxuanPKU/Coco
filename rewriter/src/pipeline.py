import clize
import traceback
import pickle
import operator

import rule
import loader
from rewriter import Rewriter
from evaluator import Evaluator
from prove_dumper import ProveDumper
from test_verifier import TestVerifier
from tqdm import tqdm
import time
from utils import exp_recorder, generate_query_param_rewrites, generate_query_param_single, get_sqlobj_table
from config import CONNECT_MAP, FileType, get_path
from prover import prove

def rewrite(data_dir: str, app: str, *, db: bool = False, only_rewrite: bool = False, cnt: int = 100000, include_eq: bool = False):
    """ConstrOpt rewriter

    Args:
        :param data_dir: Root directory for storing intermediate and final results.
        :param app: Name of app to be processed.
        :param db: Only use db constraints to perform optimization.
        :param only_rewrite: Only rewrite queries based on constraints, without running any tests, or having communication with the database.
        :param cnt: Number of queries to rewrite.
        :param include_eq: When filtering rewrites, include rewrites with the same cost as the original sql
    """
    rules = [rule.RemovePredicate, rule.RemoveDistinct, rule.RewriteNullPredicate,
             rule.RemoveJoin, rule.ReplaceOuterJoin, rule.AddLimitOne]
    constraint_file = get_path(FileType.CONSTRAINT, app, data_dir)
    constraints = loader.read_constraints(constraint_file, include_all=False)
    if db:
        print("========Only use DB constraints to perform optimization======")
        print("[Before filtering DB constraints] ", len(constraints))
        constraints = [c for c in constraints if c.db == True]
        print("[After filtering DB constraints] ", len(constraints))

    queries = loader.read_queries(get_path(FileType.RAW_QUERY, app, data_dir), 0, cnt)
    rewriter = Rewriter()
    rewriter.set_rules(rules)
    used_tables = []
    if only_rewrite:
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
            enumerate_times.append(end - start)
            start = end 
            used_tables += get_sqlobj_table(q.q_obj)

        with open(get_path(FileType.ENUMERATE_CNT, app, data_dir), "wb") as f:
            pickle.dump(enumerate_cnts, f)
        with open(get_path(FileType.ENUMERATE_TIME, app, data_dir), "wb") as f:
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
        connect_str = CONNECT_MAP[app]
        for q in tqdm(queries):
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
            if include_eq:
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
            # use tests to check equivalence
            rewritten_queries_lower_cost_after_test, not_eq_qs = TestVerifier().verify(app, q, constraints, rewritten_queries_lower_cost)
            
            if len(rewritten_queries_lower_cost_after_test) == 0:
                continue
            lower_cost_pass_test_cnt += 1
        
            end = time.time()
            run_test_time = end - start
            exp_recorder.record("enumerate", enumerate_time)
            exp_recorder.record("get_cost", get_cost_time)
            exp_recorder.record("test", run_test_time)
            # exp_recorder.dump(get_filename(FileType.REWRITE_TIME, app))
            
            # ========= Sort rewrites that pass tests ============
            # Sort the list in place
            rewritten_queries_lower_cost_after_test.sort(key=lambda x: x.estimate_cost, reverse=False)
            
            # ========== Dump outputs to cosette ==========
            rewrite_cnt += 1
            total_candidate_cnt.append(len(rewritten_queries_lower_cost_after_test))
            ProveDumper.dump_param_rewrite(app, q, rewritten_queries_lower_cost_after_test, rewrite_cnt, include_eq, data_dir)
            ProveDumper.dump_metadata(app, q, rewritten_queries_lower_cost_after_test, rewrite_cnt, include_eq, data_dir)
    stats_file = get_path(FileType.REWRITE_STATS, app, data_dir)
    stats_file.parent.mkdir(parents=True, exist_ok=True)
    stats_file.write_text(f"{enumerate_cnt}, {lower_cost_cnt}, {lower_cost_pass_test_cnt}")
    
    print("========  Running prover  ========")
    prove(get_path(FileType.REWRITTEN_QUERY, app, data_dir), constraint_file)

def main():
    clize.run(rewrite)

if __name__ == "__main__":
    main()