

from ctypes.wintypes import SIZE
import matplotlib.pyplot as plt
import numpy as np
import os
import sys
from os.path import dirname, abspath, join
sys.path.append(join(dirname(dirname(abspath(__file__))), "rewriter/src/"))
from loader import *
from config import *

# Run: under plot directory run: python plot_rewrite_cnt.py

apps = ['spree'] # change to this line once has data from other apps
fig, ax = plt.subplots()
fig.set_size_inches(9, 8)
    
x = [1, 2, 3, 4, 5, 6]
BLUE = "#1AA7EC"
BLACK = "#453020"
ORANGE = "#de8004"
GREEN = "#28a81d"
PURPLE = "#955df5"
RED = "#e3272d"
colors = {'Redmine':ORANGE, 'Dev.to': BLUE, 'Openproject': RED, 'Mastodon': BLACK, 'Openstreetmap': GREEN, 'spree': PURPLE}
data = {} 
for app in apps:
    data[app] = []
    p_meta = "../data/rewrites/{}/cost_less_eq/metadata".format(app)
    p_sql = "../data/rewrites/{}/cost_less_eq_sqls".format(app)
    read_rewrites(Path(p_meta), Path(p_sql), True)

    rewrite_f = open('../data/rewrites/{}/rewrite_stats'.format(app))
    rewrite_stats = [int(x) for x in rewrite_f.readline().split(", ")]

    qs_with_cnt = 0
    data[app].append(qs_with_cnt)
    data[app] += rewrite_stats
    qs_verified = 0
    data[app].append(qs_verified)
    print("{} app data is {}".format(app, data[app])) 

patches = []
for k in data:
    patches.append(plt.stairs(data[k], x, baseline=None, label=k, \
                  lw=4, ls = "-", color = colors[k]))
    
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
plt.savefig("./rewrite_cnt.png")
plt.savefig("./rewrite_cnt.pdf")