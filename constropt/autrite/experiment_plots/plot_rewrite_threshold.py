from copyreg import pickle
import pickle
import matplotlib.pyplot as plt

appname = "redmine"
tick_size = 14
label_size = 16 

def plot_app(appname):
  fig, ax = plt.subplots()
  fig.set_size_inches(8, 4)
  with open("log/%s/enumerate_cnts" % appname, "rb") as f:
    cnts = pickle.load(f)
  
  with open("log/%s/enumerate_times" % appname, "rb") as f:
    times = pickle.load(f) 
  print(cnts)
  print(max(cnts))
  print(len(cnts))
  
  plt.yticks(fontsize=tick_size)
  plt.xticks(fontsize=tick_size)
  plt.xlabel("Number of Rewrites", size=label_size)
  plt.ylabel("Cumulative percentage (%)", size=label_size)
  loc = [0, 0.2, 0.4, 0.6, 0.8, 1.0] 
  plt.yticks(loc, [int(l * 100) for l in loc])
  # ax.set_yscale('log')
  n_bins = 10000 
  n, bins, patches = ax.hist(cnts, n_bins, density=True, histtype='step',
                           cumulative=True, label=appname)
  # ax.set_xlim(0, 100)
  plt.tight_layout()
  
  suffix = "png"
  plt.savefig("/home/ubuntu/ConstrOpt/figures/7.3/%s_rewrite_threshold.%s" % (appname, suffix))



plot_app("mastodon")