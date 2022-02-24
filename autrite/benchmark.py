import os.path
import json
import traceback
from rewriter import Rewriter

from loader import Loader
from evaluator import Evaluator
import numpy as np
from utils import exp_recorder, generate_query_params, test_query_result_equivalence
from config import CONNECT_MAP
import constraint
from mo_sql_parsing import parse

def get_rewrite_pg(appname):
    def filter_queries(queries, constraints):
        q_with_constraints = []
        def extract_q_field(q):
            # TODO: extract all the fields insteaf of all the tokens
            tokens = [t.lower().split('.')[-1] for t in q.split(' ')]
            return tokens

        def get_field_constraint(field, constraints):
            field_constraints = []
            for c in constraints:
                if c.field == field:
                    field_constraints.append(c)
            return field_constraints

        for q in queries:
            # extract fields in q
            fields = extract_q_field(q)
            has_c = False
            for field in fields:
                cs = get_field_constraint(field, constraints)
                if len(cs) > 0:
                    has_c = True
                    break
            if has_c:
                q_with_constraints.append(q)
                
        return q_with_constraints
        
    def get_query_plans(queries):
        results = []
        for q in queries:
            try:
                plan = Evaluator.evaluate_query("EXPLAIN " + q, CONNECT_MAP[appname])
                cost = Evaluator.evaluate_cost(q, CONNECT_MAP[appname])
                time = Evaluator.evaluate_actual_time(q, CONNECT_MAP[appname])
                results.append((cost, time, plan))
            except Exception as e:
                print(traceback.format_exc())
                results.append(None)
        return results
    
    def clean_constraints(constraints):
        # constraints = constraints[0:5]
        for c in constraints:
            if c.table is None:
                continue
            if type(c) in [constraint.UniqueConstraint, constraint.NumericalConstraint]:
                constraint_name = str(c)
                drop_sql = "ALTER TABLE %s DROP CONSTRAINT IF EXISTS %s;" %(c.table, constraint_name)
                Evaluator.evaluate_query(drop_sql, CONNECT_MAP[appname])
            elif type(c) in [constraint.PresenceConstraint]:
                constraint_name = str(c)
                drop_sql = "ALTER TABLE %s ALTER COLUMN %s DROP NOT NULL;" %(c.table, c.field)
                try:
                    Evaluator.evaluate_query(drop_sql, CONNECT_MAP[appname])
                except: # column might not exist
                    pass
                       
    def install_constraints(constraints):
        installed_constraints = []
        for c in constraints:
            if c.table is None:
                continue
            elif isinstance(c, constraint.UniqueConstraint):
                constraint_name = str(c)
                roll_back_info = (c, constraint_name)
                fields = [c.field] + c.scope
                fields = ', '.join(fields)
                install_sql = "ALTER TABLE %s ADD CONSTRAINT %s UNIQUE (%s);" % (c.table, constraint_name, fields)
            elif isinstance(c, constraint.PresenceConstraint):
                constraint_name = str(c)
                roll_back_info = (c, constraint_name)
                install_sql = "ALTER TABLE %s ALTER COLUMN %s SET NOT NULL;" % (c.table, c.field)
            elif isinstance(c, constraint.NumericalConstraint):
                constraint_name = str(c)
                roll_back_info = (c, constraint_name)
                if c.min is not None and c.max is None:
                    install_sql = "ALTER TABLE {} ADD CONSTRAINT {} CHECK ({} > {});".format(
                        c.table, constraint_name, c.field, c.min)
                elif c.min is None and c.max is not None:
                    install_sql = "ALTER TABLE {} ADD CONSTRAINT {} CHECK ({} < {});".format(
                        c.table, constraint_name, c.field, c.max)
                else:
                    install_sql = "ALTER TABLE {} ADD CONSTRAINT {} CHECK ({} > {} AND {} < {});".format(
                        c.table, constraint_name, c.field, c.min, c.field, c.max)
            
            try:
                Evaluator.evaluate_query(install_sql, CONNECT_MAP[appname])
                installed_constraints.append(roll_back_info)
            except Exception as e:
                print(traceback.format_exc())
        print("Install constraints success/all: %d/%d" % (len(installed_constraints), len(constraints)))
        return installed_constraints            

    # does not catch exception here, roll back shoud succeed
    def roll_back(installed_constraints):
        for roll_back_info in installed_constraints:
            c, constraint_name = roll_back_info
            if type(c) in [constraint.NumericalConstraint, constraint.UniqueConstraint]:
                drop_sql = "ALTER TABLE %s DROP CONSTRAINT IF EXISTS %s;" % (c.table, constraint_name)
            elif type(c) in [constraint.PresenceConstraint]:
                drop_sql = "ALTER TABLE %s ALTER COLUMN %s DROP NOT NULL;" %(c.table, c.field)
            Evaluator.evaluate_query(drop_sql, CONNECT_MAP[appname])
    
    def dump_rewrite(queries, old_plans, new_plans):
        rewrite_cnt = 0
        for i, (old, new) in enumerate(zip(old_plans, new_plans)):
            if old is None or new is None:
                continue
            old_cost, old_time, old_plan = old
            new_cost, new_time, new_plan = new
            eq = test_query_result_equivalence(old_plan, new_plan)
            if not eq:
                rewrite_cnt += 1
                exp_recorder.record("id", hash(queries[i]))
                exp_recorder.record("before_t", old_time)
                exp_recorder.record("before_cost", old_cost)
                exp_recorder.record("after_t", new_time)
                exp_recorder.record("after_cost", new_cost)
                exp_recorder.record("query", queries[i])
                exp_recorder.record("before_plan", old_plan)
                exp_recorder.record("after_plan", new_plan)
                exp_recorder.dump("log/%s_pg_rewrite_info" % (appname))
                

    query_file = "../queries/%s/%s.pk" % (appname.split("_")[0], appname.split("_")[0])
    queries = Loader.load_queries_raw(query_file, offset=1000, cnt=2000)
    constraint_file = "../constraints/%s" % (appname.split("_")[0])
    constraints = Loader.load_constraints(constraint_file)
    queries = filter_queries(queries, constraints)
    queries = generate_query_params(queries, CONNECT_MAP[appname], {})
    
    clean_constraints(constraints)
    org_plans = get_query_plans(queries)
    installed_constraints = install_constraints(constraints)
    new_plans = get_query_plans(queries)
    roll_back(installed_constraints)
    dump_rewrite(queries, org_plans, new_plans)
    
    

