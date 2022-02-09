from ast import Load
from fileinput import filename
from loader import Loader
def test_load_queries():
    filename = "../queries/redmine.pk"
    queries = list(Loader.load_queries(filename))
    print(len(queries))
    print(queries[0])

def test_load_constraints():
    filename = "../constraints/redmine"

if __name__ == "__main__":
    test_load_queries()
    test_load_constraints()