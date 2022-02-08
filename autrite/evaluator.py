import psycopg2

class Evaluator:
    @staticmethod
    def evaluate(q, connect_string):
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
    def evaluate_batch(q_list, connect_string):
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
