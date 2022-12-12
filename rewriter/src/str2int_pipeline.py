import argparse
import traceback
from loader import Loader
from config import FileType, get_filename, CONNECT_MAP
from extract_rule import ExtractQueryRule
from utils import GlobalExpRecorder, get_valid_queries
from constraint import InclusionConstraint, LengthConstraint, FormatConstraint

name_to_type = {
    'inclusion': InclusionConstraint,
    'length': LengthConstraint,
    'format': FormatConstraint,
}
# =====================================================================


# ========================== main function ============================
def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument('--app', default='redmine')
    parser.add_argument('--cnt', type=int, default=100000, help='number of queries to rewrite')
    parser.add_argument("--data_dir", type=str, help="data root dir")
    args = parser.parse_args()
    
    recorder = GlobalExpRecorder()
    recorder.record("app_name", args.app)
    
    # load query once for each app
    offset = 0
    queries = Loader.load_queries(get_filename(FileType.RAW_QUERY, args.app, args.data_dir), offset, args.cnt)
    # queries = get_valid_queries(queries, CONNECT_MAP[args.app])
    
    # count the number of queries with constraints on it
    all_cs = load_cs(args.app, args.data_dir, 'all')
    all_cnt, warning_cnt = count_queries_with_cs(all_cs, queries, verbal=True)
    recorder.record("queries_with_cs", all_cnt)
    recorder.record("warning cnt", warning_cnt)

    # count inclusion, length, format constraint query
    for type_name in name_to_type.keys():
        cs_type = name_to_type[type_name]
        filtered_cs = load_cs(args.app, args.data_dir, cs_type)
        cnt, _ = count_queries_with_cs(filtered_cs, queries, verbal=True)
        recorder.record(type_name, cnt)
    recorder.dump(get_filename(FileType.PRECHECK_STR2INT_NUM, args.app, args.data_dir))

#################################
#        helper functions       #
#################################
# return filtered constraints
def load_cs(appname, datadir, cs_type) -> list:
    constraints = Loader.load_constraints(get_filename(FileType.CONSTRAINT, appname, datadir))
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


if __name__ == "__main__":
    main()