def get_rewrite_perf(appname):
    rewrite_file = "log/%s_test_rewrite" % appname
    if not os.path.isfile(rewrite_file):
        print("[Error] Please first generate rewrite")
    with open(rewrite_file, "r") as f:
        lines = f.readlines()
        
    connect_str = CONNECT_MAP[appname]
    for line in lines:
        obj = json.loads(line)
        org_q, rewrite_q = obj["org_q"], obj["rewrite_q"]
        org_exec_t = Evaluator.evaluate_actual_time(org_q, connect_str)
        rewrite_exec_t = Evaluator.evaluate_actual_time(rewrite_q, connect_str)
        exp_recorder.record("id", obj["id"])
        exp_recorder.record("org_cost", obj["org_cost"])
        exp_recorder.record("rewrite_cost", obj["min_cost"])
        exp_recorder.record("org_t", org_exec_t)
        exp_recorder.record("rewrite_t", rewrite_exec_t)
        exp_recorder.record("org_q", org_q)
        exp_recorder.record("rewrite_q", rewrite_q)
        exp_recorder.dump("log/%s_exec_time" % (appname))


def get_slow_queries(appname, queries, ratio):
    ts = []
    for q in queries:
        if len(q) < 5:
            ts.append(-1)
            continue
        try:
            ts.append(Evaluator.evaluate_actual_time(q, connect_string=CONNECT_MAP[appname]))
        except:
            print("[Fail to execute]", q)
            ts.append(-1)
    ts_array = np.array(ts)
    percentile_t = np.percentile(ts_array[ts_array>0], (1 - ratio)*100)
    slow_queries = []
    slow_ts = []
    for i, t in enumerate(ts):
        if t > percentile_t:
            slow_queries.append(queries[i])
            slow_ts.append(t)
    return slow_queries, slow_ts


if __name__ == "__main__":
    appname = "redmine"
    bench_pg = True
    bench_slow_queries = False
    bench_rewrite_perf = False
    
    if bench_pg:
        # get_rewrite_pg(appname + "_test")
        get_rewrite_pg(appname)
        
    if bench_slow_queries:
        filename = "../queries/redmine.pk"
        queries = Loader.load_queries_raw(filename, cnt=1000)
        queries = generate_query_params(queries, CONNECT_MAP[appname])
        slow_queries, slow_ts = get_slow_queries(queries, 0.1)
        
        for q,t in zip(slow_queries, slow_ts):
            exp_recorder.record("time(ms)", t)
            exp_recorder.record("queries", q)
            exp_recorder.dump("logs/slow_queries")
            
    if bench_rewrite_perf:
        get_rewrite_perf(appname)