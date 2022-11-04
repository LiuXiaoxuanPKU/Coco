from statistics import median
import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import json
from config import get_filename, FileType
import matplotlib.pyplot as plt
import numpy as np
import seaborn as sns
import pandas as pd

suffix = "png"
speedup = {}
s = []
a = []
q_len = {"redmine":0, "forem":0, "openproject":0,
         "mastodon": 0, "spree": 0, "openstreetmap": 0}
storages = {"redmine": 2.67, "forem": 2.14, "openproject":2.55,
         "mastodon": 1.89, "spree": 2.45, "openstreetmap": 1.49}

APP_NAME = {
    "redmine" : "Re",
    "forem": "Dv",
    "openproject": "Op",
    "mastodon" : "Ma",
    "openstreetmap": "Os",
    "spree": "Sp"
}

apps = list(storages.keys())
for app in apps:
    print(app)
    filename = get_filename(FileType.ENUM_EVAL, app)
    with open(filename, "r") as f:
        lines = f.readlines()
    speedup[app] = []
    for i, line in enumerate(lines):
        obj = json.loads(line)
        # after_time = max(1e-5, obj["after_time"])
        sp = obj["before_time"] / obj["after_time"] 
        q_len[app] += len(obj["before"])
        if sp == 1:
           continue
        if sp < 1 and len(obj['before']) < 100:
            print(i, sp)
            print(obj["before_time"], obj["after_time"])
            print(obj['before'])
            print(obj['after'])
            print("")
            continue
        speedup[app].append(sp)
        s.append(sp)
        a.append(app)

fig, ax = plt.subplots(1, 1)
storage = list(storages.values())
fig.set_size_inches(4, 4)
x = np.arange(len(speedup))  # the label locations
#sns.boxplot(data=pd.DataFrame.from_dict({"speedup":s, "app":a}), x="app", y="speedup")
ax.set_xticks([0, 1, 2, 3, 4, 5])
ax.tick_params(axis='both', which='major', labelsize=12)
ax.set_xticklabels(apps)
means = []

mins = []
maxs = []
errors = [[], []]
for k in speedup:
    med = np.median(speedup[k])
    means.append(med)
    mv = np.percentile(speedup[k], 25)
    mx = np.percentile(speedup[k], 75)
    print(k, med, mv, mx)
    errors[0].append(med - mv)
    errors[1].append(mx - med)

print(means)
# print(min(speedup['forem']))
# print(q_len)

# errors = [errors[], errors[1], 0.1]
width = 0.5
ax.bar(x, means, width=width, yerr=errors, label="Query Speedup", color='#1f77b4', capsize=6)
ax.set_ylabel("Speedup", size = 18)
ax.set_xlabel("Application", size= 18)
ax.set_yticks([0, 0.5, 1])
ax.set_xticks([0, 1, 2, 3, 4, 5])
ax.set_xticklabels([APP_NAME[a] for a in apps])
# ax.legend(loc='upper right', ncol=2, prop={'size': 14})
ax.tick_params(axis='both', which='major', labelsize=16)
ax.grid(axis='y', color='grey')
plt.tight_layout()
plt.subplots_adjust(bottom=0.15)
ax.set_ylim(0.5, 1.3)
fig.savefig("/home/ubuntu/ConstrOpt/figures/7.4/str2int_perf.%s" % suffix)


fig, ax = plt.subplots(1, 1)
storage = list(storages.values())
fig.set_size_inches(4, 4)
width = 0.5
ax.bar(x, storage, width=width, label="Storage Reduction", color='#ff7f0e')
ax.set_ylabel("Storage Reduction", size = 18)
ax.set_xlabel("Application", size= 18)
ax.set_yticks([0, 1, 2, 3])
ax.set_xticks([0, 1, 2, 3, 4, 5])
ax.set_xticklabels([APP_NAME[a] for a in apps])
# ax.legend(loc='upper right', ncol=2, prop={'size': 14})
ax.tick_params(axis='both', which='major', labelsize=16)
ax.grid(axis='y', color='grey')
plt.tight_layout()
plt.subplots_adjust(bottom=0.15)
plt.savefig("/home/ubuntu/ConstrOpt/figures/7.4/str2int_storage.%s" % suffix)


fig, ax = plt.subplots(1, 1)
fig.set_size_inches(4, 4)
q1 = [1.03, 1.27, 1.77, 2.4, 4.77]
q2 = [0.97, 1.24, 1.66, 2.39, 5.03]
q3 = [1.02, 1.25, 1.64, 2.45, 5.02]
percentage = [0, 20, 40 ,60, 80]
x = np.arange(len(percentage))
width = 0.2
ax.bar(x - width, q1, width=width, label='Q1', color='#1f77b4')
ax.bar(x, q2, width=width, label='Q2', color='#ff7f0e')
ax.bar(x + width, q3, width=width, label='Q3', color='#2ca02c')
ax.tick_params(axis='both', which='major', labelsize=12)
ax.set_yticks([0, 1, 2, 3, 4, 5])
ax.set_xticks([0, 1, 2, 3, 4])
ax.set_xticklabels([str(s) + "%" for s in percentage])
ax.set_xlabel("Invalid Percentage", size=18)
ax.set_ylabel("Speedup", size = 18)
ax.legend(loc=(0,1.05), ncol=3, prop={'size': 13})
ax.tick_params(axis='both', which='major', labelsize=14)
ax.grid(axis='y', color='grey')
plt.tight_layout()
plt.subplots_adjust(bottom=0.15)
plt.savefig("/home/ubuntu/ConstrOpt/figures/7.4/precheck.%s" % suffix)


