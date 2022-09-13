from ctypes.wintypes import SIZE
import matplotlib.pyplot as plt

redmine = [
    2950, # qs with constraints
    1674, # qs with rewritten
    1208, # qs with lower cost
    1103, # qs with lower cost and pass tests
    775   # qs get verified
]

forem = [
   4772, # qs with constraints
   381, # qs with rewritten
   159, # qs with lower cost
   122, # qs with lower cost and pass tests
   45   # qs get verified 
]

openproject = [
   10676, # qs with constraints
   8817, # qs with rewritten
   4687, # qs with lower cost
   4329, # qs with lower cost and pass tests
   709   # qs get verified 
]

spree = [
   1163, # qs with constraints
   656, # qs with rewritten
   593, # qs with lower cost
   561, # qs with lower cost and pass tests
   462   # qs get verified 
]

mastodon = [
   6955, # qs with constraints
   984, # qs with rewritten
   803, # qs with lower cost
   435, # qs with lower cost and pass tests
   68   # qs get verified 
]

openstreetmap = [
   4836, # qs with constraints
   136, # qs with rewritten
   101, # qs with lower cost
   76, # qs with lower cost and pass tests
   38   # qs get verified 
]

fig, ax = plt.subplots()
fig.set_size_inches(9, 8)
    
x = [1, 2, 3, 4, 5, 6]
BLUE = "#1AA7EC"
BLACK = "#453020"
ORANGE = "#de8004"
GREEN = "#28a81d"
PURPLE = "#955df5"
RED = "#e3272d"
colors = {'Redmine':ORANGE, 'Dev.to': BLUE, 'Openproject': RED, 'Mastodon': BLACK, 'Openstreetmap': GREEN, 'Spree': PURPLE}
data = {'Dev.to' : forem, 'Redmine': redmine, 'Openstreetmap': openstreetmap, 'Openproject' : openproject,
        'Spree': spree, 'Mastodon': mastodon, } 
patches = []
for k in data:
    patches.append(plt.stairs(data[k], x, baseline=None, label=k, \
                  lw=4, ls = "-", color = colors[k]))
    
# ============= four vertical dividing bars ============
ax.axvline(2, alpha=0.2, color='#713b28')
ax.axvline(3, alpha=0.2, color='#713b28')
ax.axvline(4, alpha=0.2, color='#713b28')
ax.axvline(5, alpha=0.2, color='#713b28')

# ============= add text explainations =================
axis_font = {'size': 17}
text_font = {'y': 16, 'size': 12, 'weight': 'bold', 'ha': 'center', 'va': 'center'}
qs_w_cs_font = {'x': 1.45, 'size': 11, 'ha': 'center', 'va': 'center'}
enumerate_font = {'x': 2.5, 'size': 11, 'ha': 'center', 'va': 'center'}
rm_slow_font = {'x': 3.5, 'size': 11, 'ha': 'center', 'va': 'center'}
test_font = {'x': 4.5, 'size': 11, 'ha': 'center', 'va': 'center'}
verify_font = {'x': 5.5, 'size': 11, 'ha': 'center', 'va': 'center'}

plt.ylabel("Number of queries", **axis_font)
plt.xlabel("Stages of ConstrOpt Rewrite", **axis_font)

plt.text(1.45, s="Queries with\nconstraints", **text_font)
plt.text(2.5, s= "Enumerate", **text_font)
plt.text(3.5, s="Remove\nslow rewrites", **text_font)
plt.text(4.5, s="Test", **text_font)
plt.text(5.5, s="Verify", **text_font)

# ============ queries with constraints =============
plt.text(y=12100, s="10676", **qs_w_cs_font) # openproject
plt.text(y=7800, s="6955", **qs_w_cs_font) # mastodon
plt.text(y=5400, s="4836", **qs_w_cs_font) # openstreetmap
plt.text(y=3300, s="2950", **qs_w_cs_font) # redmine
plt.text(y=1300, s="1163", **qs_w_cs_font) # spree

# ============ enumeration =================
plt.text(y=10000, s="8817", **enumerate_font) # openproject
plt.text(y=1850, s="1674", **enumerate_font) # redmine
plt.text(y=1100, s="984", **enumerate_font) # mastodon
plt.text(y=750, s="656", **enumerate_font) # spree
plt.text(y=430, s="381", **enumerate_font) # dev.to
plt.text(y=150, s="136", **enumerate_font) # openstreetmap

# ============ remove slow rewrites =================
plt.text(y=5400, s="4687", **rm_slow_font) # openproject
plt.text(y=1345, s="1208", **rm_slow_font) # redmine
plt.text(y=880, s="803", **rm_slow_font) # mastodon
plt.text(y=680, s="593", **rm_slow_font) # spree
plt.text(y=180, s="159", **rm_slow_font) # dev.to
plt.text(y=110, s="101", **rm_slow_font) # openstreetmap

# ============ test =================
plt.text(y=5100, s="4329", **test_font) # openproject
plt.text(y=1295, s="1103", **test_font) # redmine
plt.text(y=670, s="561", **test_font) # mastodon
plt.text(y=480, s="435", **test_font) # spree
plt.text(y=140, s="122", **test_font) # dev.to
plt.text(y=85, s="76", **test_font) # openstreetmap

# ============ verify =================
plt.text(y=850, s="775", **verify_font) # openproject
plt.text(y=620, s="709", **verify_font) # redmine
plt.text(y=400, s="462", **verify_font) # mastodon
plt.text(y=75, s="68", **verify_font) # spree
plt.text(y=50, s="45", **verify_font) # dev.to
plt.text(y=32, s="38", **verify_font) # openstreetmap

plt.xticks([])  # supress x axis labels
plt.xlim(0.9, 6.2)
plt.ylim(bottom=10, top = 30000)
plt.yscale('log', base=10)
plt.legend(prop={'size': 10}, loc='upper right')
plt.savefig("/home/ubuntu/ConstrOpt_warning_suppress/figures/7.3/rewrite_cnt.png")
plt.savefig("/home/ubuntu/ConstrOpt_warning_suppress/figures/7.3/rewrite_cnt.pdf")
