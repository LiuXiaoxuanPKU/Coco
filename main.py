import os
import json
import pickle
from constropt.query_rewriter import rewrite
from constropt.query_rewriter import constraint


def extract_constraints(app_dir, output_dir):
    commit = 'master'
    rules = "[:builtin, :inheritance]"
    extract_script = '''
    require_relative "./version.rb"
    commit = "master"
    v = Version.new('%s', '%s', %s)
    constraints = v.getModelConstraints()
    File.open('%s', "w") do |f|
      JSON.dump(constraints, f)
    end
    puts "===========Extract #{constraints.length} constraints==========="
    ''' % (app_dir, commit, rules, output_dir)
    script_dir = "./constropt/constr_extractor/extract_script.rb"
    with open(script_dir, 'w') as f:
        f.write(extract_script)
    os.system("cd ./constropt/constr_extractor; ruby ./extract_script.rb")
    # load constraints
    return list(map(lambda x: json.loads(x), json.load(open(output_dir, 'r'))))


def load_constraints(constraints_json):
    constraints = []
    for obj in constraints_json:
        c = None
        if obj["constraint_type"] == "length":
            c = constraint.LengthConstraint(
                obj['table'], obj['field_name'], obj['min'], obj['max'])
        elif obj["constraint_type"] == "unique":
            c = constraint.UniqueConstraint(obj['table'], obj['field_name'])
        elif obj["constraint_type"] == "presence":
            c = constraint.PresenceConstraint(obj['table'], obj['field_name'])
        elif obj["constraint_type"] == "inclusion":
            c = constraint.InclusionConstraint(
                obj['table'], obj['field_name'], obj['values'])
        elif obj["constraint_type"] == "format":
            c = constraint.FormatConstraint(
                obj['table'], obj['field_name'], obj['format'])
        else:
            print("[Error] Unsupport constraint type ", obj)
            exit(1)
        constraints.append(c)
    return constraints


def load_queries(query_dir):
    with open(query_dir, 'rb') as f:
        content = pickle.load(f)
    if query_dir.endswith("end2end.pk"):
        return content
    else:
        queries = []
        content = list(content)
        for i in range(len(content)):
            queries.append(content[i][1])
        return queries


def rewrite_queries(constraints, queries):
    testname = list(queries.keys())[0]
    print("=================Start rewrite ===============")
    print("Testname %s" % testname)
    for i in range(10):
        print(constraints[i])
        print(queries[testname][i])
    print("=================Finish rewrite===============")


if __name__ == "__main__":
    app_name = "redmine"
    app_dir = "spec/test_data/"
    constraint_output_dir = "%s/constraints/%s" % (
        os.getcwd(), app_name)
    constraints_json = extract_constraints(app_dir, constraint_output_dir)
    constraints = load_constraints(constraints_json)
    query_dir = "%s/queries/%s_end2end.pk" % (os.getcwd(), app_name)
    queries = load_queries(query_dir)
    rewrite_queries(constraints, queries)
