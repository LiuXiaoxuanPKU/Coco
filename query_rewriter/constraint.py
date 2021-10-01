class Constraint:
    pass

class UniqueConstraint(Constraint):
    def __init__(self, table, field) -> None:
        super().__init__()
        self.table = table
        self.field = field