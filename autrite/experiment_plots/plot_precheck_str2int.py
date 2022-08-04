import sys, os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import json
import matplotlib.pyplot as plt
import numpy as np

from config import FileType, get_filename

total_queries = {
    "redmine" : 10,
    "dev.to" : 10,
    "openproject" : 10 
}

queries_on_constraints = {
    "redmine" : 5,
    "dev.to" : 5,
    "openproject" : 5
}

if __name__ == "__main__":
    with open(get_filename(FileType.PRECHECK_STR2INT_NUM, None), 'r') as f:
        lines = f.readlines()
    
    precheck_len = []
    precheck_format = []
    str2int = []
    all_cs_q = []
    apps = []
    for line in lines:
        obj = json.loads(line)
        apps.append(obj["app_name"])
        precheck_len.append(obj["length"])
        precheck_format.append(obj["format"])
        str2int.append(obj["inclusion"])
        all_cs_q.append(obj["queries_with_cs"])
    
    for i, c in enumerate(all_cs_q):
        precheck_len[i] = precheck_len[i] / all_cs_q[i]
        precheck_format[i] = precheck_format[i] / all_cs_q[i]
        str2int[i] = str2int[i] / all_cs_q[i]
        
    fig, ax = plt.subplots()
    fig.set_size_inches(8, 4)
    
    x = np.arange(len(precheck_len))
    print(precheck_len)

    width = 0.4
    ax.bar(x - width, precheck_len, width, edgecolor='black', color='#efccc9', label = "Length Precheck")
    ax.bar(x        , precheck_format, width, edgecolor='black', color='#de948e', label = "Format Precheck")
    ax.bar(x + width, str2int, width, edgecolor='black', color='#713b28', label = "Query Rewrite")
    ax.set_xticks(x)
    ax.set_xticklabels(apps, rotation = 0)
    
    ax.tick_params(axis='both', which='major', labelsize=17)
    ax.legend(prop={'size': 15})
    # fig.subplots_adjust(bottom=0.2)
    # plt.yscale("log")
    plt.savefig("/home/ubuntu/ConstrOpt/figures/7.3/precheck_str2int.png")
    


