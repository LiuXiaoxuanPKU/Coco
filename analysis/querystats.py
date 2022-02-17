#constraints we can extract:
from collections import Counter
from collections import defaultdict
from collections import OrderedDict

ASC = defaultdict(int)
DESC = defaultdict(int)
#presence is defined by the number of WHERE clauses
presence = defaultdict(int)
FROM = defaultdict(int)
#represents the subset of ASC and DESC that constains a limit
DESCLIMIT = defaultdict(int)
ASCLIMIT = defaultdict(int)
ORDERBY = defaultdict(int)
#equalities are represented by equal signs
equalities = defaultdict(int)
#notequals are <>
notequals = defaultdict(int)
#joins is the total number of inner and outer joins
joins = defaultdict(int)
#inner joins and outer joins are each a subset of the total joins
innerjoin = defaultdict(int)
outerjoin = defaultdict(int)
#IN keywords
inclusion = defaultdict(int)
NOTIN = defaultdict(int)
when = defaultdict(int)
then = defaultdict(int)


with open("redmine_unique.txt") as openfileobject:
    for line in openfileobject:
        words = Counter(line.split())
        ASC[words['ASC']] += 1
        DESC[words['DESC']] += 1
        presence[words['WHERE']] += 1
        FROM[words['FROM']] += 1
        DESCLIMIT[words['DESC LIMIT']] += 1
        ASCLIMIT[words['ASC LIMIT']] += 1
        ORDERBY[words['ORDER BY']] += 1
        equalities[words['=']] += 1
        notequals[words['<>']] += 1
        joins[words['JOIN']] += 1
        innerjoin[words['INNER JOIN']] += 1
        outerjoin[words['OUTER JOIN']] += 1
        inclusion[words['IN']] += 1
        NOTIN[words['NOT IN']] += 1
        when[words['WHEN']] += 1
        then[words['THEN']] += 1

print("presence = {3: 2} says that there exactly 3 occurances of the presence constraint in exactly 2 of the queries" )
print("Presence Constraints = ", dict(OrderedDict(sorted(presence.items()))))
print("Inclusion Constraints = ", dict(OrderedDict(sorted(inclusion.items()))))

print("ASC = ", dict(OrderedDict(sorted(ASC.items()))))
print("DESC = ", dict(OrderedDict(sorted(DESC.items()))))
print("ASC LIMIT = ", dict(OrderedDict(sorted(ASCLIMIT.items()))))
print("DESC LIMIT = ", dict(OrderedDict(sorted(DESCLIMIT.items()))))
print("ORDER BY = ", dict(OrderedDict(sorted(ORDERBY.items()))))
print("equalities = ", dict(OrderedDict(sorted(equalities.items()))))
print("NOT EQUALS = ", dict(OrderedDict(sorted(notequals.items()))))
print("Total Joins = ", dict(OrderedDict(sorted(joins.items()))))
print("Inner Joins = ", dict(OrderedDict(sorted(innerjoin.items()))))
print("Outer Joins = ", dict(OrderedDict(sorted(outerjoin.items()))))
print("NOT IN = ", dict(OrderedDict(sorted(NOTIN.items()))))
print("WHEN = ", dict(OrderedDict(sorted(when.items()))))
print("THEN = ", dict(OrderedDict(sorted(then.items()))))
