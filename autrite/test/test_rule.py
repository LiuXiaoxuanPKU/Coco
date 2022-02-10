import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from constraint import NumericalConstraint
from rule import AddLimitOne, RemoveDistinct, AddPredicate
from mo_sql_parsing import parse, format

def test_q_obj(q_obj, q_str):
    q_str = format(parse(q_str))
    if format(q_obj) != q_str:
        print("Expect ", q_str)
        print("Get ", format(q_obj))
    assert(format(q_obj) == q_str)

def test_add_limit_one_select_from():
    print("===============Add Limit One=================")
    q_before_str = "select * from R"
    q_after_str = "select * from R limit 1"
    q_before = parse(q_before_str)
    q_afters = AddLimitOne([]).apply(q_before)
    assert(len(q_afters) == 1)
    q_after = q_afters[0]
    test_q_obj(q_after, q_after_str)

    q_before_str = "select * from (select * from R where id = 2) where a = 1"
    q_before = parse(q_before_str)
    q_afters = AddLimitOne([]).apply(q_before)
    assert(len(q_afters) == 3)
    print("Before: ", format(q_before))
    print("After: ")
    for q in q_afters:
        print(format(q))

    print("--------------")
    q_before_str = "select (select * from R where id = 2) from R where a = 1"
    q_before = parse(q_before_str)
    q_afters = AddLimitOne([]).apply(q_before)
    assert(len(q_afters) == 3)
    print("Before: ", format(q_before))
    print("After: ")
    for q in q_afters:
        print(format(q))
    
    print("--------------")
    q_before_str = "select (select * from R where id = 2) from (select * from R where id = 3) where a = 1"
    q_before = parse(q_before_str)
    q_afters = AddLimitOne([]).apply(q_before)
    assert(len(q_afters) == 7)
    print("Before: ", format(q_before))
    print("After: ")
    for q in q_afters:
        print(format(q))

def test_add_limit_one_where_having():
    q_before_str = "select * from R1 where a in (select a from R2) and a > 1"
    q_before = parse(q_before_str)
    print("Before: ", format(q_before))
    print("After: ")
    q_afters = AddLimitOne([]).apply(q_before)
    assert(len(q_afters) == 3)
    for q in q_afters:
        print(format(q))
    
    print("--------------")
    q_before_str = "select * from R1 where a in (select a from R2) and b in (select b from R3)"
    q_before = parse(q_before_str)
    print("Before: ", format(q_before))
    print("After: ")
    q_afters = AddLimitOne([]).apply(q_before)
    assert(len(q_afters) == 7)
    for q in q_afters:
        print(format(q))

    print("---------------")
    q_before_str = "select * from R1 group by b having c > (select c from R2)"
    q_before = parse(q_before_str)
    print("Before: ", format(q_before))
    print("After: ")
    q_afters = AddLimitOne([]).apply(q_before)
    assert(len(q_afters) == 3)
    for q in q_afters:
        print(format(q))


def test_remove_distinct_select_from():
    print("===============Remove Distinct=================")
    q_before_str = "select distinct(*) from (select distinct(*) from R) where a = 1"
    q_before = parse(q_before_str)
    print("Before: ", format(q_before))
    print("After: ")
    q_afters = RemoveDistinct([]).apply(q_before)
    assert(len(q_afters) == 3)
    for q in q_afters:
        print(format(q))

    print("--------------")
    q_before_str = "select distinct(select distinct * from R1) from (select distinct(*) from R2) where a = 1"
    q_before = parse(q_before_str)
    print("Before: ", format(q_before))
    print("After: ")
    q_afters = RemoveDistinct([]).apply(q_before)
    assert(len(q_afters) == 7)
    for q in q_afters:
        print(format(q))

def test_add_limit_one_exist():
    pass

def test_add_predicate_simple():
    print("===============Add Predicate=================")
    q_before_str = "select * from R where a > b"
    q_before = parse(q_before_str)
    c = NumericalConstraint("R", "a", 0, 100)
    print("Before: ", format(q_before))
    print("After: ")
    q_afters = AddPredicate([c]).apply(q_before)
    # assert(len(q_afters) == 1)
    for q in q_afters:
        print(format(q))

    print("--------------")
    q_before_str = "select * from R where a > b and a > c"
    q_before = parse(q_before_str)
    c = NumericalConstraint("R", "a", 0, 100)
    print("Before: ", format(q_before))
    print("After: ")
    q_afters = AddPredicate([c]).apply(q_before)
    # assert(len(q_afters) == 1)
    for q in q_afters:
        print(format(q))

    print("--------------")
    q_before_str = "select * from R where a > b or a < c"
    # select * from R where (a > b and b < 100) or a < c
    # select * from R where a > b or (a < c and c > 0)
    q_before = parse(q_before_str)
    c = NumericalConstraint("R", "a", 0, 100)
    print("Before: ", format(q_before))
    print("After: ")
    q_afters = AddPredicate([c]).apply(q_before)
    # assert(len(q_afters) == 1)
    for q in q_afters:
        print(format(q))

if __name__ == "__main__":
    # test_add_limit_one_select_from()
    # test_remove_distinct_select_from()
    # test_add_limit_one_where_having()
    test_add_predicate_simple()
