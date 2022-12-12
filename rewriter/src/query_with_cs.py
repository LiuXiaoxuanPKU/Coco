import argparse
import traceback
from config import FileType, get_path, CONNECT_MAP
from extract_rule import ExtractQueryRule
from utils import GlobalExpRecorder, get_valid_queries
from constraint import InclusionConstraint, LengthConstraint, FormatConstraint
from loader import *

# =====================================================================


# ========================== main function ============================
def get_query_with_cnt(app: str, data_dir: str, cnt: int = 100000):
    # load query once for each app
    offset = 0
    queries = read_queries(get_path(FileType.RAW_QUERY, app, data_dir), offset, cnt)
    
    # count the number of queries with constraints on it
    all_cs = load_cs(app, data_dir, 'all')
    all_cnt, warning_cnt = count_queries_with_cs(all_cs, queries, verbal=True)
    print("q with all cns", all_cnt)
    return all_cnt


#################################
#        helper functions       #
#################################
# return filtered constraints
def load_cs(appname, datadir, cs_type) -> list:
    constraints = read_constraints(get_path(FileType.CONSTRAINT, appname, datadir), True)
    if cs_type == 'all':
        return constraints
    filtered_cs = [c for c in constraints if isinstance(c, cs_type)]
    return filtered_cs

# return number of queries contains filtered constraints
def count_queries_with_cs(filtered_cs, queries, verbal) -> tuple:
    cnt = 0
    rule = ExtractQueryRule(filtered_cs)
    for q in queries:
        try:
            rewrite_q = rule.apply(q.q_obj)
            if extracted(rewrite_q):
                # print(format(rewrite_q[0]))
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

