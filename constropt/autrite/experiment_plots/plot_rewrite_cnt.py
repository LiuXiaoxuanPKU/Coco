import seaborn as sns 
import matplotlib.pyplot as plt

redmine = [
    2289, # qs with constraints
    1530, # qs with rewritten
    1328, # qs with lower cost
    1049, # qs with lower cost and pass tests
    124   # qs get verified
]

forem = [
   1638, # qs with constraints
   461, # qs with rewritten
   102, # qs with lower cost
   54, # qs with lower cost and pass tests
   29   # qs get verified 
]

openproject = [
   10676, # qs with constraints
   8817, # qs with rewritten
   4687, # qs with lower cost
   4329, # qs with lower cost and pass tests
   709   # qs get verified 
]

fig, ax = plt.subplots()
fig.set_size_inches(8, 4)
    
x = [1,2,3,4, 5, 6]
colors = ["#1AA7EC", "#713b28", "#FF847C"]
data = {'Redmine': redmine, 'Dev.to' : forem, 'Openproject' : openproject} 
patches = []
for i, k in enumerate(data):
    patches.append(plt.stairs(data[k], x, baseline=None, label=k, \
                  lw=4, ls = "-", color = colors[i]))
ax.axvline(2, alpha=0.2, color='#713b28')
ax.axvline(3, alpha=0.2, color='#713b28')
ax.axvline(4, alpha=0.2, color='#713b28')
ax.axvline(5, alpha=0.2, color='#713b28')

plt.ylabel("Number of queries", size=15)
plt.xlabel("Stages of ConstrOpt Rewrite", size=15)
plt.text(1.4, 12, "Queries with\nconstraints", ha='center',size=12, va='center', weight='bold')
plt.text(2.5, 12, "Enumerate", ha='center',size=12, va='center', weight='bold')
plt.text(3.5, 12, "Remove\nslow rewrites", ha='center',size=10, va='center', weight='bold')
plt.text(4.5, 12, "Test", ha='center',size=12, va='center', weight='bold')
plt.text(5.5, 12, "Verify", ha='center',size=12, va='center', weight='bold')
plt.xticks([])
plt.xlim(0.7, 6.5)
plt.ylim(bottom=5, top = 30000)
plt.yscale('log', base=10)
plt.legend(prop={'size': 11}, loc='upper right')
# plt.subplots_adjust(top=0.92, bottom=5, left=0.10, right=0.95, hspace=0.25,
#                     wspace=0.35)
plt.savefig("/home/ubuntu/ConstrOpt/figures/7.3/rewrite_cnt.pdf")
