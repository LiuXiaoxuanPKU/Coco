import numpy as np
import matplotlib.pyplot as plt

models = {
   'Presence' : 1482,
   'Inclusion' : 144,
   'Uniqueness': 370,
   'Format' : 116,
   'Length' : 430,
   'Numerical' : 144,
   'Foreign Key' : 1360
}

dbs = {
   'Presence' : 2469,
   'Inclusion' : 0,
   'Uniqueness': 368,
   'Format' : 0,
   'Length' : 2546,
   'Numerical' : 63,
   'Foreign Key' : 89
}

labels = list(models.keys())

fig, ax = plt.subplots()
fig.set_size_inches(20, 8)

x = np.arange(len(labels))  # the label locations
width = 0.4
ax.bar(x - width/2, list(models.values()), width, edgecolor='black', color='#2596be', label = "Model")
ax.bar(x + width/2, list(dbs.values()), width, edgecolor='black', color='#e28743', label = "DB")
ax.set_xticks(x)
ax.set_xticklabels(labels, rotation = 20)

step = 500
maxv = int(max(list(models.values()) + list(dbs.values())) / step) * step
ax.set_xlim(-3.0/2*width, len(labels) - width)
ax.set_yticks(list(range(0, maxv + 50, step)))
ax.set_ylabel("Number of constraints", size = 40)

ax.tick_params(axis='both', which='major', labelsize=40)
ax.legend(prop={'size': 30})
fig.subplots_adjust(bottom=0.2)
plt.savefig("constraint_dis.pdf")