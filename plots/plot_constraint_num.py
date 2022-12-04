from os import dup
import matplotlib.pyplot as plt
import numpy as np
import os
import sys
from os.path import dirname, abspath, join
sys.path.append(join(dirname(dirname(abspath(__file__))), "rewriter/src/"))
from loader import *

# models = {
#     "Ds" : 441,
#     "Dv" : 439,
#     "Lm" : 114,
#     "Lb" : 131,
#     "Re" : 281,
#     "Gi" : 1219,
#     "Op" : 346,
#     "Sp" : 245,
#     "Ro" : 305,
#     "Da" : 112,
#     "On" : 172,
#     "Ma" : 217,
#     "Ta" : 46,
#     "Os" : 238
# }

# dbs = {
#     "Ds" : 1065,
#     "Dv" : 590,
#     "Lm" : 314,
#     "Lb" : 108,
#     "Re" : 332,
#     "Gi" : 1287,
#     "Op" : 177,
#     "Sp" : 239,
#     "Ro" : 263,
#     "Da" : 265,
#     "On" : 214,
#     "Ma" : 406,
#     "Ta" : 69,
#     "Os" : 213
# }

# dups = {
#     "Ds" : 91,
#     "Dv" : 153,
#     "Lm" : 16,
#     "Lb" : 33,
#     "Re" : 91,
#     "Gi" : 230,
#     "Op" : 35,
#     "Sp" : 10,
#     "Ro" : 130,
#     "Da" : 25,
#     "On" : 21,
#     "Ma" : 65,
#     "Ta" : 12,
#     "Os" : 42
# }


models = {
    "Ds" : 0,
    "Dv" : 0,
    "Lm" : 0,
    "Lb" : 0,
    "Re" : 0,
    "Gi" : 0,
    "Op" : 0,
    "Sp" : 0,
    "Ro" : 0,
    "Da" : 0,
    "On" : 0,
    "Ma" : 0,
    "Ta" : 0,
    "Os" : 0
}

dbs = {
    "Ds" : 0,
    "Dv" : 0,
    "Lm" : 0,
    "Lb" : 0,
    "Re" : 0,
    "Gi" : 0,
    "Op" : 0,
    "Sp" : 0,
    "Ro" : 0,
    "Da" : 0,
    "On" : 0,
    "Ma" : 0,
    "Ta" : 0,
    "Os" : 0
}

dups = {
    "Ds" : 0,
    "Dv" : 0,
    "Lm" : 0,
    "Lb" : 0,
    "Re" : 0,
    "Gi" : 0,
    "Op" : 0,
    "Sp" : 0,
    "Ro" : 0,
    "Da" : 0,
    "On" : 0,
    "Ma" : 0,
    "Ta" : 0,
    "Os" : 0
}


name_to_abbr = {
    "discourse": "Ds",
    "dev.to"   : "Dv",
    "loomio"   : "Lm",
    "lobster"  : "Lb",
    "redmine"  : "Re",
    "gitlab"   : "Gi",
    "openproject"   : "Op",
    "spree"    : "Sp",
    "ror_ecommerce" : "Ro",
    "diaspora" : "Da",
    "onebody"  : "On",
    "mastodon" : "Ma",
    "tracks"   : "Ta",
    "openstreetmap" : "Os" 
}


for f in os.listdir('../data/constraints'):
    ctrs = []
    if f not in name_to_abbr.keys():
        continue
    ctrs = read_constraints("../data/constraints/" + f)
    for ctr in ctrs:
        bucket = dbs if ctr.db == True else models
        bucket[name_to_abbr[f]] += 1    
        for compare in ctrs:
            if ctr != compare and type(ctr) == type(compare) and ctr.table == compare.table and ctr.field == compare.field:
                dups[name_to_abbr[f]] += 1
                # match type(ctr).__name__:
                #     case UniqueConstraint.__name__:
                #         if ctr.type==compare.type and ctr.cond==compare.cond:
                #             dups[name_to_abbr[f]] += 1
                #         continue
                #     case InclusionConstraint.__name__:
                #         if ctr.values==compare.values:
                #             dups[name_to_abbr[f]] += 1
                #         continue
                #     case LengthConstraint.__name__:
                #         if ctr.min==compare.min and ctr.max==compare.max:
                #             dups[name_to_abbr[f]] += 1
                #         continue
                #     case FormatConstraint.__name__:
                #         if ctr.format==compare.format:
                #             dups[name_to_abbr[f]] += 1
                #         continue
                #     case PresenceConstraint.__name__:
                #         dups[name_to_abbr[f]] += 1
                #         continue
                #     case NumericalConstraint.__name__:
                #         if ctr.min==compare.min and ctr.max==compare.max:
                #             dups[name_to_abbr[f]] += 1
                #         continue
                #     case ForeignKeyConstraint.__name__:
                #         if ctr.ref_class==compare.ref_class:
                #             dups[name_to_abbr[f]] += 1
                #         continue
# Counted twice, thus divide by half
for k in dups.keys():
    dups[k] = dups[k]/2  



labels = list(models.keys())
dup_values = list(dups.values())
model_wo_dups = np.array(list(models.values())) - np.array(dup_values)
db_wo_dups = np.array(list(dbs.values())) - np.array(dup_values)

fig, ax = plt.subplots()
fig.set_size_inches(20, 8)

x = np.arange(len(labels))  # the label locations
width = 0.4
ax.bar(x, [0] * len(labels), hatch='//', edgecolor='black', label = "Defined both in Model and DB", color="white")
ax.bar(x - width/2, dup_values, width, edgecolor='black', hatch='//', color='#efccc9', alpha=0.5)
ax.bar(x - width/2, model_wo_dups, width, edgecolor='black', bottom = dup_values, color='#efccc9', label = "Application")
ax.bar(x + width/2, dup_values, width, edgecolor='black', hatch='//', color='#713b28', alpha=0.5)
ax.bar(x + width/2, db_wo_dups, width, edgecolor='black', bottom = dup_values, color='#713b28', label = "DB")
ax.set_xticks(x)
ax.set_xticklabels(labels)

step = 300
maxv = int(max(list(models.values())) / step) * step
ax.set_xlim(-3.0/2*width, len(labels) - width)
ax.set_yticks(list(range(0, maxv + 50, step)))
ax.set_ylabel("Number of constraints", size = 40)

ax.tick_params(axis='both', which='major', labelsize=40)
ax.legend(prop={'size': 30})
# plt.savefig("/home/ubuntu/ConstrOpt_str2int/figures/7.2/constraint.pdf")
plt.savefig("/home/ubuntu/graph_script_GeLi/constraint.pdf")