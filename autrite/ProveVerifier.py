from config import get_filename, FileType

class ProveVerifier:
    @staticmethod
    def format_param(q):
        tokens = q.split(" ")
        keywords = ['one', 'position', 'value', 'count']
        
        for i, t in enumerate(tokens):
            if t in keywords:
                tokens[i] = '"' + t + '"'
        q = ' '.join(tokens)
        return q 
        
    def verify(self, appname, org_q, constraints, rewritten_queries, id):
        # Dump SQLs
        sql_create_path = get_filename(FileType.VERIFIER_INPUT, appname)
        with open(sql_create_path, "r") as f:
            create_lines = f.readlines()

        qs = create_lines + ["\n-- Original Query\n"]
        qs += [ProveVerifier.format_param(org_q.q_raw_param) + ";"]
        qs += ["\n-- Rewritten Queries\n"]   
        qs += [ProveVerifier.format_param(q.q_raw_param) + ";\n" for q in rewritten_queries]

        q_path = "%s/%d.sql" % (get_filename(FileType.VERIFIER_OUTPUT, appname), id)
        print("write to %s, length %d" % (q_path, len(qs)))
        with open (q_path, "w") as f:
            f.writelines(qs)

        equivalent_queries = rewritten_queries
        return equivalent_queries