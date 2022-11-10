
from config import CONNECT_MAP, FileType, RewriteQuery, get_filename
from mo_sql_parsing import parse, format
from utils import generate_query_param_rewrites

appname = "spree"
sql_create_path = get_filename(FileType.VERIFIER_INPUT, appname)
with open(sql_create_path, "r") as f:
  create_lines = f.readlines()

distinct_dump_path = "/home/ubuntu/ConstrOpt/constropt/autrite/log/%s/cosette/distinct" % appname
    
    
def format_param(q):
  tokens = q.split(" ")
  keywords = ['one', 'position', 'value', 'count']
  
  for i, t in enumerate(tokens):
      if t in keywords:
          tokens[i] = '"' + t + '"'
  q = ' '.join(tokens)
  return q         
            
def dump_query_pair(q1, q2, i):
  qs = create_lines + ["\n-- Original Query\n"]
  qs += [format_param(q1) + ";"]
  qs += ["\n-- Rewritten Queries\n"]   
  qs += [format_param(q2)]
  with open("%s/%d.sql" % (distinct_dump_path, i), 'w') as f:
    f.writelines(qs)


sql_path = "/home/ubuntu/ConstrOpt/queries/%s/distinct.sql" % appname
with open(sql_path, "r") as f:
  lines = f.readlines()
  
rewrites = []
for l in lines:
  if 'DISTINCT' in l or 'distinct' in l:
    l = l.replace('DISTINCT', '')
    l = l.replace('distinct', '')
    rewrites.append(l)

valid = 0
for i, (org, rewrite) in enumerate(zip(lines, rewrites)):
  try:    
    org_obj = RewriteQuery(org, parse(org))
  except:
    print("[Error] Fail to parse %s" % org)
    continue
  rewrite_obj = RewriteQuery(rewrite, parse(rewrite))
  if not generate_query_param_rewrites(org_obj, [rewrite_obj], CONNECT_MAP[appname]):
    print("[Error] Fail to generate parameter: %s" % org)
    continue
  valid += 1
  dump_query_pair(org_obj.q_raw_param, rewrite_obj.q_raw_param, valid)
  
print("%d/%d" % (valid, len(lines)))
