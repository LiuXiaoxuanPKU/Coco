from copyreg import pickle
import pickle
import matplotlib.pyplot as plt
import numpy as np
from plot_config import APP_NAME
from os.path import dirname, abspath, join
import sys
sys.path.append(join(dirname(dirname(abspath(__file__))), "rewriter/src/"))
from config import FileType, get_path

tick_size = 14
label_size = 16 

def plot_app(appname, ax):
  data_dir = "data"
  with open(get_path(FileType.ENUMERATE_CNT, appname, data_dir), 'rb') as f:
    cnts = pickle.load(f)
  print(f"App:{appname}\ttotal: {len(cnts)}\tover 100: {(np.array(cnts)>100).sum()}")
  
  plt.yticks(fontsize=tick_size)
  plt.xticks(fontsize=tick_size)
  plt.xlabel("Number of Enumerated Candidates", size=label_size)
  plt.ylabel("Cumulative percentage (%)", size=label_size)
  loc = [0, 0.2, 0.4, 0.6, 0.8, 1.0] 
  plt.yticks(loc, [int(l * 100) for l in loc])
  # ax.set_yscale('log')
  n_bins = 10000 
  # get the counts and edges of the histogram data
  cs, edges = np.histogram(cnts, bins=n_bins)
  # plot the data as a step plot. note that edges has an extra right edge.
  ax.step(edges[:-1], cs.cumsum() / cs.sum(), label=APP_NAME[appname], linewidth=2)
  

def main():
  fig, ax = plt.subplots()
  fig.set_size_inches(6, 4)
  for app in APP_NAME.keys():
    plot_app(app, ax)
  plt.legend(loc='lower right', fontsize='large')
  ax.set_xlim(0, 100)
  plt.grid()
  plt.tight_layout()
  filename = get_path(FileType.GRAPH_REWRITE_THRESHOLD, None, "data")
  plt.savefig(filename)

if __name__ == "__main__":
  main()