from collections import deque

class Rewriter:
    def __init__(self) -> None:
        pass

    def rewrite(self, constraints, q):
        # identify constraints in q
        constraints = self.get_q_constraints(constraints, q)
        if constraints.empty():
            return q
        
        # use constraints to generate potential rules
        rules = self.get_rules(constraints)

        rewritten_queries = self.bfs(rules, q, h)

        return rewritten_queries

    
    def generate(self, q, rules):
        for rule in rules:
            q = rule.apply(q)
        return q

    
    # select * from R where a = 1
    # UniqueConstraint(a)
    def get_q_constraints(self, constraints, q):
        pass

    def get_rules(self, constraints):
        pass

    def bfs(self, rules, q, h):
        rewritten_queries = []
        dq = deque()
        dq.append(q)
        while len(dq) > 0:
            n = len(dq)
            for _ in range(n):
                cur_q = dq.popleft()
                rewritten_queries.append(cur_q)
                for rule in rules:
                    dq.append(rule.apply(cur_q))
        return rewritten_queries[1:]




