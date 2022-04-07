from mo_sql_parsing import parse, format

import sys, os
# sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.append('./../')
from loader import Loader
from config import CONNECT_MAP, FileType, get_filename, RewriteQuery
import constraint 
from extract_rule import ExtractInclusionRule

# This script counts queries has table column with a inclusion constraint
def main(appname):
    #==============load constraints and queries=================
    app_to_cnt = {"redmine": 262462, "forem": 183483}
    constraint_filename = "../" + get_filename(FileType.CONSTRAINT, appname)
    query_filename = "../" + get_filename(FileType.RAW_QUERY, appname)
    offset = 0
    query_cnt = app_to_cnt[appname]
    constraints = Loader.load_constraints(constraint_filename)
    queries = Loader.load_queries(query_filename, offset, query_cnt)
    # filter inclusion constraints from the rest
    inclusion_cs = [c for c in constraints if isinstance(c, constraint.InclusionConstraint)]
    #====================check each query========================
    cnt = 0
    for q in queries:
        try:
            rewrite_q = ExtractInclusionRule(inclusion_cs).apply(q)
            if extracted(rewrite_q):
                cnt += 1
        except (KeyError, TypeError, AttributeError, ValueError):
            print_error(q)
    return cnt

#=====================helper functions===========================
# return True if query contains inclusion constrains
def extracted(q) -> bool:
    # rewrite_q is a list of queries from the rewrite rules
    return len(q) == 1

# print info about errored query
def print_error(q) -> None:
    print(format(q))
    print("----------------")
    print(q)
    print("================")
    

if __name__=="__main__":
    # accept redmine, forem, or openproject as argument 
    appname = sys.argv[1]
    cnt = main(appname)
    print("number of queries contains inclusion constrants is ", cnt)

