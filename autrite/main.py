
from loader import Loader
from rewriter import Rewriter
from evaluator import Evaluator

if __name__ == '__main__':
    constraint_filename = ""
    query_filename = ""
    constraints = Loader.load_constraints(constraint_filename)
    queries = Loader.load_queries(query_filename)
    rewriter = Rewriter()

    for q in queries:
        rewritten_queries = rewriter.rewrite(constraints, q)
    
        # TODO: verify rewritten queries
        verified_queries = rewritten_queries

        # evaluate query performance
        org_cost = Evaluator.evaluate(q)
        min_cost = org_cost
        best_q = q
        for vq in verified_queries:
            cost = Evaluator.evaluate(vq)
            if cost < min_cost:
                min_cost, best_q = cost, vq

        print("Org q %s, org cost %d" % (format(q), org_cost))
        print("Best q %s, best cost %d" % (format(best_q), min_cost))