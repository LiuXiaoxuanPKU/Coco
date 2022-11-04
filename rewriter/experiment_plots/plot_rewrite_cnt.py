import seaborn as sns 
import matplotlib.pyplot as plt

redmine = [
    2861, # qs with constraints
    1830, # qs with rewritten
    1464, # qs with lower cost
    1294, # qs with lower cost and pass tests
    286   # qs get verified
]

forem = [
   4411, # qs with constraints
   461, # qs with rewritten
   165, # qs with lower cost
   124, # qs with lower cost and pass tests
   29   # qs get verified 
]

openproject = [
   10676, # qs with constraints
   8817, # qs with rewritten
   4687, # qs with lower cost
   4329, # qs with lower cost and pass tests
   709   # qs get verified 
]

spree = [
   1143, # qs with constraints
   3503, # qs with rewritten
   1616, # qs with lower cost
   149, # qs with lower cost and pass tests
   12   # qs get verified 
]

mastodon = [
   6936, # qs with constraints
   1040, # qs with rewritten
   345, # qs with lower cost
   345, # qs with lower cost and pass tests
   22   # qs get verified 
]

openstreetmap = [
   4830, # qs with constraints
   170, # qs with rewritten
   131, # qs with lower cost
   102, # qs with lower cost and pass tests
   17   # qs get verified 
]

fig, ax = plt.subplots()
fig.set_size_inches(8, 4)
    
x = [1,2,3,4, 5, 6]
colors = ["#1AA7EC", "#713b28", "#FF847C", "green", "purple", "black"]
data = {'Redmine': redmine, 'Dev.to' : forem, 'Openproject' : openproject,
        'Mastodon': mastodon, 'Openstreetmap': openstreetmap, 'Spree': spree} 
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
plt.savefig("/home/ubuntu/ConstrOpt/figures/7.3/rewrite_cnt.png")
