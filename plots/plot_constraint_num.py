import argparse
import matplotlib.pyplot as plt
import numpy as np
import os
import sys
from os.path import dirname, abspath, join
sys.path.append(join(dirname(dirname(abspath(__file__))), "rewriter/src/"))
from loader import *
from config import *

NAME_TO_ATTRS = {
    "discourse": "Ds",
    "forem"   : "Dv",
    "loomio"   : "Lm",
    "lobsters"  : "Lb",
    "redmine"  : "Re",
    "gitlab"   : "Gi",
    "openproject"   : "Op",
    "spree"    : "Sp",
    "rorecommerce" : "Ro",
    "diaspora" : "Da",
    "onebody"  : "On",
    "mastodon" : "Ma",
    "tracks"   : "Ta",
    "openstreetmap" : "Os" 
}

def ctr_eq(c1, c2):
    field_eq = False
    if isinstance(c1.field, str):
        field_eq = (c1.field == c2.field)
    elif isinstance(c1.field, list):
        field_eq = (set(c1.field) == set(c2.field))
    else:
        print(f"[Error] Unsupport field type {c1.field}")
        assert(False)
    return type(c1) == type(c2) and c1.table == c2.table and field_eq

def get_stats(ctrs):
    dbs = [ctr for ctr in ctrs if ctr.db]
    models = [ctr for ctr in ctrs if not ctr.db]
    dups = []
    for db_ctr in dbs:
        for model_ctr in models:
            if ctr_eq(db_ctr, model_ctr):
                dups.append((db_ctr, model_ctr))
    return len(dbs), len(models), len(dups)


def plot_stats(stats, outfile):
    dbs, models, dups = stats["dbs"], stats["models"], stats["dups"]
    labels = list(models.keys())
    dup_values = list(dups.values())
    model_wo_dups = np.array(list(models.values())) - np.array(dup_values)
    db_wo_dups = np.array(list(dbs.values())) - np.array(dup_values)
    overlap_percentage = sum(dup_values) / (model_wo_dups.sum() + db_wo_dups.sum() + sum(dup_values))
    print(f"overlap percentage: {overlap_percentage}")
    

    fig, ax = plt.subplots()
    fig.set_size_inches(20, 8)

    x = np.arange(len(labels))  # the label locations
    width = 0.4
    ax.bar(x, [0] * len(labels), hatch='//', edgecolor='black', label = "Defined both in Model and DB", color="white")
    ax.bar(x - width/2, dup_values, width, edgecolor='black', hatch='//', color='#2471a3', alpha=0.5)
    ax.bar(x - width/2, model_wo_dups, width, edgecolor='black', bottom = dup_values, color='#2471a3', label = "Application")
    ax.bar(x + width/2, dup_values, width, edgecolor='black', hatch='//', color='#e67e22', alpha=0.5)
    ax.bar(x + width/2, db_wo_dups, width, edgecolor='black', bottom = dup_values, color='#e67e22', label = "DB")
    ax.set_xticks(x)
    ax.set_xticklabels(labels)

    step = 300
    maxv = int(max(list(models.values())) / step) * step
    ax.set_xlim(-3.0/2*width, len(labels) - width)
    # ax.set_yticks(list(range(0, maxv + 50, step)))
    # ax.set_yscale("log", nonpositive='clip')
    ax.set_ylabel("Number of constraints", size = 40)

    ax.tick_params(axis='both', which='major', labelsize=40)
    ax.legend(prop={'size': 30})
    plt.savefig(outfile)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--data_dir', type=str, default='data')
    args = parser.parse_args()
    
    # load constraints
    constr_dir = get_path(FileType.CONSTRAINT, '', args.data_dir)
    dbs, models, dups = {}, {}, {}
    for f in os.listdir(constr_dir):
        app = NAME_TO_ATTRS[f.split('.')[0]]      
        ctrs = read_constraints(join(constr_dir, f), include_all = True, remove_pk = False)
        # get stats of different types
        dbs[app], models[app], dups[app] = get_stats(ctrs)
        
    stats = {"dbs": dbs, "models": models, "dups": dups}
    print(stats)
    outfilename = get_path(FileType.GRAPH_CONSTRAINT_COMPARE, '', args.data_dir)
    plot_stats(stats, outfilename)
        