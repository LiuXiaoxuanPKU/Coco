import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import constraint
from utils import GlobalExpRecorder
from extract_rule import ExtractQueryRule
from config import FileType, get_filename
from loader import Loader
import traceback

# ------------------------------------------------------------------------------
# This script counts queries has table column with certain type(s) of constraints
# dump the results into logs. Here's how to run this script:
# Run under autrite directory: python3 benchmark/bench_precheck_str2int.py
# Option to verbal for debug purpose: python3 benchmark/bench_precheck_str2int.py -v
# ------------------------------------------------------------------------------

# ========================== static variables =========================
app_to_cnt = {"redmine": 262462, "forem": 183483,
              "openproject": 22021, "mastodon": 1000000, "spree": 1000000}
# app_to_cnt = {"redmine": 100, "forem": 1, "openproject": 100, "mastodon": 100, "spree": 50}
appnames = ['forem', 'redmine', 'openproject', 'mastodon', "spree"]
# appnames = ['mastodon']
name_to_type = {
    'inclusion': constraint.InclusionConstraint,
    'length': constraint.LengthConstraint,
    'format': constraint.FormatConstraint,
}
# =====================================================================


# ========================== main function ============================
def main(verbal) -> None:
    # make sure log file is clean
    recorder = GlobalExpRecorder()
    recorder.clear(get_filename(FileType.PRECHECK_STR2INT_NUM, None))

    for appname in appnames:
        # load query once for each app
        all_queries = load_queries(appname)
        # queries = get_valid_queries(all_queries, CONNECT_MAP[appname])
        queries = all_queries
        recorder.record("app_name", appname)
        # count the number of queries with constraints on it
        all_cs = load_cs(appname, 'all')
        all_cnt, warning_cnt = count(all_cs, queries, verbal)
        recorder.record("queries_with_cs", all_cnt)
        recorder.record("warning cnt", warning_cnt)

        # count inclusion, length, format constraint query
        for type_name in name_to_type.keys():
            cs_type = name_to_type[type_name]
            filtered_cs = load_cs(appname, cs_type)
            cnt, _ = count(filtered_cs, queries, verbal)
            recorder.record(type_name, cnt)
        recorder.dump(get_filename(FileType.PRECHECK_STR2INT_NUM, None))

#################################
#        helper functions       #
#################################

# load queries


def load_queries(appname) -> list:
    query_filename = get_filename(FileType.RAW_QUERY, appname)
    offset = 0
    query_cnt = app_to_cnt[appname]
    queries = Loader.load_queries(query_filename, offset, query_cnt)
    return queries

# return filtered constraints


def load_cs(appname, cs_type) -> list:
    constraint_filename = get_filename(FileType.CONSTRAINT, appname)
    constraints = Loader.load_constraints(constraint_filename)
    if cs_type == 'all':
        return constraints
    filtered_cs = [c for c in constraints if isinstance(c, cs_type)]
    return filtered_cs

# return number of queries contains filtered constraints


def count(filtered_cs, queries, verbal) -> tuple:
    cnt = 0
    rule = ExtractQueryRule(filtered_cs)
    for q in queries:
        try:
            rewrite_q = rule.apply(q.q_obj)
            if extracted(rewrite_q):
                cnt += 1
        except (KeyError, TypeError, AttributeError, ValueError):
            print_error(q, verbal)
    return (cnt, rule.warning_cnt)

# return True if query contains inclusion constrains


def extracted(q) -> bool:
    # rewrite_q is a list of queries from the rewrite rules
    return len(q) >= 1

# print info about errored query


def print_error(q, verbal) -> None:
    if verbal:
        print(q.q_raw)
        print("----------------")
        print(traceback.format_exc())
        print("================")
    else:
        pass


if __name__ == "__main__":
    verbal = len(sys.argv) > 1
    main(verbal)
