# count plot distributions for different apps
import sys
import os
import json
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from constraint import *
from loader import Loader
from config import get_filename, FileType


import matplotlib.pyplot as plt
import numpy as np

CONSTRAINT2NAME = {
    PresenceConstraint : 'Presence',
    InclusionConstraint : 'Inclusion',
    UniqueConstraint : 'Unique',
    FormatConstraint : 'Format',
    LengthConstraint : 'Length',
    NumericalConstraint : 'Numerical',
    ForeignKeyConstraint : 'FK'    
}

def group_by(constraints):
    c_map = {}
    for c in constraints:
        if type(c) not in c_map:
            c_map[type(c)] = 0
        c_map[type(c)] += 1
    return c_map

def plot_app(appname):
    filename = "/home/ubuntu/ConstrOpt/autrite/log/db/%s_db_speedup_old" % appname
    with open(filename, 'r') as f:
        lines = f.readlines()
    speedup = []
    slowdown_query_plans = []
    for line in lines:
        obj = json.loads(line)
        s = obj['before'] / obj['after']
        if s < 1.5: 
            speedup.append(s)
        if s < 0.95 and len(obj['before_plan']) < 10:
            print(obj['sql'])
            print(obj['before_plan'])
            print(obj['after_plan'])
    
    fig, ax = plt.subplots()
    fig.set_size_inches(8, 4)
    
    ax.hist(speedup, 100)
    
    ax.tick_params(axis='both', which='major', labelsize=17)
    ax.legend(prop={'size': 15})
    fig.subplots_adjust(bottom=0.2)
    # plt.xscale("log", base=2)
    plt.savefig("/home/ubuntu/ConstrOpt/figures/7.3/%s_db.png" % appname)
    
    

if __name__ == "__main__":
    for appname in ["openproject"]:
        print("app: %s" % appname)
        plot_app(appname) 