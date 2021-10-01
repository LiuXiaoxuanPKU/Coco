import unittest
import rewrite
from constraint import UniqueConstraint
from mo_sql_parsing import parse, format


class TestRewrite(unittest.TestCase):
    def __init__(self, methodName: str = ...) -> None:
        super().__init__(methodName=methodName)
        self.constraints = [UniqueConstraint("users", "name")]

    def test_add_limit_one_single_predicate(self):
        sql1 = "SELECT * FROM users where name = $1"
        can_rewrite1, rewrite_sql1 = rewrite.add_limit_one(
            parse(sql1), self.constraints)
        self.assertTrue(can_rewrite1)
        self.assertTrue('limit' in rewrite_sql1)
        self.assertEqual(format(parse(sql1 + " LIMIT 1")),
                         format(rewrite_sql1))

        sql2 = "SELECT * FROM users where gender = $1"
        can_rewrite2, rewrite_sql2 = rewrite.add_limit_one(
            parse(sql2), self.constraints)
        self.assertFalse(can_rewrite2)
        self.assertIsNone(rewrite_sql2)

    def test_add_limit_one_multiple_predicates(self):
        sql1 = "SELECT * from users where name = $1 and gender = $2"
        can_rewrite1, rewrite_sql1 = rewrite.add_limit_one(
            parse(sql1), self.constraints)
        self.assertTrue(can_rewrite1)
        self.assertTrue('limit' in rewrite_sql1)
        self.assertEqual(format(parse(sql1 + " LIMIT 1")),
                         format(rewrite_sql1))

        sql2 = "SELECT * from users where name = $1 or gender = $2"
        can_rewrite2, rewrite_sql2 = rewrite.add_limit_one(
            parse(sql2), self.constraints)
        self.assertFalse(can_rewrite2)
        self.assertIsNone(rewrite_sql2)

        sql3 = "SELECT * from users where age = 15 and name = $1 and gender = $2"
        can_rewrite3, rewrite_sql3 = rewrite.add_limit_one(
            parse(sql3), self.constraints)
        self.assertTrue(can_rewrite3)
        self.assertTrue('limit' in rewrite_sql3)
        self.assertEqual(format(parse(sql3 + " LIMIT 1")),
                         format(rewrite_sql3))

    def test_add_limit_join(self):
        pass


if __name__ == '__main__':
    unittest.main()
