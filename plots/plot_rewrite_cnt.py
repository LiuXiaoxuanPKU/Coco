
import matplotlib.pyplot as plt
import json
import sys
from os.path import dirname, abspath, join
sys.path.append(join(dirname(dirname(abspath(__file__))), "rewriter/src/"))
from loader import *
from config import *
from plot_config import APP_NAME



BLUE = "#1AA7EC"
BLACK = "#453020"
ORANGE = "#de8004"
GREEN = "#28a81d"
PURPLE = "#955df5"
RED = "#e3272d"
colors = {'redmine':ORANGE, 'forem': BLUE, 'openproject': RED, 
          'mastodon': BLACK, 'openstreetmap': GREEN, 'spree': PURPLE}

def load_data():
   data = {}
   data_dir = 'data'
   for app in APP_NAME.keys():
      data[app] = []
      meta_path = get_path(FileType.REWRITE_META, app, data_dir)
      sql_path = get_path(FileType.REWRITTEN_QUERY, app, data_dir)
      qs_verified = len(read_rewrites(meta_path, sql_path, True))
      with open(get_path(FileType.REWRITE_STATS, app, data_dir)) as f:
         rewrite_stats = [int(x) for x in f.readline().split(", ")]
      with open(get_path(FileType.BENCH_STR2INT_NUM, app, data_dir), 'r') as f:
         qs_with_cs = json.loads(f.readline())['queries_with_cs']
      data[app].append(qs_with_cs)
      data[app] += rewrite_stats
      data[app].append(qs_verified)
      print("{} app data is {}".format(app, data[app])) 
   return data

def plot_data(data):
   fig, ax = plt.subplots()
   fig.set_size_inches(9, 8)
   patches = []
   for k in data:
      patches.append(plt.stairs(data[k], range(1, len(data[k]) + 2), 
                     baseline=None, label=k, lw=4, ls = "-", color = colors[k]))

   # ============= four vertical dividing bars ============
   ax.axvline(2, alpha=0.2, color='#713b28')
   ax.axvline(3, alpha=0.2, color='#713b28')
   ax.axvline(4, alpha=0.2, color='#713b28')
   ax.axvline(5, alpha=0.2, color='#713b28')

   # ============= add text explainations =================
   axis_font = {'size': 17}
   text_font = {'y': 16, 'size': 12, 'weight': 'bold', 'ha': 'center', 'va': 'center'}
   qs_w_cs_font = {'x': 1.45, 'size': 11, 'ha': 'center', 'va': 'center'}
   enumerate_font = {'x': 2.5, 'size': 11, 'ha': 'center', 'va': 'center'}
   rm_slow_font = {'x': 3.5, 'size': 11, 'ha': 'center', 'va': 'center'}
   test_font = {'x': 4.5, 'size': 11, 'ha': 'center', 'va': 'center'}
   verify_font = {'x': 5.5, 'size': 11, 'ha': 'center', 'va': 'center'}

   plt.ylabel("Number of queries", **axis_font)
   plt.xlabel("Stages of ConstrOpt Rewrite", **axis_font)

   plt.text(1.45, s="Queries with\nconstraints", **text_font)
   plt.text(2.5, s= "Enumerate", **text_font)
   plt.text(3.5, s="Remove\nslow rewrites", **text_font)
   plt.text(4.5, s="Test", **text_font)
   plt.text(5.5, s="Verify", **text_font)

   plt.xticks([])  # supress x axis labels
   plt.xlim(0.9, 6.2)
   plt.ylim(bottom=10, top = 30000)
   plt.yscale('log', base=10)
   plt.legend(prop={'size': 10}, loc='upper right')
   
   plt.savefig(get_path(FileType.GRAPH_REWRITE_CNT, None, "data"))

if __name__ == "__main__":
   data = load_data()
   plot_data(data)
