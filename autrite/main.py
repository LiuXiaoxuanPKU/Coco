
from loader import Loader
from rewriter import Rewriter
from evaluator import Evaluator
from verifier import Verifier
from mo_sql_parsing import parse, format

if __name__ == '__main__':
    appname = "redmine"
    constraint_filename = "../constraints/%s" % appname
    query_filename = "../queries/%s.pk" % appname 
    constraints = Loader.load_constraints(constraint_filename)
    queries = Loader.load_queries(query_filename)

    for q in queries:
        print("org")
        print(format(q))

        rewritten_queries = Rewriter().rewrite(constraints, q)

        print("rewritten", len(rewritten_queries))
        if len(rewritten_queries) == 0:
            continue
        
        # TODO: verify rewritten queries
        verified_queries = Verifier().verify(appname, q, constraints, rewritten_queries)

        # # evaluate query performance
        # org_cost = Evaluator.evaluate(q)
        # min_cost = org_cost
        # best_q = q
        # for vq in verified_queries:
        #     cost = Evaluator.evaluate(vq)
        #     if cost < min_cost:
        #         min_cost, best_q = cost, vq

        # print("Org q %s, org cost %d" % (format(q), org_cost))
        # print("Best q %s, best cost %d" % (format(best_q), min_cost))