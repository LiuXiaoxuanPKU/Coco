import json
import re
from pathlib import Path

from config import get_path, FileType


class ProveDumper:
    @staticmethod
    def cleanup_sql(content):
        keyword = re.compile(r"([^\w\"\']|^)(language|position|value|count|local|scope|sensitive|month|year|timestamp|one)([^\w\"\']|$)")
        equality = re.compile(r" != ")
        cleaned = []
        for statement in content.split(";"):
            if "SELECT" in statement:
                statement = re.sub(keyword, "\g<1>\"\g<2>\"\g<3>", statement)
                statement = re.sub(equality, " <> ", statement)
                cleaned.append(statement)
            else:
                cleaned.append(statement)
        return ";".join(cleaned)

    @staticmethod
    def dump_metadata(appname, org_q, rewritten_queries, id, cost_include_eq, datadir):
        result = {
            "org": org_q.to_dict(),
            "rewrites": [q.to_dict() for q in rewritten_queries]
        }
        path = get_path(FileType.REWRITE_META, appname, datadir, cost_include_eq)
        path.mkdir(parents=True, exist_ok=True)
        with open(path / f"{id}.json", "w") as f:
            json.dump(result, f, indent=4)

    @staticmethod
    def dump_param_rewrite(appname, org_q, rewritten_queries, id, cost_include_eq, datadir):
        assert (len(rewritten_queries) > 0)
        # Dump SQLs
        sql_create_path = get_path(FileType.DATABASE_SCHEMA, appname, datadir)
        with open(sql_create_path, "r") as f:
            create_lines = f.readlines()

        qs = create_lines + ["\n-- Original Query\n"]
        qs += [ProveDumper.cleanup_sql(org_q.q_raw_param) + ";"]
        qs += ["\n-- Rewritten Queries\n"]
        qs += [ProveDumper.cleanup_sql(q.q_raw_param) +
               ";\n" for q in rewritten_queries]

        path = get_path(FileType.REWRITTEN_QUERY,
                            appname, datadir, cost_include_eq)
        path.mkdir(exist_ok=True, parents=True)
        # print("[Dump rewrite sqls] write to %s, rewrite length %d" % (q_path, len(qs)))
        with open(path / f"{id}.sql", "w") as f:
            f.writelines(qs)
