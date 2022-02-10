from mo_sql_parsing import parse, format

def base_stats(filename):
    with open(filename, 'r') as f:
        lines = f.readlines()
    total_raw_queries = len(lines)
    lines = set(lines)
    unique_raw_queries = len(lines)
    print("Total # of raw queries: ", total_raw_queries)
    print("Total # of unique raw queries: ", unique_raw_queries)

    q_objs = []
    fail_raw_queries = []
    for line in lines:
        try:
            q_objs.append(parse(line))
        except:
            fail_raw_queries.append(line)
    print("[Success] Parse unique queries %d" % len(q_objs))
    print("[Fail] Parse %d queries" % len(fail_raw_queries))
    # for q in fail_raw_queries:
    #     print(q)
    return q_objs

if __name__ == "__main__":
    query_filename = "queries/redmine.sql"
    q_objs = base_stats(query_filename)