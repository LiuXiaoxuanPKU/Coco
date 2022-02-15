import subprocess
from mo_sql_parsing import parse, format

app_create_path = "./app_create_sql"
cosette_parser_path = ""
rewrite_cnt = 0

class Verifier:
    def verify(self, appname, org_q, constraints, rewritten_queries):
        global rewrite_cnt
        rewrite_cnt += 1
        # generate parser input1: create_sql + query_sql
        # generate parser input2: create_sql + org_q_sql
        create_sql_path = "%s/%s_create.sql" % (app_create_path, appname)
        with open(create_sql_path, "r") as f:
            create_lines = f.readlines()
        
        qs = create_lines + ["-- Original Query;\n"]
        qs += [format(org_q) + ";"]
        qs += ["\n-- Rewritten Queries;\n"]
        qs += [format(q) + ";\n" for q in rewritten_queries]

        q_path = "%s/%s_%d.sql" % (app_create_path, appname+"_parser_input", rewrite_cnt)
        with open (q_path, "w") as f:
            f.writelines(qs)
        
        # call parser, get json output
        # cd_cmd = "cd %s;" % cosette_parser_path
        # org_cmd = './mvnw exec:java -Dexec.mainClass="org.cosette.Main" -Dexec.args="%s"' % q_path
        # subprocess.run(cd_cmd + org_cmd, shell=True)

        # prepare verifier input
        # org_q_json
        # rewritten_q_json
        # constraints


        # call verifier

        equivalent_queries = []
        return equivalent_queries