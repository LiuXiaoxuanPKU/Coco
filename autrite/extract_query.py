from loader import Loader
from config import CONNECT_MAP, FileType, get_filename, RewriteQuery
import constraint 
from extract_rule import ExtractInclusionRule
import sys

# This script counts queries has table column with a inclusion constraint


#====================load constraints and queries====================
# rewrite_q is a list of queries from the rewrite rules
def extracted(rewrite_q):
    return len(rewrite_q) == 1

def main(appname):
    app_to_cnt = {"redmine": 262462, "forem": 183483}
    constraint_filename = get_filename(FileType.CONSTRAINT, appname)
    query_filename = get_filename(FileType.RAW_QUERY, appname)
    offset = 0
    # query_cnt = app_to_cnt[appname]
    constraints = Loader.load_constraints(constraint_filename)
    queries = Loader.load_queries(query_filename, offset, 3)
    # filter inclusion constraints from the rest
    inclusion_cs = [c for c in constraints if isinstance(c, constraint.InclusionConstraint)]
    cnt = 0
    for q in queries:
        try:
            rewrite_q = ExtractInclusionRule(inclusion_cs).apply(q)
            if extracted(rewrite_q):
                cnt += 1
        except (KeyError, TypeError, AttributeError, ValueError):
            print(format(q))
            print("-----------")
    print(cnt)
    return cnt
    

if __name__=="__main__":
    # only accept redmine, forem, openproject as argument for now
    appname = sys.argv[1]
    main(appname)

