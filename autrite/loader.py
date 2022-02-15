import pickle
from mo_sql_parsing import parse, format
import json
import constraint

class Loader:
    @staticmethod
    def load_constraints(filename):
        constraints = []
        classnodes = json.load(open(filename, 'r'))
        for classnode in classnodes:
            constraints_obj = classnode['constraints']
            for obj in constraints_obj:
                c = None
                if obj["^o"] == "LengthConstraint":
                    c = constraint.LengthConstraint(
                        classnode['table'], obj['field_name'], obj['min'], obj['max'])
                elif obj["^o"] == "UniqueConstraint":
                    c = constraint.UniqueConstraint(
                        classnode['table'], obj['field_name'], obj['scope'])
                elif obj["^o"] == "PresenceConstraint":
                    c = constraint.PresenceConstraint(
                        classnode['table'], obj['field_name'])
                elif obj["^o"] == "InclusionConstraint":
                    c = constraint.InclusionConstraint(
                        classnode['table'], obj['field_name'], obj['values'])
                elif obj["^o"] == "FormatConstraint":
                    c = constraint.FormatConstraint(
                        classnode['table'], obj['field_name'], obj['format'])
                elif obj["^o"] == "NumericalConstraint":
                    c = constraint.NumericalConstraint(
                        classnode['table'], obj['field_name'], obj['min'], obj['max'], obj['allow_nil'])
                else:
                    print("[Error] Unsupport constraint type ", obj)
                    exit(1)
                constraints.append(c)
        print("======================Load %d constraints" % len(constraints))
        return constraints

    @staticmethod
    def load_queries(filename, cnt = 5):
        if filename.endswith("pk"):
            with open(filename, 'rb') as f:
                lines = pickle.load(f)
                lines = [l[1] for l in lines]
        elif filename.endswith("sql"):
            with open(filename, 'r') as f:
                lines = f.readlines()
        else:
            raise NotImplementedError("Does not support file %s as query input" % (filename))
        
        total_raw_queries = len(lines)
        lines = list(set(lines))
        unique_raw_queries = len(lines)
        print("Total # of raw queries: ", total_raw_queries)
        print("Total # of unique raw queries: ", unique_raw_queries)

        lines = lines[:cnt]
        # for i, l in enumerate(lines):
        #     print(i, l)
        q_objs = []
        fail_raw_queries = []
        for line in lines:
            try:
                q_obj = parse(line)
                print(format(q_obj))
                q_objs.append(q_obj)
            except:
                fail_raw_queries.append(line)
        print("======================[Success] Parse unique queries %d" % len(q_objs))
        print("======================[Fail] Parse %d queries" % len(fail_raw_queries))
        return q_objs
