import json

queries = json.load(open("old_prove.json"))
prove_sqls = []
for q in queries:
    if q['rewrite_type'] not in ['string_to_int', 'strprecheck', 'lenprecheck']:
        prove_sqls.append(q["src"])

with open("prove.sql", "w") as f:
    for q in prove_sqls:
        f.write(q + "\n")