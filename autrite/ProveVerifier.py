from lib2to3.pgen2 import token
import subprocess
from mo_sql_parsing import parse, format

app_create_path = "./app_create_sql"
cosette_parser_path = ""
rewrite_cnt = 0

class ProveVerifier:
    def verify(self, appname, org_q, constraints, rewritten_queries, out_dir):
        global rewrite_cnt
        rewrite_cnt += 1
        # generate parser input1: create_sql + query_sql
        # generate parser input2: create_sql + org_q_sql
        create_sql_path = "%s/%s_create.sql" % (app_create_path, appname)
        with open(create_sql_path, "r") as f:
            create_lines = f.readlines()
        
        def format_param(q):
            for i in range(100): # At most 100 parameters
                q = q.replace('"$%d"' % i, '\'$%d\'' % i)
            # replace parameter after limit
            tokens = q.split(" ")
            for i, t in enumerate(tokens):
                if t == "LIMIT" and tokens[i+1].startswith("'$"):
                    tokens[i+1] = '2' # replace the parameter after limit with 2
            q = ' '.join(tokens)
            return q 

        qs = create_lines + ["\n-- Original Query\n"]
        qs += [format_param(format(org_q)) + ";"]
        qs += ["\n-- Rewritten Queries\n"]   
        qs += [format_param(format(q)) + ";\n" for q in rewritten_queries]

        q_path = "%s/%s_%d.sql" % (out_dir, appname+"_parser_input", rewrite_cnt)
        print("write to %s, length %d" % (q_path, len(qs)))
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