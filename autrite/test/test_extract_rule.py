import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from constraint import InclusionConstraint
from extract_rule import ExtractInclusionRule
from mo_sql_parsing import parse, format
import unittest

class TestInclusionConstraintQuery(unittest.TestCase):

    def test_non_example_naive(self):
        cs = [InclusionConstraint("auth_sources", "fake_column", [])]
        q = "SELECT 1 AS one FROM auth_sources LIMIT 1"
        q = parse(q)
        extracted = ExtractInclusionRule(cs).apply(q)
        self.assertTrue(len(extracted) == 0)

    def test_where_naive(self):
        cs = [InclusionConstraint("attachments", "disk_filename", [])]
        q = "SELECT 1 AS one FROM attachments WHERE disk_filename = '060719210727_archive.zip'"
        q = parse(q)
        extracted = ExtractInclusionRule(cs).apply(q)
        self.assertTrue(len(extracted) == 1)

    def test_where_and(self):
        cs = [InclusionConstraint("attachments", "disk_filename", [])]
        q = "SELECT 1 AS one FROM attachments WHERE disk_filename = '060719210727_archive.zip' AND id <> 21 LIMIT 1"
        q = parse(q)
        extracted = ExtractInclusionRule(cs).apply(q)
        self.assertTrue(len(extracted) == 1)

    def test_select_distinct(self):
        cs = [InclusionConstraint("attachments", "filename", [])]
        q = "SELECT DISTINCT attachments.filename AS alias_0, projects.id FROM projects LEFT OUTER JOIN attachments ON attachments.container_id = projects.id AND attachments.container_type = 1 WHERE projects.id = 2 ORDER BY attachments.filename ASC LIMIT 3"
        q = parse(q)
        extracted = ExtractInclusionRule(cs).apply(q)
        self.assertTrue(len(extracted) == 1)

    def test_join(self):
        cs = [InclusionConstraint("projects", "id", [])]
        q = "SELECT DISTINCT attachments.filename AS alias_0, projects.id FROM projects LEFT OUTER JOIN attachments ON attachments.container_id = projects.id AND attachments.container_type = 1 WHERE projects.id = 2 ORDER BY attachments.filename ASC LIMIT 3"
        q = parse(q)
        extracted = ExtractInclusionRule(cs).apply(q)
        self.assertTrue(len(extracted) == 1)

    def test_on(self):
        cs = [InclusionConstraint("attachments", "container_id", [])]
        q = "SELECT DISTINCT attachments.filename AS alias_0, projects.id FROM projects LEFT OUTER JOIN attachments ON attachments.container_id = projects.id AND attachments.container_type = 1 WHERE projects.id = 2 ORDER BY attachments.filename ASC LIMIT 3"
        q = parse(q)
        extracted = ExtractInclusionRule(cs).apply(q)
        self.assertTrue(len(extracted) == 1)

    def test_order_by(self):
        cs = [InclusionConstraint("attachments", "butterfly", [])]
        q = "SELECT DISTINCT attachments.filename AS alias_0, projects.id FROM projects LEFT OUTER JOIN attachments ON attachments.container_id = projects.id AND attachments.container_type = 1 WHERE projects.id = 2 ORDER BY attachments.butterfly ASC LIMIT 3"
        q = parse(q)
        extracted = ExtractInclusionRule(cs).apply(q)
        self.assertTrue(len(extracted) == 1)

    def test_subquery(self):
        cs = [InclusionConstraint("projects", "id", [])]
        q = "SELECT 1 AS one FROM enabled_modules WHERE enabled_modules.project_id IN (SELECT projects.id FROM projects WHERE projects.status <> 9 AND projects.is_public = True AND projects.id NOT IN (SELECT project_id FROM members WHERE user_id IN (74, 12))) AND enabled_modules.name = 1 LIMIT 2"
        q = parse(q)
        extracted = ExtractInclusionRule(cs).apply(q)
        self.assertTrue(len(extracted) == 1)

if __name__ == "__main__":
    unittest.main()