from mo_sql_parsing import parse, format

class Query:
    def __init__(self, s) -> None:
        self.q = parse(s)