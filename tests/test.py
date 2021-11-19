import json
import traceback
from mo_sql_parsing import parse, format

from constropt.query_rewriter import Rewriter
from constropt.query_rewriter.constraint import *


class RewriteTestor:
    def __init__(self, filename) -> None:
        self.filename = filename
        self.data = json.load(open(filename, "r"))
        self.r = Rewriter()
        self.constraint_dic = {
            "unique": UniqueConstraint,
            "numerical": NumericalConstraint
        }
        self.rewrite_dic = {
            "add_limit_one": self.r.add_limit_one,
            "remove_predicate_numerical": self.r.remove_predicate_numerical
        }

    def create_constraint(self, constraint_obj):
        args = tuple(constraint_obj["args"].values())
        return self.constraint_dic[constraint_obj["type"]](*args)

    def run_by_ids(self, ids):
        for record in self.data:
            if record['id'] not in ids:
                continue
            self.run(record)

    def run_all(self):
        valid_cnt = 0
        print("=====Start Test=====")
        print("Test file", self.filename)
        for record in self.data:
            ok = self.run(record)
            if ok:
                valid_cnt += 1
        print("=====Finish Test=====")
        print("Pass cases: %d/%d" % (valid_cnt, len(self.data)))

    def run(self, record):
        c = self.create_constraint(record["constraint"])
        before_q = parse(record['before'])
        after_q = parse(record['after'])
        ok = True
        try:
            can_rewrite, rewrite_q = self.rewrite_dic[record["type"]](before_q, [
                c])
            if can_rewrite != record["can_rewrite"]:
                print("[Test Fail] Can rewrite: expect %s, get %s, id %d" %
                      (record["can_rewrite"], can_rewrite, record["id"]))
                ok = False
            if format(rewrite_q) != format(after_q):
                print("[Test Fail] Error rewrite query: expect %s, get %s, id: %d" % (
                    format(after_q), format(rewrite_q), record["id"]))
                ok = False
        except Exception as e:
            print("%d throw exception %s" %
                  (record["id"], traceback.print_exc()))
            ok = False
        return ok


if __name__ == "__main__":
    testor = RewriteTestor("./tests/cases/add_limit_one.json")
    testor.run_by_ids([3])

    # testor = RewriteTestor("./tests/cases/remove_predicate_numerical.json")
    # testor.run_all()
