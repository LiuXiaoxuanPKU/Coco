import json, random
from collections import OrderedDict
from evaluator import Evaluator

def generate_query_params(queries, connect_str):
    def get_field_value(table_field):
        if table_field.startswith("LOWER"):
            table_field = table_field[6:-1]
        table, field = table_field.split('.')
        SQL = "SELECT %s FROM %s ORDER BY RANDOM() LIMIT 1" % (table_field, table)
        ret =  Evaluator.evaluate_query(SQL, connect_str)
        return ret

    def generate_single(q):
        if '$' not in q:
            return q
        tokens = q.split(" ")
        for i, token in enumerate(tokens):
            if '$' in token:
                if tokens[i-1] == "LIMIT":
                    tokens[i] = str(random.randint(0, 10))
                elif tokens[i-1] == "OFFSET":
                    tokens[i] = "1"
                elif tokens[i-1] in ["=", '!=', '>', '<']:
                    re = get_field_value(tokens[i-2])
                    if len(re) == 0 or re[0][0] is None:
                        return None
                    tokens[i] = re[0][0]
                    if isinstance(tokens[i], str):
                        tokens[i] = "'" + tokens[i] + "'"
                    else:
                        tokens[i] = str(tokens[i])
                elif tokens[i-1] == "IN":
                    end_idx = i
                    while ")" not in tokens[end_idx]:
                        end_idx += 1
                    for j in range(i, end_idx + 1):
                        re = get_field_value(tokens[i-2])
                        if len(re) == 0 or re[0][0] is None:
                            return None
                        tokens[j] = re[0][0]
                        if isinstance(tokens[j], str):
                            tokens[j] = "'" + tokens[j] + "'"
                        else:
                            tokens[j] = str(tokens[j])
                        tokens[j] += ","
                    tokens[i] = "(" + tokens[i]
                    tokens[end_idx] =  tokens[end_idx][:-1] + ")"
        q = " ".join(tokens)
        return q

    param_qs = []
    for q in queries:
        q_param = generate_single(q)
        if q_param is not None:
            param_qs.append(q_param)
    return param_qs

class GlobalExpRecorder:
    def __init__(self):
        self.val_dict = OrderedDict()

    def record(self, key, value):
        self.val_dict[key] = value

    def dump(self, filename):
        with open(filename, "a") as fout:
            fout.write(json.dumps(self.val_dict) + '\n')
        print("Save exp results to %s" % filename)

    def clear(self):
        pass


exp_recorder = GlobalExpRecorder()