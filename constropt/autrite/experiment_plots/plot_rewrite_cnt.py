import seaborn as sns 
import matplotlib.pyplot as plt

redmine = [
    2950, # qs with constraints
    1674, # qs with rewritten
    1208, # qs with lower cost
    1103, # qs with lower cost and pass tests
    124   # qs get verified
]

forem = [
   4772, # qs with constraints
   381, # qs with rewritten
   159, # qs with lower cost
   122, # qs with lower cost and pass tests
   29   # qs get verified 
]

openproject = [
   13125, # qs with constraints
   8262, # qs with rewritten
   0, # qs with lower cost
   0, # qs with lower cost and pass tests
   0   # qs get verified 
]

spree = [
   1163, # qs with constraints
   656, # qs with rewritten
   593, # qs with lower cost
   561, # qs with lower cost and pass tests
   459   # qs get verified 
]

mastodon = [
   6955, # qs with constraints
   984, # qs with rewritten
   803, # qs with lower cost
   435, # qs with lower cost and pass tests
   65   # qs get verified 
]

openstreetmap = [
   4836, # qs with constraints
   136, # qs with rewritten
   101, # qs with lower cost
   76, # qs with lower cost and pass tests
   25   # qs get verified 
]

fig, ax = plt.subplots()
fig.set_size_inches(9, 6)
    
x = [1, 2, 3, 4, 5, 6]
BLUE = "#1AA7EC"
YELLOW = "#f7b50c"
ORANGE = "#de8004"
GREEN = "#28a81d"
PURPLE = "#d822f0"
RED = "#e3272d"
colors = [BLUE, YELLOW, ORANGE, GREEN, PURPLE, RED]
data = {'Redmine': redmine, 'Dev.to' : forem, 'Openproject' : openproject,
        'Mastodon': mastodon, 'Openstreetmap': openstreetmap, 'Spree': spree} 
patches = []
for i, k in enumerate(data):
    patches.append(plt.stairs(data[k], x, baseline=None, label=k, \
                  lw=4, ls = "-", color = colors[i]))
    
# ============= four vertical dividing bars ============
ax.axvline(2, alpha=0.2, color='#713b28')
ax.axvline(3, alpha=0.2, color='#713b28')
ax.axvline(4, alpha=0.2, color='#713b28')
ax.axvline(5, alpha=0.2, color='#713b28')

plt.ylabel("Number of queries", size=17)
plt.xlabel("Stages of ConstrOpt Rewrite", size=17)
plt.text(1.4, 8, "Queries with\nconstraints", ha='center',size=12, va='center', weight='bold')
plt.text(2.5, 8, "Enumerate", ha='center',size=12, va='center', weight='bold')
plt.text(3.5, 8, "Remove\nslow rewrites", ha='center',size=11, va='center', weight='bold')
plt.text(4.5, 8, "Test", ha='center',size=12, va='center', weight='bold')
plt.text(5.5, 8, "Verify", ha='center',size=12, va='center', weight='bold')
plt.xticks([])
plt.xlim(0.7, 6.5)
plt.ylim(bottom=5, top = 30000)
plt.yscale('log', base=10)
plt.legend(prop={'size': 10}, loc='upper right')
# plt.subplots_adjust(top=0.92, bottom=5, left=0.10, right=0.95, hspace=0.25,
#                     wspace=0.35)
plt.savefig("/home/ubuntu/ConstrOpt_warning_suppress/figures/7.3/rewrite_cnt.png")
