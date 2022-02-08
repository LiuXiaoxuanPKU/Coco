from rule import AddLimitOne, RemoveDistinct
from mo_sql_parsing import parse, format

def test_q_obj(q_obj, q_str):
    q_str = format(parse(q_str))
    if format(q_obj) != q_str:
        print("Expect ", q_str)
        print("Get ", format(q_obj))
    assert(format(q_obj) == q_str)

def test_add_limit_one():
    print("===============Add Limit One=================")
    q_before_str = "select * from R"
    q_after_str = "select * from R limit 1"
    q_before = parse(q_before_str)
    q_afters = AddLimitOne.apply(q_before)
    assert(len(q_afters) == 1)
    q_after = q_afters[0]
    test_q_obj(q_after, q_after_str)

    q_before_str = "select * from (select * from R where id = 2) where a = 1"
    q_before = parse(q_before_str)
    q_afters = AddLimitOne.apply(q_before)
    assert(len(q_afters) == 3)
    print("Before: ", format(q_before))
    print("After: ")
    for q in q_afters:
        print(format(q))


def test_remove_distinct():
    print("===============Remove Distinct=================")
    q_before_str = "select distinct(*) from (select distinct(*) from R) where a = 1"
    q_before = parse(q_before_str)
    q_afters = RemoveDistinct.apply(q_before)
    assert(len(q_afters) == 3)
    for q in q_afters:
        print(format(q))

if __name__ == "__main__":
    test_add_limit_one()
    test_remove_distinct()
