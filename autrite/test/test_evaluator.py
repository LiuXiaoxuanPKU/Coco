import os, sys
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from evaluator import Evaluator
import psycopg2

CONNECT_STRING = "user=postgres password=insertpasswordhere"

def test_evaluate():
    eva = Evaluator()
    q = "SELECT * FROM a as a1 INNER JOIN a as a2 ON a1.name = a2.name"
    assert(eva.evaluate(q, CONNECT_STRING) == 26.48)

def test_evaluate_batch():
    eva = Evaluator()
    q_list = ["SELECT * FROM a as a1 INNER JOIN a as a2 ON a1.name = a2.name",
    "SELECT * FROM a",
    "SELECT a2.name FROM a as a1 INNER JOIN a as a2 ON a1.product_id = a2.user_id"]
    assert(eva.evaluate_batch(q_list, CONNECT_STRING) == [26.48, 11.4, 26.48])

if __name__ == "__main__":
    with psycopg2.connect(CONNECT_STRING) as conn:
        with conn.cursor() as cur:
            cur.execute("""CREATE TABLE IF NOT EXISTS a (
                user_id INTEGER NOT NULL,
                product_id INTEGER NOT NULL,
                name VARCHAR(255) NOT NULL,
                PRIMARY KEY(user_id, product_id)
            )""")
            conn.commit()
            cur.close()
    test_evaluate()
    test_evaluate_batch()