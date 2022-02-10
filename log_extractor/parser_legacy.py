import pickle
import re
from random import expovariate

filename = "./test.log"


# [1m[36mAnonymousUser Load (0.4ms)[0m  [1m[34mSELECT  "users".* FROM "users" WHERE "users"."type" IN ('AnonymousUser') AND "users"."lastname" = $1 LIMIT $2[0m  [["lastname", "Anonymous"], ["LIMIT", 1]]


def extract_line(line):
    line = line.strip()
    start_idx = line.find("SELECT")
    if start_idx == -1:
        return False, "", None
    sql_and_param = line[start_idx:]
    tokens = sql_and_param.split("\x1b")
    if len(tokens) <= 1:
        print("[Parse Error] token length = 1 ", sql_and_param, tokens)
        return False, "", None

    sql = tokens[0]
    param = tokens[1]

    if len(param) <= 3:
        param = []
    else:
        param = param[4:].replace("[nil", "[None")
        param = param.replace(", nil", ", None")
        param = param.replace("true]", "True]")
        param = param.replace("false]", "False]")
        try:
            param = eval(param)
        except Exception as e:
            print("===Fail====")
            print(param, sql_and_param)
            print(e)

    return True, sql, param


# D, [2021-08-25T01:55:24.810967 #14466] DEBUG -- :   ↳ app/models/wiki.rb:106:in `create_menu_item_for_start_page'
# app/models/wiki.rb:106:in `create_menu_item_for_start_page'
# test-prof (1.0.6) lib/test_prof/recipes/rspec/let_it_be.rb:90:in `instance_exec'
def get_file_line_func(str):
    part = str.split(":in")
    assert len(part) >= 1
    filename_linenum = part[0]
    space_idx = -1
    for i, c in enumerate(filename_linenum):
        if c == "/":
            break
        if c == " ":
            space_idx = i
    filename_linenum = filename_linenum[space_idx + 1:]
    filename, linenum = filename_linenum.split(":")
    return filename, linenum


def parse_test_name(line):
    tokens = line.split(": ")
    if not tokens[0].endswith("Test"):
        return False
    return tokens[0].strip() + "-" + tokens[1].strip().strip("\n")


def replace_param(sql, param):
    idx1, idx2 = 0, 0
    tokens = sql.split(" ")
    while idx1 < len(tokens):
        if '$' in tokens[idx1]:
            if isinstance(param[idx2][1], str):
                param_str = '\"' + param[idx2][1] + '\"'
            else:
                param_str = str(param[idx2][1])
            tokens[idx1] = re.sub(r"\$\d", param_str, tokens[idx1])
            idx2 += 1
        idx1 += 1
    sql_with_param = " ".join(tokens).strip()
    return sql_with_param


if __name__ == "__main__":
    sqls = {}
    with open(filename, "r", errors="replace") as f:
        lines = f.readlines()
        i = 0
        while i < len(lines):
            if not lines[i].startswith("-----"):
                i += 1
            else:
                break

        while i < len(lines):
            cur_sqls = []
            if lines[i].startswith("-----"):
                cur_test = parse_test_name(lines[i + 1])
                i += 3
                if not cur_test:
                    i += 1
                    continue
                print(cur_test)
                while not lines[i].startswith("-----"):
                    ok, sql, param = extract_line(lines[i])
                    sql_with_param = replace_param(sql, param)
                    if ok:
                        cur_sqls.append((sql_with_param, sql_with_param))
                    i += 1
                sqls[cur_test] = cur_sqls
            i += 1

    with open("redmine_end2end_withparam.pk", "wb") as f:
        pickle.dump(sqls, f)
