from constraint import FormatConstraint, InclusionConstraint, LengthConstraint
import unittest
import rewrite
from constraint import UniqueConstraint
from mo_sql_parsing import parse, format


class TestRewrite(unittest.TestCase):
    def __init__(self, methodName: str = ...) -> None:
        super().__init__(methodName=methodName)
        self.unique_constraints = [UniqueConstraint("users", "name"), 
        UniqueConstraint("users", "project_id"), UniqueConstraint("projects", "id"),
        UniqueConstraint("city", "country_id"), UniqueConstraint("country", "id"),
        UniqueConstraint("customer", "city_id"), UniqueConstraint("city", "id"),
        UniqueConstraint("country", "country_name_eng")]
        self.inclusion_constraints = [
            InclusionConstraint("users", "gender", ["F", "M"])]
        self.length_constraints = [LengthConstraint("users", "name", 0, 30)]
        self.format_constraints = [
            FormatConstraint("users", "name", '[A-Za-z]')]

    def test_find_field(self):
        sql1 = "SELECT * from users where name = $1 and gender = $2 and project_id = $3"
        predicate1 = parse(sql1)['where']
        self.assertTrue(rewrite.find_field_in_predicate("name", predicate1))
        self.assertTrue(rewrite.find_field_in_predicate(
            "project_id", predicate1))
        self.assertFalse(rewrite.find_field_in_predicate("user", predicate1))
        sql2 = "SELECT * from users where name = $1 and gender = $2 or project_id = $3"
        predicate2 = parse(sql2)['where']
        self.assertTrue(rewrite.find_field_in_predicate(
            "project_id", predicate2))
        self.assertFalse(rewrite.find_field_in_predicate("id", predicate2))
        sql3 = "SELECT * from users INNER JOIN projects where users.name = $1 and users.gender = $2 or users.project_id = $3 or projects.id = $4"
        predicate3 = parse(sql3)['where']
        self.assertTrue(rewrite.find_field_in_predicate(
            "users.project_id", predicate3))
        self.assertFalse(rewrite.find_field_in_predicate(
            "project_id", predicate3))

    def test_add_limit_one_single_predicate(self):
        sql1 = "SELECT * FROM users where name = $1"
        can_rewrite1, rewrite_sql1 = rewrite.add_limit_one(
            parse(sql1), self.unique_constraints)
        self.assertTrue(can_rewrite1)
        self.assertTrue('limit' in rewrite_sql1)
        self.assertEqual(format(parse(sql1 + " LIMIT 1")),
                         format(rewrite_sql1))

        sql2 = "SELECT * FROM users where gender = $1"
        can_rewrite2, rewrite_sql2 = rewrite.add_limit_one(
            parse(sql2), self.unique_constraints)
        self.assertFalse(can_rewrite2)
        self.assertIsNone(rewrite_sql2)

    def test_add_limit_one_multiple_predicates(self):
        sql1 = "SELECT * from users where name = $1 and gender = $2"
        can_rewrite1, rewrite_sql1 = rewrite.add_limit_one(
            parse(sql1), self.unique_constraints)
        self.assertTrue(can_rewrite1)
        self.assertTrue('limit' in rewrite_sql1)
        self.assertEqual(format(parse(sql1 + " LIMIT 1")),
                         format(rewrite_sql1))

        sql2 = "SELECT * from users where name = $1 or gender = $2"
        can_rewrite2, rewrite_sql2 = rewrite.add_limit_one(
            parse(sql2), self.unique_constraints)
        self.assertFalse(can_rewrite2)
        self.assertIsNone(rewrite_sql2)

        sql3 = "SELECT * from users where age = 15 and name = $1 and gender = $2"
        can_rewrite3, rewrite_sql3 = rewrite.add_limit_one(
            parse(sql3), self.unique_constraints)
        self.assertTrue(can_rewrite3)
        self.assertTrue('limit' in rewrite_sql3)
        self.assertEqual(format(parse(sql3 + " LIMIT 1")),
                         format(rewrite_sql3))

    def test_add_limit_one_join(self):
        pass

    def test_str2int(self):
        sql1 = "SELECT * FROM users where gender = 'F'"
        can_rewrite1, rewrite_fields1 = rewrite.str2int(
            parse(sql1), self.inclusion_constraints)
        self.assertTrue(can_rewrite1)
        self.assertEqual(rewrite_fields1, ["gender"])
        sql2 = "SELECT * FROM users INNER JOIN projects\
             WHERE users.gender = 'F' and projects.id = 1"
        can_rewrite2, rewrite_fields2 = rewrite.str2int(
            parse(sql2), self.inclusion_constraints)
        self.assertTrue(can_rewrite2)
        self.assertEqual(rewrite_fields2, ["users.gender"])
        sql3 = "SELECT gender FROM users where id > 0"
        can_rewrite3, rewrite_fields3 = rewrite.str2int(
            parse(sql3), self.inclusion_constraints)
        self.assertFalse(can_rewrite3)
        self.assertEqual(len(rewrite_fields3), 0)

    def test_strlen_precheck(self):
        sql1 = "SELECT * FROM users where name = 'bob'"
        can_rewrite1, rewrite_fields1 = rewrite.strlen_precheck(
            parse(sql1), self.length_constraints)
        self.assertTrue(can_rewrite1)
        self.assertEqual(rewrite_fields1, ["name"])
        sql2 = "SELECT * FROM users where age = 10"
        can_rewrite2, rewrite_fields2 = rewrite.strlen_precheck(
            parse(sql2), self.length_constraints)
        self.assertFalse(can_rewrite2)
        self.assertEqual(len(rewrite_fields2), 0)

    def test_strformat_precheck(self):
        sql1 = "SELECT * FROM users where name = 'bob'"
        can_rewrite1, rewrite_fields1 = rewrite.strformat_precheck(
            parse(sql1), self.format_constraints)
        self.assertTrue(can_rewrite1)
        self.assertEqual(rewrite_fields1, ["name"])
        sql2 = "SELECT * FROM users where age = 10"
        can_rewrite2, rewrite_fields2 = rewrite.strformat_precheck(
            parse(sql2), self.format_constraints)
        self.assertFalse(can_rewrite2)
        self.assertEqual(len(rewrite_fields2), 0)

    def test_remove_distinct(self):
        # base case: one table, select column has unique constraint
        sql1 = "SELECT distinct(name) from users where name = $1"
        can_rewrite1, rewrite_sql1 = rewrite.remove_distinct(parse(sql1), self.unique_constraints)
        self.assertTrue(can_rewrite1)

        # base case2: one table, select multiple columns, at least one has unique constraint
        sql2 = "SELECT distinct(users.name, users.id) from users where name = $1"
        can_rewrite2, rewrite_2 = rewrite.remove_distinct(parse(sql2), self.unique_constraints)
        self.assertTrue(can_rewrite2)

        # base case3: one table, select all columns, at least one has unique constraints
        sql3 = "SELECT distinct(*) from users where name = $1"
        can_rewrite3, rewrite_3 = rewrite.remove_distinct(parse(sql3), self.unique_constraints)
        self.assertTrue(can_rewrite3)

        # no remove distinct case
        sql4 = "SELECT * from users INNER JOIN projects where projects.id = users.project_id and projects.id = 1"
        can_rewrite4, rewrite_sql4 = rewrite.remove_distinct(parse(sql4), self.unique_constraints)
        self.assertFalse(can_rewrite4)
        self.assertTrue(rewrite_sql4 == None)

        # no remove distinct case2
        sql6 = "SELECT count(name) from users where name = 'lily' LIMIT 1"
        can_rewrite6, rewrite_sql6 = rewrite.remove_distinct(parse(sql6), self.unique_constraints)
        self.assertFalse(can_rewrite6)
        self.assertTrue(rewrite_sql6 == None)

        # no remove distinct case3
        sql7 = "SELECT projects.id, project.name from users INNER JOIN projects where projects.id = users.project_id and projects.id = 1"
        can_rewrite7, rewrite_sql7 = rewrite.remove_distinct(parse(sql7), self.unique_constraints)
        self.assertFalse(can_rewrite7)
        self.assertTrue(rewrite_sql7 == None)


    def test_remove_distinct_join(self):
        # non unique column in join condition case
        sql1 = "SELECT distinct(projects.id) from users INNER JOIN projects ON projects.name = users.project_id where projects.id = 1"
        can_rewrite1, rewrite_sql1 = rewrite.remove_distinct(parse(sql1), self.unique_constraints)
        self.assertFalse(can_rewrite1)
        self.assertTrue(rewrite_sql1 == None)

        # inner join case
        sql2 = "SELECT distinct(projects.id) from users INNER JOIN projects ON projects.id = users.project_id where projects.id = 1"
        can_rewrite2, rewrite_sql2 = rewrite.remove_distinct(parse(sql2), self.unique_constraints)
        self.assertTrue(can_rewrite2)
        self.assertTrue('distinct' not in rewrite_sql2)

        # left outer join case
        sql3 = "SELECT distinct(projects.id) from projects LEFT OUTER JOIN users ON projects.id = users.project_id where projects.id = 1"
        can_rewrite3, rewrite_sql3 = rewrite.remove_distinct(parse(sql3), self.unique_constraints)
        self.assertTrue(can_rewrite3)
        self.assertTrue('distinct' not in rewrite_sql3)

        # selecting non unique columns after successful join
        sql4 = "SELECT distinct(projects.name, users.id) from users INNER JOIN projects ON projects.id = users.project_id where projects.id = 1"
        can_rewrite4, rewrite_sql4 = rewrite.remove_distinct(parse(sql4), self.unique_constraints)
        self.assertFalse(can_rewrite4)
        self.assertTrue(rewrite_sql4 == None)

        # inner join left join case 
        sql5 = "SELECT DISTINCT country.country_name_eng, city.city_name, customer.customer_name FROM country INNER JOIN city ON city.country_id = country.id LEFT OUTER JOIN customer ON customer.city_id = city.id where 1=1"
        can_rewrite5, rewrite_sql5 = rewrite.remove_distinct(parse(sql5), self.unique_constraints)
        self.assertTrue(can_rewrite5)
        self.assertTrue('distinct' not in rewrite_sql5)

        # non unique join followed by unique join
        sql5 = "SELECT DISTINCT country.country_name_eng, city.city_name, customer.customer_name FROM city LEFT OUTER JOIN customer ON customer.id = city.customer_id INNER JOIN country ON city.country_id = country.id where 1=1"
        can_rewrite5, rewrite_sql5 = rewrite.remove_distinct(parse(sql5), self.unique_constraints)
        self.assertFalse(can_rewrite5)
        self.assertTrue(rewrite_sql5 == None)

        # chained AND in ON condition
        sql6 = "SELECT distinct(projects.name, users.name) from users INNER JOIN projects ON projects.id > 0 AND users.project_id > 0 AND projects.id = users.project_id where p.id = 1"
        can_rewrite6, rewrite_sql6 = rewrite.remove_distinct(parse(sql6), self.unique_constraints)
        self.assertTrue(can_rewrite6)
        self.assertTrue('distinct' not in rewrite_sql6)

if __name__ == '__main__':
    unittest.main()
