# 1. postgreSQL explain original queries --> dump execution plan
# 2. read constraints from constraints/redmine, add constraints to database
# 3. postgreSQL explain again --> dump execution plan
# 4. compare and count the number of different plans, print statistics

# Usage: python3 compare.py app_name
# Example: python3 compare.py redmine
# prerequisie: pip3 install psycopg2

import sys
import psycopg2
import pickle
import json

# read redmine queries line by line
# substitude dollar sign variables into real variables 
def scan_queries(app_name) -> list:
    query_file = "./../queries/redmine/{}.pk".format(app_name) 
    with open(query_file, "rb") as f:
        queries = pickle.load(f)
    # # make sure that all qeries are unique
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
    
def add_constraint(conn, app_name) -> list:
    cur = conn.cursor()
    f = open("test.json") # TODO: change later, use the app_name
    data = json.load(f)
    # For roll back purpose, elch element in format (table, constraint_name)
    roll_back_info = [] 
    for obj in data:
        if obj['table'] != None:
            table = obj['table']
            for constraint in obj['constraints']:
                tipe = constraint["^o"]
                if tipe == "UniqueConstraint":
                    field = constraint['field_name']
                    constraint_name = "{}_{}_{}".format(table, field, tipe)
                    roll_back_info.append((table, constraint_name))
                    unique_fields = [field] + constraint["scope"]
                    unique_fields = str(unique_fields)[1:-1]
                    sql = "ALTER TABLE {} ADD CONSTRAINT {} UNIQUE ({});".format(table, constraint_name, field)
                    print(sql)
                    cur.execute(sql)
                elif tipe == "NumericalConstraint":
                    constraint_name = "{}_{}_{}".format(table, field, tipe)
                    roll_back_info.append((table, constraint_name))
                    field = constraint['field_name']
                    if constraint["min"] != None and constraint['max'] == None:
                        sql = "ALTER TABLE {} ADD CONSTRAINT {} CHECK ({} > {});".format(table, constraint_name, field, constraint["min"])
                        print(sql)
                    elif constraint['min'] == None and constraint["max"] != None:
                        sql = "ALTER TABLE {} ADD CONSTRAINT {} CHECK ({} < {});".format(table, constraint_name, field, constraint["max"])
                        print(sql)
                    elif constraint["min"] != None and constraint["max"] != None:
                        sql = sql = "ALTER TABLE {} ADD CONSTRAINT {} CHECK ({} > {} AND {} < {});".format(
                            table, constraint_name, field, constraint["min"], field, constraint["max"])
                        print(sql)
    return roll_back_info
    



def roll_back(conn, roll_back_info):
    cur = conn.cursor()
    for table, constraint_name in roll_back_info:
        sql = "ALTER TABLE {} DROP CONSTRAINT IF EXISTS {};".format(table, constraint_name)
        print(sql)
        cur.execute(sql)

def count_diff(old_plans, new_plans):
    assert(len(old_plans) == len(new_plans))
    cnt = 0
    n = len(old_plans)
    for i in range(n):
        if old_plans[i] == new_plans[i]:
            cnt += 1
    print("out of {} queries, {} are rewrite by postgreSQD after constraints".format(n, cnt))



if __name__ == "__main__": 
    app_name = sys.argv[1]
    queries = scan_queries(app_name)
    # Connect to Database
    try:
        conn = psycopg2.connect(database="redmine", user=app_name, password="my_password")
    except ImportError:
        print("If you are using macOS with M1 chip, use conda environemnt to run.")
    # get postgreSQL query plan before adding constraints 
    old_plans = view_query_plan(queries, conn)
    # add constraints to database
    roll_back_info = add_constraint(conn, app_name)
    # get postgreSQL query plan after adding constraints
    new_plans = view_query_plan(queries, conn)
    # roll back database constraints
    roll_back(conn, roll_back_info)
    # count different query plans 
    print(old_plans, new_plans)
    count_diff(old_plans, new_plans)


    
    