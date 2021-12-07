import os
import json
import pickle
from mo_imports import expect
from mo_sql_parsing import parse, format
from constropt.query_rewriter import Rewriter
from constropt.query_rewriter import constraint
from tqdm import tqdm
import traceback


def extract_constraints(filename):
    # load constraints
    return json.load(open(filename, 'r'))


def load_constraints(classnodes):
    constraints = []
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


def load_queries(query_dir):
    with open(query_dir, 'rb') as f:
        content = pickle.load(f)
    if query_dir.endswith("end2end.pk"):
        return content
    if query_dir.endswith("end2end_withparam.pk"):
        queries = {}
        for test in content:
            sqls_with_param = []
            for pair in content[test]:
                sqls_with_param.append(pair[1])
            queries[test] = sqls_with_param
        return queries
    else:
        queries = []
        content = list(content)
        for i in range(len(content)):
            queries.append(content[i][1])
        return queries


def rewrite_queries(constraints, queries):
    rewriter = Rewriter()
    tests = list(queries.keys())
    rewrite_stats = {}
    table_stats = {}
    total_queries = 0
    rewritten_queries = 0
    fail_parse_cnt = 0
    test_cnt = 0
    distinct_cnt = 0
    limit_cnt = 0
    for i in tqdm(range(len(tests))):
        rewrite_cnt = 0
        testname = tests[i]
        # if not testname.startswith('UsersControllerTest-test_create'):
        #     continue
        print("=================Start rewrite test %d %s ===============" %
              (i, testname))
        test_cnt += 1
        for i in range(len(queries[testname])):
            try:
                org_q = parse(queries[testname][i].strip())
                if isinstance(org_q['from'], str):
                    if org_q['from'] not in table_stats:
                        table_stats[org_q['from']] = 0
                    table_stats[org_q['from']] += 1
            except:
                fail_parse_cnt += 1
                print("[Error] Fail to parse ", queries[testname][i])
                continue
            # print(queries[testname][i])
            if "DISTINCT" in queries[testname][i]:
                # print("[Distinct Query] ", queries[testname][i].strip())
                distinct_cnt += 1
            if "LIMIT" not in queries[testname][i]:
                limit_cnt += 1
            if "IS NULL" in queries[testname][i]:
                # print(queries[testname][i])
                pass
            q, rewrite_types = rewriter.rewrite_single_query(
                org_q, constraints)
            if len(rewrite_types) > 0:
                rewrite_cnt += 1
                # print("org %s\n new %s\n" %
                #       (format(queries[testname][i]), format(q)))
        total_queries += len(queries[testname])
        rewritten_queries += rewrite_cnt
        print("=================Finish rewrite, rewrite %d queries===============" % rewrite_cnt)
        rewrite_stats[testname] = rewrite_cnt
    total_queries -= fail_parse_cnt
    print("Number of end2end tests", test_cnt)
    print("Number of distinct candidates", distinct_cnt)
    print("Number of limit candidates", limit_cnt)
    print("Average number of queries", total_queries * 1.0 / test_cnt)
    print("Avergae number of rewritten queries",
          rewritten_queries * 1.0 / test_cnt)
    print("Table stats", table_stats)


if __name__ == "__main__":
    app_name = "redmine"
    constraint_output_dir = "%s/constraints/%s" % (
        os.getcwd(), app_name)
    constraints_json = extract_constraints(constraint_output_dir)
    constraints = load_constraints(constraints_json)
    run_end2end_test = False
    if run_end2end_test:
        query_dir = "%s/queries/%s_end2end_withparam.pk" % (
            os.getcwd(), app_name)
        queries = load_queries(query_dir)
        rewrite_queries(constraints, queries)
    else:
        r = Rewriter()
        query_dir = "queries/redmine.pk"
        queries = []
        parse_cnt = 0
        with open(query_dir, 'rb') as f:
            queries = pickle.load(f)

        rewrite_cnt = 0
        stats = {}
        for q in tqdm(list(queries)):
            try:
                q = parse(q[1])
            except Exception as e:
                continue
            new_q, rewrite_types = r.rewrite_single_query(q, constraints)
            if len(rewrite_types):
                rewrite_cnt += 1
                for t in rewrite_types:
                    if t not in stats:
                        stats[t] = 0
                    stats[t] += 1
        print("=====Total number of queries %d" % len(queries))
        print("===== Rewrite %d queries" % rewrite_cnt)
        print("===== Rewrite stats", stats)
        # print("===== Remove distinct query types")
        # for q in r.queryset:
        #     print(q)
        #     print('===============')
