import argparse
import matplotlib.pyplot as plt
from extract_rule import ExtractQueryRule
from utils import exp_recorder
from tqdm import tqdm
from mo_sql_parsing import format
import constraint
from config import CONNECT_MAP, FileType, get_filename
from utils import exp_recorder, generate_query_param_single, test_query_result_equivalence
from evaluator import Evaluator
from loader import Loader
import os.path
import traceback
import sys
import os

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))


# ------------------------------------------------------------------------------
# This script counts the number of queries and records the query performance before
# and after installing the constraints. The goal is to see if the db can leverage
# constraints to optimize query performance. The benchmark is performed in the
# following steps:
# 1. load queries, evaluate original query performance org_perf
# 2. load constraints, and install constraints into the database
# 3. evaluate the new query performance new_perf
# 4. test if org_perf and new_perf have the same query plan and compare the query performance
# ------------------------------------------------------------------------------

class EvalQuery:
    def __init__(self, rewrite_q, connect_str) -> None:
        assert(rewrite_q is not None)
        self.raw = generate_query_param_single(
            rewrite_q.q_raw, connect_str, {})
        self.q_obj = rewrite_q.q_obj
        self.before = None
        self.before_time = 0
        self.after = None
        self.after_time = 0


def filter_queries(queries, constraints):
    filtered_qs = []
    for q in queries:
        try:
            rewrite_q = ExtractQueryRule(constraints).apply(q.q_obj)
            if len(rewrite_q) == 1:
                filtered_qs.append(q)
            elif len(rewrite_q) > 0:
                pass
        except (KeyError, TypeError, AttributeError, ValueError):
            pass
    return filtered_qs


def clean_constraints(constraints):
    print("===========Clean constraints==============")
    for c in tqdm(constraints):
        if c.table is None:
            continue
        if type(c) in [constraint.UniqueConstraint, constraint.NumericalConstraint]:
            constraint_name = str(c)
            drop_sql = "ALTER TABLE %s DROP CONSTRAINT IF EXISTS %s;" % (
                c.table, constraint_name)
            Evaluator.evaluate_query(drop_sql, CONNECT_MAP[appname])
        elif type(c) in [constraint.PresenceConstraint]:
            constraint_name = str(c)
            drop_sql = "ALTER TABLE %s ALTER COLUMN %s DROP NOT NULL;" % (
                c.table, c.field)
            try:
                Evaluator.evaluate_query(drop_sql, CONNECT_MAP[appname])
            except:  # column might not exist
                pass


def install_constraints(constraints):
    installed_constraints = []
    print("=============Install constraints============")
    for c in tqdm(constraints):
        if c.table is None:
            continue
        elif isinstance(c, constraint.UniqueConstraint):
            if c.type == 'pk':
                continue
            constraint_name = str(c)
            roll_back_info = (c, constraint_name)
            fields = list(c.field)
            fields = ', '.join(fields)
            install_sql = "ALTER TABLE %s ADD CONSTRAINT %s UNIQUE (%s);" % (
                c.table, constraint_name, fields)
        elif isinstance(c, constraint.PresenceConstraint):
            constraint_name = str(c)
            roll_back_info = (c, constraint_name)
            install_sql = "ALTER TABLE %s ALTER COLUMN %s SET NOT NULL;" % (
                c.table, c.field)
        elif isinstance(c, constraint.NumericalConstraint):
            constraint_name = str(c)
            roll_back_info = (c, constraint_name)
            if c.min is not None and c.max is None:
                install_sql = "ALTER TABLE {} ADD CONSTRAINT {} CHECK ({} >= {});".format(
                    c.table, constraint_name, c.field, c.min)
            elif c.min is None and c.max is not None:
                install_sql = "ALTER TABLE {} ADD CONSTRAINT {} CHECK ({} <= {});".format(
                    c.table, constraint_name, c.field, c.max)
            else:
                install_sql = "ALTER TABLE {} ADD CONSTRAINT {} CHECK ({} >= {} AND {} <= {});".format(
                    c.table, constraint_name, c.field, c.min, c.field, c.max)
        else:
            continue
        try:
            Evaluator.evaluate_query("ALTER TABLE {} DROP CONSTRAINT IF EXISTS {}".format(
                c.table, constraint_name), CONNECT_MAP[appname])
            Evaluator.evaluate_query(install_sql, CONNECT_MAP[appname])
            installed_constraints.append(roll_back_info)
        except Exception as e:
            print(install_sql)
            print(traceback.format_exc())
            exit(0)
    print("Install constraints success/all: %d/%d" %
          (len(installed_constraints), len(constraints)))
    return installed_constraints

