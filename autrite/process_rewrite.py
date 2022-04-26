import os
from tokenize import group
from xxlimited import new

from loader import Loader
from config import get_filename, FileType
from constraint import UniqueConstraint

def dump_file(groups, extra_lines, filename):
    with open(filename, "w") as f:
        for table in groups:
            f.writelines(groups[table])
        f.writelines(extra_lines)
        
def process_group(groups, constraints):
    for table in groups:
        fields = [c.field for c in constraints if c.table == table]
        if not groups[table][-1].endswith(",\n"):
            groups[table][-1] = groups[table][-1].strip()
            groups[table][-1] += ",\n"
        for field in fields:
            groups[table].append("UNIQUE(%s),\n" % ",".join(field))
        groups[table].append(");\n\n")
    return groups

def process_file(filename, constraints):
    with open(filename, 'r') as f:
        lines = f.readlines()
    
    def parse_table_name(line):
        assert("CREATE TABLE" in line)
        return line.split(" ")[2]
    
    groups = {}
    table = None
    extra_lines = []
    for line in lines:
        if "CREATE" in line:
            table = parse_table_name(line)
            groups[table] = []
        if table is None:
            if line != "\n":
                extra_lines.append(line)
            continue
        if ");" in line:
            table = None
        else:
            groups[table].append(line)
    groups = process_group(groups, constraints)
   
    folder = get_filename(FileType.VERIFIER_OUTPUT, app) + "/eq_unique/" 
    dump_file(groups, extra_lines, folder + filename.split("/")[-1])

def process_rewrite(app, constraints):
    folder = get_filename(FileType.VERIFIER_OUTPUT, app) + "/eq/"
    for f in os.listdir(folder):
        if not f.endswith(".sql"):
            continue
        process_file(folder + f, constraints)

if __name__ == "__main__":
    app = "openproject"
    filename = get_filename(FileType.CONSTRAINT, app)
    constraints = Loader.load_constraints(filename)
    unique_constraints = [c for c in constraints if isinstance(c, UniqueConstraint)]
    
    process_rewrite(app, unique_constraints)
    