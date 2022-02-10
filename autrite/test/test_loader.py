import os
import sys
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from loader import Loader
def test_load_queries():
    filename = "../../queries/redmine.pk"
    queries = list(Loader.load_queries(filename))
    print(len(queries))
    print(queries[0])

def test_load_constraints():
    filename = "../../constraints/redmine"
    constraints = Loader.load_constraints(filename)
    print(constraints[0])

if __name__ == "__main__":
    test_load_queries()
    test_load_constraints()
