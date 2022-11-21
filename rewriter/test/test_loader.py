import os
import sys
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from constraint import ForeignKeyConstraint
import loader
from config import get_path, FileType

def test_load_queries():
    filename = get_path(FileType.RAW_QUERY, "redmine")
    queries = list(loader.read_queries(filename))
    print(len(queries))
    # print(queries[0])

def test_load_constraints():
    filename = get_path(FileType.CONSTRAINT, "redmine") 
    constraints = loader.read_constraints(filename)
    db_constraints = [c for c in constraints if c.db]
    model_constraints = [c for c in constraints if not c.db]
    print(constraints[0])
    print("DB constraints: %d, Model constraints: %d" % (len(db_constraints), len(model_constraints)))

if __name__ == "__main__":
    # test_load_queries()
    test_load_constraints()
