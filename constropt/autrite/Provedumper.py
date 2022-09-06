import json
from config import get_filename, FileType

class ProveDumper:
    @staticmethod
    def format_param(q):
        tokens = q.split(" ")
        keywords = ['one', 'position', 'value', 'count']
        
        for i, t in enumerate(tokens):
            if t in keywords:
                tokens[i] = '"' + t + '"'
        q = ' '.join(tokens)
        return q 
    
    @staticmethod
    def dump_metadaba(appname, org_q, rewritten_queries, id, cost_include_eq):
        result =  {
            "org" : org_q.to_dict(),
            "rewrites" : [q.to_dict() for q in rewritten_queries]
        }
        path = path = get_filename(FileType.REWRITE_OUTPUT_META, appname, cost_include_eq)
        q_path = "%s/%d.json" % (path, id)
        with open (q_path, "w") as f:
            f.write(json.dumps(result, indent=4))
    
    @staticmethod
    def dump_param_rewrite(appname, org_q, rewritten_queries, id, cost_include_eq, counter = False):
        assert(len(rewritten_queries) > 0)
        # Dump SQLs
        sql_create_path = get_filename(FileType.VERIFIER_INPUT, appname)
        with open(sql_create_path, "r") as f:
            create_lines = f.readlines()

        qs = create_lines + ["\n-- Original Query\n"]
        qs += [ProveDumper.format_param(org_q.q_raw_param) + ";"]
        qs += ["\n-- Rewritten Queries\n"]   
        qs += [ProveDumper.format_param(q.q_raw_param) + ";\n" for q in rewritten_queries]

        if counter:
            path = get_filename(FileType.REWRITE_OUTPUT_SQL_NOT_EQ, appname) 
        else:
            path = get_filename(FileType.REWRITE_OUTPUT_SQL_EQ, appname, cost_include_eq)
        
        q_path = "%s/%d.sql" % (path, id)
        print("write to %s, length %d" % (q_path, len(qs)))
        with open (q_path, "w") as f:
            f.writelines(qs)
        
        equivalent_queries = rewritten_queries
        return equivalent_queries