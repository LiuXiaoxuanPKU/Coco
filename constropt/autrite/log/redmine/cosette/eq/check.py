import os

cnts = []
for filename in os.listdir("."):
  if not filename.endswith(".sql"):
    continue
  with open(filename, "r") as f:
    l = len(f.readlines())
    cnts.append(l)
    if l - 580 >= 100:
      print(l - 580, filename)
  
print(max(cnts))