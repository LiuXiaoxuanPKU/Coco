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
app="mastodon"
suffix="pdf"

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
def plot(data):
    fig, ax = plt.subplots(figsize=(4, 4))
    at = AnchoredText(
    APP_NAME[app], prop=dict(size=ACHNOR_SIZE[app]), frameon=False, loc='upper left')
    ax.add_artist(at)
    pd_data = pd.DataFrame.from_dict(data)
    print(pd_data)
    sns.boxplot(data=pd_data, x='type', y='time', 
                showfliers=False)
    # plt.xscale("log")
    ax.set_xticks([0, 1, 2, 3])
    ax.set_xticklabels(["EM", "RM", "Test", "Verify"])
    if app == "openproject":
        plt.ylim(0.001, 20)
    # plt.yticks([0, 2, 4, 6, 8, 10])
    plt.yscale('log')
    if app in ["redmine", "mastodon"]:  
        plt.ylabel("Execution time (s)", size=s)
        fig.subplots_adjust(bottom=0.2, left=0.24)
    else:
        plt.ylabel("") 
        fig.subplots_adjust(bottom=0.2, left=0.2)
    plt.xlabel("Step", size=s+2)
    ax.tick_params(axis='both', which='major', labelsize=s)
    plt.savefig("/home/ubuntu/ConstrOpt/figures/7.3/%s_exec_time.%s" % (app, suffix))
   
def prepare_data(app):
    file = get_filename(FileType.REWRITE_TIME, app) 
    with open(file, 'r') as f:
        lines = f.readlines()
    data = {'type':[], 'time':[]}
    for line in lines:
        obj = json.loads(line)
        for k in obj:
            if k == "id" or k == "rewrites":
                continue
            data['type'].append(k)
            data['time'].append(obj[k])
    
    verify_file = get_filename(FileType.VERIFIER_TIME, app)
    with open(verify_file, 'r') as f:
        lines = f.readlines()
    times = []
    for line in lines:
        line = line.strip()
        data['type'].append('verify')
        data['time'].append(float(line.split("\t")[-1]))
        times.append(float(line.split("\t")[-1]))
    print(max(times)) 
    return data

if __name__ == "__main__":
    data = prepare_data(app)
    plot(data)


