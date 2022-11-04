import argparse
import sys, os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from config import FileType, get_filename
from evaluator import Evaluator
from loader import Loader
from constraint import InclusionConstraint
from config import CONNECT_MAP

# ===================== static variables ==========================
parser = argparse.ArgumentParser()
parser.add_argument('--app', default='openproject')
parser.add_argument('--cnt', default='100000')

args = parser.parse_args()
appname = args.app
query_cnt = int(args.cnt)
if query_cnt == -1:
    app_to_cnt = {"redmine": 262462, "forem": 183483, "openproject": 22021,
                  "spree": 100000, "openstreetmap": 100000, "mastodon": 10000}
    query_cnt = app_to_cnt[appname]

offset = 0

# load inclusion constraints as a list
def load_inclusion_cs() -> list:
  constraint_filename = get_filename(FileType.CONSTRAINT, appname)
  constraints = Loader.load_constraints(constraint_filename)
  inclusion_constraints = [c for c in constraints if isinstance(c, InclusionConstraint)]
  return inclusion_constraints
  
def get_size(field, table):
  sql = "select sum(pg_column_size(\"%s\")) as total_size from %s" % (field, table)
  ret = Evaluator.evaluate_query(sql, CONNECT_MAP[appname])
  column_size = ret[0][0]
  if column_size is None:
    print("[Error] Return null when evaluating %s" %sql )
    return -1, -1 
  sql = "select count(*) from %s" % table
  ret = Evaluator.evaluate_query(sql, CONNECT_MAP[appname])
  record_cnt = ret[0][0]
  return float(column_size), int(record_cnt)

def get_storage_red(cs):
  reds = []
  avg_size_old = []
  avg_size_new = []
  for c in cs:
    assert(isinstance(c, InclusionConstraint))
    field, org_table = c.field, c.table
    new_table = "%s_test_str2int" % org_table
    old_size, old_rec_cnt = get_size(field, org_table)
    new_size, new_rec_cnt = get_size(field, new_table)
    if old_size == -1:
      continue
    if old_rec_cnt != new_rec_cnt:
      print(org_table, new_table, old_rec_cnt, new_rec_cnt)
    # assert(old_rec_cnt == new_rec_cnt)
    avg_size_old.append(old_size / old_rec_cnt)
    avg_size_new.append(new_size / new_rec_cnt)
    reds.append(old_size / new_size)
  return sum(reds) / len(reds), sum(avg_size_old) / len(avg_size_old), sum(avg_size_new) / len(avg_size_new)
    

if __name__ == "__main__":
    inclusion_cs = load_inclusion_cs()
    avg_red, avg_size_old, avg_size_new = get_storage_red(inclusion_cs)
    print("Average Storage Reduction for %s: %f" % (appname, avg_red))
    print("Average bits for each record old: %f, new: %f" % (avg_size_old, avg_size_new))