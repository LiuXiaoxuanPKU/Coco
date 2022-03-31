from config import get_filename, FileType

rewrite_cnt = 0

class ProveVerifier:
    def verify(self, appname, org_q, constraints, rewritten_queries):
        global rewrite_cnt
        rewrite_cnt += 1
        app_create_path = get_filename(FileType.VERIFIER_INPUT, appname)
        create_sql_path = "%s/%s_create.sql" % (app_create_path, appname)
        with open(create_sql_path, "r") as f:
            create_lines = f.readlines()
        
        def format_param(q):
            tokens = q.split(" ")
            keywords = ['one', 'position', 'value', 'count']
            
            for i, t in enumerate(tokens):
                if t in keywords:
                    tokens[i] = '"' + t + '"'
            q = ' '.join(tokens)
            return q 

        qs = create_lines + ["\n-- Original Query\n"]
        qs += [format_param(org_q.sql_param) + ";"]
        qs += ["\n-- Rewritten Queries\n"]   
        qs += [format_param(q.sql_param) + ";\n" for q in rewritten_queries]

        q_path = "%s/%d.sql" % (app_create_path, rewrite_cnt)
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

        equivalent_queries = rewritten_queries
        return equivalent_queries