# does not catch exception here, roll back shoud succeed


def roll_back(installed_constraints):
    print("=============Rollback Constraint===============")
    for roll_back_info in installed_constraints:
        c, constraint_name = roll_back_info
        if type(c) in [constraint.NumericalConstraint, constraint.UniqueConstraint]:
            drop_sql = "ALTER TABLE %s DROP CONSTRAINT IF EXISTS %s;" % (
                c.table, constraint_name)
        elif type(c) in [constraint.PresenceConstraint]:
            drop_sql = "ALTER TABLE %s ALTER COLUMN %s DROP NOT NULL;" % (
                c.table, c.field)
        Evaluator.evaluate_query(drop_sql, CONNECT_MAP[appname])


def evaluate_queries(qs, stage, connect_str):
    repeat = 10
    for q in tqdm(qs):
        try:
            if stage == "before":
                q.before = Evaluator.evaluate_query(
                    "Explain " + q.raw, connect_str)
                for i in range(repeat):
                    q.before_time += Evaluator.evaluate_actual_time(
                        q.raw, connect_str)
                q.before_time /= repeat
            elif stage == "after":
                q.after = Evaluator.evaluate_query(
                    "Explain " + q.raw, connect_str)
                for i in range(repeat):
                    q.after_time += Evaluator.evaluate_actual_time(
                        q.raw, connect_str)
                q.after_time /= repeat
        except:
            print(format(q.q_obj))
            print(traceback.format_exc())
            print("[Error] Fail to evaluate %s" % q.raw)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--app', default='redmine')
    parser.add_argument('--cnt', default=100000)
    args = parser.parse_args()

    appname = args.app
    query_file = get_filename(FileType.RAW_QUERY, appname)
    queries = Loader.load_queries(query_file, offset=0, cnt=int(args.cnt))
    connect_str = CONNECT_MAP[appname]
    queries = [EvalQuery(q, connect_str) for q in queries]
    queries = [q for q in queries if q.raw is not None]
    constraint_file = get_filename(FileType.CONSTRAINT, appname)
    constraints = Loader.load_constraints(constraint_file)
    filtered_qs = filter_queries(queries, constraints)

    evaluate_queries(filtered_qs, "before", connect_str)
    constraints = [c for c in constraints if c.db == False]
    installed = install_constraints(constraints)
    evaluate_queries(filtered_qs, "after", connect_str)
    roll_back(installed)
    cnt = 0
    speedups = []
    outfile = get_filename(FileType.DB_PERF)
    exp_recorder.clear(outfile)
    for q in filtered_qs:
        if q.before is None or q.after is None or q.before_time == 0 or q.after_time == 0:
            continue
        eq = test_query_result_equivalence(q.before, q.after)
        cnt += (not eq)
        s = q.before_time / q.after_time
        # if s < 0.8:
        if not eq:
            exp_recorder.record('before', q.before_time)
            exp_recorder.record('after', q.after_time)
            exp_recorder.record('sql', q.raw)
            exp_recorder.record('before_plan', q.before)
            exp_recorder.record('after_plan', q.after)
            exp_recorder.dump(outfile)
            speedups.append(s)
    print("DB rewrite: ", cnt)
    # plt.hist(speedups, 50)
    # plt.savefig("%s_db_perf.png" % appname)
