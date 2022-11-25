import psycopg2
import re

JIT = "on"
class Evaluator:
    @staticmethod
    def evaluate_query(q, connect_string):
        # Connect to an existing database
        with psycopg2.connect(connect_string) as conn:
            # Open a cursor to perform database operations
            with conn.cursor() as cur:
                # Execute a command: explain query
                cur.execute(q)
                # Fetch result
                if cur.description is not None:
                    explain_fetched = cur.fetchall()
                else: # no results to fetch
                    explain_fetched  = []
                cur.close()
                return explain_fetched

    @staticmethod
    def evaluate_actual_time(q, connect_string, repeat=1, jit=False):
        if jit:
            JIT = True
        else:
            JIT = False
        # Connect to an existing database
        with psycopg2.connect(connect_string) as conn:
            # Open a cursor to perform database operations
            with conn.cursor() as cur:
                # Execute a command: explain query
                cur.execute("set jit=%s" % JIT)
                rows = 0
                def execute(q):
                    cur.execute("EXPLAIN ANALYZE " + q)
                    result = cur.fetchall()
                    nonlocal rows
                    rows = int(re.search(r"\(actual time=.* rows=(\d+).*\)", result[0][0]).group(1))
                    return float(result[-1][0].split(':')[-1].split('ms')[0])
                return sum(execute(q) for _ in range(repeat)) / repeat, rows

    @staticmethod
    def evaluate_cost(q, connect_string):
        # Connect to an existing database
        with psycopg2.connect(connect_string) as conn:
            # Open a cursor to perform database operations
            with conn.cursor() as cur:
                # Execute a command: explain query
                cur.execute("EXPLAIN " + q)
                # Fetch result
                explain_fetched = cur.fetchone()
                # Parse cost
                cost = float(explain_fetched[0].split('(')[1].split('..')[1].split(' ')[0])
                cur.close()
                return cost

    @staticmethod
    def evaluate_cost_batch(q_list, connect_string):
        # Connect to an existing database
        with psycopg2.connect(connect_string) as conn:
            # Open a cursor to perform database operations
            with conn.cursor() as cur:
                costs = []
                for q in q_list:
                    # Execute a command: explain query
                    cur.execute("EXPLAIN " + q)
                    # Fetch results
                    explain_fetched = cur.fetchone()
                    # Parse cost
                    costs.append(float(explain_fetched[0].split('(')[1].split('..')[1].split(' ')[0]))
                cur.close()
                return costs
