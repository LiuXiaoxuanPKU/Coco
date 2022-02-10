import pickle
import json
import constraint

class Loader:
    @staticmethod
    def load_constraints(filename):
        constraints = []
        classnodes = json.load(open(filename, 'r'))
        for classnode in classnodes:
            classnode = json.loads(classnode)
            constraints_obj = json.loads(classnode['constraints'])
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
        print("Load %d constraints" % len(constraints))
        return constraints

    @staticmethod
    def load_queries(filename):
        with open(filename, 'rb') as f:
            queries = pickle.load(f)
        return queries
