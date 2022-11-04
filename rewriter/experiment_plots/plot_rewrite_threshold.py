from copyreg import pickle
import pickle
import matplotlib.pyplot as plt
import numpy as np

appname = "redmine"
tick_size = 14
label_size = 16 

APP_NAME = {
    "redmine" : "Redmine",
    "forem" : "Dev.to",
    "openproject" : "Openproject",
    "mastodon": "Mastodon",
    "spree" : "Spree",
    "openstreetmap": "Openstreetmap"
}

def plot_app(appname, fig, ax):
  with open("log/%s/enumerate_cnts" % appname, "rb") as f:
    cnts = pickle.load(f)
  
  with open("log/%s/enumerate_times" % appname, "rb") as f:
    times = pickle.load(f) 
  print(min(cnts), max(cnts), (np.array(cnts)>100).sum())
  
  plt.yticks(fontsize=tick_size)
  plt.xticks(fontsize=tick_size)
  plt.xlabel("Number of Enumerated Candidates", size=label_size)
  plt.ylabel("Cumulative percentage (%)", size=label_size)
  loc = [0, 0.2, 0.4, 0.6, 0.8, 1.0] 
  plt.yticks(loc, [int(l * 100) for l in loc])
  # ax.set_yscale('log')
  n_bins = 10000 
  # n, bins, patches = ax.hist(cnts, n_bins, density=True, histtype='step',
  #                          cumulative=True, label=appname, linewidth=2)
  # patches[0].set_xy(patches[0].get_xy()[:-1])
  # get the counts and edges of the histogram data
  cs, edges = np.histogram(cnts, bins=n_bins)
  # plot the data as a step plot.  note that edges has an extra right edge.
  ax.step(edges[:-1], cs.cumsum() / cs.sum(), label=APP_NAME[appname], linewidth=2)

  


suffix = "png"
fig, ax = plt.subplots()
fig.set_size_inches(6, 4)
plot_app("forem", fig, ax)
plot_app("redmine", fig, ax)
plot_app("openstreetmap", fig, ax)
plot_app("openproject", fig, ax)
plot_app("spree", fig, ax)
plot_app("mastodon", fig, ax)

plt.legend(loc='lower right', fontsize='large')
# ax.spines.top.set_visible(False)
# ax.spines.right.set_visible(False)
ax.set_xlim(0, 100)
plt.grid()
plt.tight_layout()
plt.savefig("/home/ubuntu/ConstrOpt/figures/7.3/all_rewrite_threshold.%s" % (suffix))
