import os
import sys
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from constraint import *
from rewriter import Rewriter
from mo_sql_parsing import parse, format


def test_get_constraints():
    constraints = [UniqueConstraint("users", "id"), UniqueConstraint("projects", "id"),
                   InclusionConstraint("users", "id", [1, 2]), UniqueConstraint("members", "name"),
                    UniqueConstraint("users", "name")]
    q_before_str = "select distinct (*) from users where id \
                        in (select distinct user_id from projects)"
    rewriter = Rewriter()
    constraints = rewriter.get_q_constraints(constraints, parse(q_before_str))
    assert(len(constraints) == 3)

def test_get_rules():
    constraints = [UniqueConstraint("users", "id"), NumericalConstraint("projects", "id", 0, 100),
                   InclusionConstraint("users", "id", [1, 2])]
    rewriter = Rewriter()
    rules = rewriter.get_rules(constraints)
    assert(len(set(rules)) == 4)

def test_rewrite_helper(constraints, q_str):
    rewriter = Rewriter()
    rewritten_queries = rewriter.rewrite(constraints, parse(q_str))
    print("------------------------Start Rewrite------------------------")
    print("Before:\n", format(parse(q_str)))
    print("After:")
    for q in rewritten_queries:
        print(q)
        print(format(q))
    print("------------------------Finish Rewrite------------------------")


def test_simple_enumerate():
    constraints = [UniqueConstraint("users", "id")]
    q_before_str = "select distinct (*) from users where id in (select distinct user_id from projects)"
    test_rewrite_helper(constraints, q_before_str)

def test_redmine_enumerate():
    constraints = [UniqueConstraint("issue_relations", "issue_from_id")]
    q_before_str = 'SELECT issue_relations.* FROM issue_relations WHERE \
                    issue_relations.issue_from_id = "$1" AND issue_relations.issue_to_id = "$2" \
                    AND issue_relations.relation_type IN ("$3", "$4")'
    test_rewrite_helper(constraints, q_before_str)

    constraints = [UniqueConstraint("projects", "id")]
    q_before_str = "SELECT projects.* FROM projects WHERE projects.status = 1 AND projects.id IN (1, 5) LIMIT 1"
    test_rewrite_helper(constraints, q_before_str)

    constraints = [UniqueConstraint("cfp", "custom_field_id")]
    q_before_str = 'SELECT custom_fields.* FROM custom_fields WHERE custom_fields.type = "$1" \
                        AND (is_for_all = True OR id IN \
                            (SELECT DISTINCT cfp.custom_field_id \
                                FROM custom_fields_projects AS cfp WHERE cfp.project_id = 16))\
                                     ORDER BY custom_fields.position ASC'
    test_rewrite_helper(constraints, q_before_str)


    constraints = [UniqueConstraint("projects", "id")]
    q_before_str = 'SELECT SUM(time_entries.hours) FROM time_entries INNER JOIN projects \
                        ON projects.id = time_entries.project_id WHERE \
                        (SELECT 1 AS one FROM enabled_modules AS em WHERE em.project_id = projects.id AND em.name = "time_tracking") IS NOT NULL'
    test_rewrite_helper(constraints, q_before_str)
            

    constraints = [UniqueConstraint("projects", "parent_id")]
    q_before_str = "SELECT MAX(projects.rgt) FROM projects WHERE projects.parent_id IS NULL AND name < 'YY'"
    test_rewrite_helper(constraints, q_before_str)
    
if __name__ == "__main__":
    test_get_constraints()
    test_get_rules()
    # test_simple_enumerate()
    test_redmine_enumerate()
