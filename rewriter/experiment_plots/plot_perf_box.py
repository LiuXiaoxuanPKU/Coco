import sys
import os
import json
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from config import get_filename, FileType
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
from matplotlib.offsetbox import AnchoredText

n_bins = 50
s=16
app="forem"
suffix="png"

APP_NAME = {
    "redmine" : "Redmine",
    "forem" : "Dev.to",
    "openproject" : "Openproject",
    "mastodon": "Mastodon",
    "openstreetmap": "Openstreetmap",
    "spree": "Spree"
}

ACHNOR_SIZE = {
    "redmine" : 18,
    "forem" : 18,
    "openproject" : 18,
    "mastodon": 18,
    "openstreetmap": 16,
    "spree": 18
}

class EvalQuery:
  def __init__(self, before_sql, after_sql) -> None:
    self.raw = before_sql
    self.rewrite = after_sql
    self.t_db = 0
    self.t_rewrite = 0
    self.t_db_constraint = 0
    self.t_rewrite_constraint = 0
        
def plot(data):
    fig, ax = plt.subplots(figsize=(4, 4))
    at = AnchoredText(
    APP_NAME[app], prop=dict(size=ACHNOR_SIZE[app]), frameon=False, loc='upper left')
    ax.add_artist(at)
    pd_data = pd.DataFrame.from_dict(data)
    print(pd_data)
    sns.boxplot(data=pd_data, x='type', y='speedup', 
                showfliers=False)
    # plt.xscale("log")
    # ax.set_xticks([0, 1, 2])
    # ax.set_xticklabels(["EM", "RM", "Test", "Verify"])
    # if app == "openproject":
    #     plt.ylim(0.001, 20)
    # plt.yticks([0, 2, 4, 6, 8, 10])
    # plt.yscale('log')
    # if app in ["redmine", "mastodon"]:  
    #     plt.ylabel("Execution time (s)", size=s)
    #     fig.subplots_adjust(bottom=0.2, left=0.24)
    # else:
    #     plt.ylabel("") 
    #     fig.subplots_adjust(bottom=0.2, left=0.2)
    plt.ylabel("Speedup", size=s)
    plt.xlabel("Type", size=s)
    plt.tight_layout()
    ax.tick_params(axis='both', which='major', labelsize=s)
    plt.savefig("/home/ubuntu/ConstrOpt/figures/7.4/%s_box_perf.%s" % (app, suffix))
   
def load_results(app: str) -> list[EvalQuery]:
  filename = "log/perf_leq/%s_perf" % app
  queries = []
  data = {'type':[], 'speedup':[]}
  with open(filename, 'r') as f:
      lines = f.readlines()
  for l in lines:
      if l.startswith("#"):
          continue
      obj = json.loads(l)
      q = EvalQuery(obj["raw"], obj["rewrite"])
      q.t_db, q.t_rewrite, q.t_db_constraint, q.t_rewrite_constraint = \
          obj['t_db'], obj['t_rewrite'], obj['t_db_constraint'], obj['t_rewrite_constraint'] 
      data['type'].append('install')
      data['speedup'].append(q.t_db/ q.t_db_constraint)
      data['type'].append('rewrite')
      data['speedup'].append(q.t_db / q.t_rewrite)
      data['type'].append('ins+rew')
      data['speedup'].append( q.t_db / q.t_rewrite_constraint)
      
      queries.append(q)
  return queries, data
  
if __name__ == "__main__":
    _, data = load_results(app)
    plot(data)


