import json
from constraint import *
import loader
from pathlib import Path

def load_query(filename):
    return json.load(open(filename, 'r'))

def add_table_constraint(table, constraints):
    def get_field_idx(table, field):
        fields = [field.lower() for field in table["fields"]]
        field = field.lower()
        if field not in fields:
            return None
        return fields.index(field)

    tablename = table['name'].lower()
    table_constraint = [c for c in constraints if c.table is not None and c.table.lower() == tablename]
    for c in table_constraint:
        if isinstance(c.field, str) and c.field.lower() not in [f.lower() for f in table["fields"]]:
            continue
        if isinstance(c, NumericalConstraint):
            def bound(lower, val, idx):
                data_type = table["types"][idx]
                if val is None:
                    return {
                      "operator" : "TRUE",
                      "operand" : [ ],
                      "type" : "BOOLEAN"
                    }
                return {
                  "operator" : "<=" if lower else ">=",
                  "operand" : [ {
                    "operator" : str(val),
                    "operand" : [ ],
                    "type" : data_type
                  }, {
                    "column" : idx,
                    "type" : data_type
                  } ],
                  "type" : "BOOLEAN"
                }
            idx = get_field_idx(table, c.field.lower())
            if c.min is not None and c.max is not None:
                table.setdefault("guaranteed", list()).append({"operator": "AND", "operand": [bound(True, c.min, idx), bound(False, c.max, idx)], "type": "BOOLEAN"})
        elif isinstance(c, UniqueConstraint):
            idx = [get_field_idx(table, f.lower()) for f in c.field]
            if all([i is not None for i in idx]):
                if idx not in table['key'] and len(idx) > 0:
                    table["key"].append(idx)
        elif isinstance(c, PresenceConstraint):
            idx = get_field_idx(table, c.field.lower())
            if idx is not None:
                table["nullable"][idx] = False
    return table


def modify_query(query, constraints):
    schemas = query['schemas']
    for table in schemas:
        add_table_constraint(table, constraints)
    return query

def inject(constraint: Path, batch_dir: Path):
    constraints = loader.read_constraints(constraint, include_all=False, remove_pk=False)
    for query in batch_dir.glob("*.batch/*.json"):
        with open(query, "r+") as f:
            mq = modify_query(json.load(f), constraints)
            f.seek(0)
            json.dump(mq, f)
            f.truncate()
