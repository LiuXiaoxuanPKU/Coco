import pickle
from mo_sql_parsing import parse
import sys
# TODO: replace the path here
sys.path.insert(
    1, '/Users/xiaoxuanliu/Documents/UCB/fall2021/ConstrOpt/query_rewriter')
from query_rewriter import rewrite

filename = './experiment/queries/redmine.pk'

with open(filename, 'rb') as f:
    pairs = list(pickle.load(f))

for i in range(100):
    print(pairs[i][1])
# for loc, sql in pairs:
#     rewrite.rewrite(parse(sql))
