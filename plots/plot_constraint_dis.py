import argparse
import numpy as np
import matplotlib.pyplot as plt
from os.path import dirname, abspath, join
import os
import sys
sys.path.append(join(dirname(dirname(abspath(__file__))), "rewriter/src/"))
from loader import *
from config import *

CONSTRAINT_TYPE_NAMES = {
   UniqueConstraint: "Uniqueness",
   InclusionConstraint: "Inclusion",
   LengthConstraint: "Length",
   FormatConstraint: "Format",
   PresenceConstraint: "Presence",
   NumericalConstraint: "Numerical",
   ForeignKeyConstraint: "Foreign Key"
}

def get_stats(ctrs):
   dbs = {k: 0 for k in CONSTRAINT_TYPE_NAMES.values()}
   models = {k: 0 for k in CONSTRAINT_TYPE_NAMES.values()}
   for ctr in ctrs:
      bucket = dbs if ctr.db == True else models
      bucket[CONSTRAINT_TYPE_NAMES[type(ctr)]] += 1
   return {"dbs": dbs, "models": models}
   

def plot_stats(stats, outfile):
   dbs, models = stats["dbs"], stats["models"]
   labels = list(models.keys())

   fig, ax = plt.subplots()
   fig.set_size_inches(20, 8)

   x = np.arange(len(labels))  # the label locations
   width = 0.4
   #ax.bar(x - width/2, list(models.values()), width, edgecolor='black', color='#efccc9', label = "Model")
   #ax.bar(x + width/2, list(dbs.values()), width, edgecolor='black', color='#713b28', label = "DB")
   ax.bar(x - width/2, list(models.values()), width, edgecolor='black', label = "Model")
   ax.bar(x + width/2, list(dbs.values()), width, edgecolor='black', label = "DB")
   for i, v in enumerate(models.values()):
      ax.text(i - width/2 - 0.17, v * 1.05, str(v), color='black', fontsize=24)
   for i, v in enumerate(dbs.values()):
      if v == 0:
         v = 1
         t = '0'
      else:
         t = str(v)
      ax.text(i + width/2 - 0.15, v * 1.05, t, color='black', fontsize=24)
      
   ax.set_xticks(x)
   ax.set_xticklabels(labels, rotation = 20)

   step = 500
   maxv = int(max(list(models.values()) + list(dbs.values())) / step) * step
   ax.set_xlim(-3.0/2*width, len(labels) - width)
   ax.set_yscale("log", nonpositive='clip')
   ax.set_ylim(bottom=1, top=10**(3.7))
   # ax.set_yticks(list(range(0, maxv + 50, step)))
   ax.set_ylabel("Number of constraints", size = 40)

   ax.tick_params(axis='both', which='major', labelsize=40)
   ax.legend(prop={'size': 30}, loc=(0.65, 1.05), ncol = 2)
   fig.subplots_adjust(bottom=0.2)
   plt.savefig(outfile)


if __name__ == "__main__":
   parser = argparse.ArgumentParser()
   parser.add_argument('--data_dir', type=str, default='data')
   args = parser.parse_args()

   # load constraints
   constr_dir = get_path(FileType.CONSTRAINT, '', args.data_dir)
   ctrs = []
   for f in os.listdir(constr_dir):
      ctrs += read_constraints(join(constr_dir, f), include_all = True)
   
   # get stats of different types
   stats = get_stats(ctrs)
   
   outfilename = get_path(FileType.GRAPH_CONSTRAINT_DIS, '', args.data_dir)
   plot_stats(stats, outfilename)
