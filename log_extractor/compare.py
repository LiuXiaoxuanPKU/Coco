# 1. postgreSQL explain original queries --> get execution plan
# 2. read constraints from constraints/redmine, add constraints to database
# 3. postgreSQL explain again --> get execution plan
# 4. compare and count the number of different plans, print statistics

# Usage: python3 compare.py app_name
# Example: python3 compare.py redmine
# prerequisie: pip3 install psycopg2; if you are using M1 chip, use conda environment: conda install psycopg2

import sys
import psycopg2
import pickle
import json
sys.path.append('./../autrite')
import benchmark
import loader
import constraint


# return queries in example_app.pk file 
def scan_queries() -> list:
    filename = "../queries/redmine/redmine.pk"
    queries = loader.Loader.load_queries_raw(filename, cnt=1)
    queries = benchmark.generate_query_params(queries)
    # make sure that all qeries are unique
    queries = list(set(queries))
    return queries

# return a list of dumped query plan from postgreSQL EXPLAIN
def view_query_plan(queries, conn) -> list:
    cur = conn.cursor()
    plans = []
    for q in queries:
        cur.execute("explain {};".format(q))
        plans.append(cur.fetchall()[0])
    return plans

# read in constraints
def load_constraints(constraint_file) -> list:
    constraints = loader.Loader.load_constraints(constraint_file)
    return constraints

# add constraints to database 
def add_constraint(constraints) -> list:
    cur = conn.cursor()
    # For roll back purpose, elch element in format (table, constraint_name)
    roll_back_info = [] 
    for c in constraints:
        if isinstance(c, constraint.UniqueConstraint):
            constraint_name = "unique_%s_%s" % (c.table, c.field) 
            roll_back_info.append(constraint_name)
            fields = [c.field] + c.scope
            fields = str(fields)[1:-1]
            sql = "ALTER TABLE {} ADD CONSTRAINT {} UNIQUE ({});".format(
                c.table, constraint_name, fields)
        elif isinstance(c, constraint.PresenceConstraint):
            constraint_name = "present_%s_%s" % (c.table, c.field)
            roll_back_info.append(constraint_name)
            sql = "ALTER TABLE {} ADD CONSTRAINT {} UNIQUE ({});".format(c.table, constraint_name, c.field)
        elif isinstance(c, constraint.NumericalConstraint):
            constraint_name = "numerical_%s_%s" % (c.table, c.field)
            roll_back_info.append(constraint_name)
            if c.min is not None and c.max is None:
                sql = "ALTER TABLE {} ADD CONSTRAINT {} CHECK ({} > {});".format(
                    c.table, constraint_name, c.field, c.min)
            elif c.min is None and c.max is not None:
                sql = "ALTER TABLE {} ADD CONSTRAINT {} CHECK ({} < {});".format(
                    c.table, constraint_name, c.field, c.max)
            else:
                sql = "ALTER TABLE {} ADD CONSTRAINT {} CHECK ({} > {} AND {} < {});".format(
                    c.table, constraint_name, c.field, c,min, c.field, c.max)
        print(sql)
        cur.execute(sql)
    return roll_back_info
    



def roll_back(conn, roll_back_info):
    conn.rollback()
    # for table, constraint_name in roll_back_info:
    #     sql = "ALTER TABLE {} DROP CONSTRAINT IF EXISTS {};".format(table, constraint_name)
    #     print(sql)
    #     cur.execute(sql)

def count_diff(old_plans, new_plans):
    assert(len(old_plans) == len(new_plans))
    cnt = 0
    n = len(old_plans)
    for i in range(n):
        if old_plans[i] != new_plans[i]:
            cnt += 1
    print("out of {} queries, {} are rewrite by postgreSQD after constraints".format(n, cnt))



if __name__ == "__main__": 
    app_name = sys.argv[1]
    queries = scan_queries()
    # Connect to Database
    try:
        conn = psycopg2.connect(database="redmine", user=app_name, password="my_password")
    except ImportError:
        print("If you are using macOS with M1 chip, use conda environemnt to run.")
    # get postgreSQL query plan before adding constraints 
    old_plans = view_query_plan(queries, conn)
    # read in constraints, "./../constraints/redmine"
    constraints = load_constraints("test.json")
    # add constraints to database
    roll_back_info = add_constraint(constraints)
    # get postgreSQL query plan after adding constraints
    new_plans = view_query_plan(queries, conn)
    # roll back database constraints
    roll_back(conn, roll_back_info)
    # count different query plans 
    count_diff(old_plans, new_plans)
    conn.commit()
    conn.close()


    
    