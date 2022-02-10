import os
import sys
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from constraint import *
from rewriter import Rewriter
from mo_sql_parsing import parse, format

def test_simple_enumerate():
    constraints = [UniqueConstraint("users", "id")]
    q_before_str = "select distinct (*) from users where id in (select distinct user_id from projects)"
    q_before = parse(q_before_str)
    rewriter = Rewriter()
    rewritten_queries = rewriter.rewrite(constraints, q_before)
    print("Before ", format(q_before))
    print("After")
    for q in rewritten_queries:
        print(format(q))

def test_redmine_enumerate():
    constraint = UniqueConstraint("users", "id")
    query_before = "SELECT DISTINCT users.* FROM users \
                    INNER JOIN members ON members.user_id = users.id \
                    WHERE users.status = $1 AND (members.project_id = 1) \
                        AND users.status = $2 AND users.status = $3 AND users.type IN ($4, $5) \
                    ORDER BY users.type DESC, users.firstname, users.lastname, users.id"
            
if __name__ == "__main__":
    test_simple_enumerate()
    # test_redmine_enumerate()
