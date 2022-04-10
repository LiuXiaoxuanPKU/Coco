from mo_sql_parsing import parse, format

import sys, os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from loader import Loader
from config import FileType, get_filename
import constraint 
from extract_rule import ExtractQueryRule
from utils import GlobalExpRecorder

# ------------------------------------------------------------------------------
# This script counts queries has table column with a certain type of constraints
# dump the results into logs
# ------------------------------------------------------------------------------
def main(verbal) -> None:
    # make sure log file is clean
    recorder = GlobalExpRecorder()
    recorder.clear(get_filename(FileType.QUERY_NUM))

    appnames = ['openproject', 'forem', 'redmine']
    name_to_type = {'inclusion': constraint.InclusionConstraint, 
               'length': constraint.LengthConstraint, 
               'format': constraint.FormatConstraint}

    for appname in appnames:
        # load query once for each app
        queries = load_queries(appname)
        recorder.record("app_name", appname)
        for type_name in name_to_type.keys():
            cs_type = name_to_type[type_name]
            filtered_cs = load_cs(appname, cs_type)
            cnt = count(filtered_cs, queries, verbal)
            recorder.record(type_name, cnt)
        recorder.dump(get_filename(FileType.QUERY_NUM))
        
#################################
#        helper functions       #
#################################
# load queries
def load_queries(appname) -> list:
    app_to_cnt = {"redmine": 262462, "forem": 183483, "openproject": 22021}
    query_filename = get_filename(FileType.RAW_QUERY, appname)
    offset = 0
    query_cnt = app_to_cnt[appname]
    queries = Loader.load_queries(query_filename, offset, query_cnt)
    return queries

# return filtered constraints
def load_cs(appname, cs_type) -> list:
    constraint_filename = get_filename(FileType.CONSTRAINT, appname)
    constraints = Loader.load_constraints(constraint_filename)
    filtered_cs = [c for c in constraints if isinstance(c, cs_type)]
    return filtered_cs

# return number of queries contains filtered constraints
def count(filtered_cs, queries, verbal) -> int:
    cnt = 0
    for q in queries:
        try:
            rewrite_q = ExtractQueryRule(filtered_cs).apply(q)
            if extracted(rewrite_q):
                cnt += 1
        except (KeyError, TypeError, AttributeError, ValueError):
            print_error(q, verbal)
    return cnt

# return True if query contains inclusion constrains
def extracted(q) -> bool:
    # rewrite_q is a list of queries from the rewrite rules
    return len(q) == 1

# print info about errored query
def print_error(q, verbal) -> None:
    if verbal:
        print(format(q))
        print("----------------")
        print(q)
        print("================")
    else:
        pass

if __name__=="__main__":
    # run under autrite directory: python3 benchmark/extract_query.py
    # option to verbal for debug purpose: python3 benchmark/extract_query.py -v
    verbal = len(sys.argv) > 1
    main(verbal)