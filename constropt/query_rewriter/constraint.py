class Constraint:
    def __init__(self, table, field) -> None:
        self.table = table
        self.field = field


class UniqueConstraint(Constraint):
    def __init__(self, table, field) -> None:
        if table == "principals":
            table = "users"
        super().__init__(table, field)


class InclusionConstraint(Constraint):
    def __init__(self, table, field, values) -> None:
        super().__init__(table, field)
        self.value_list = values


class LengthConstraint(Constraint):
    def __init__(self, table, field, min, max) -> None:
        super().__init__(table, field)
        self.min = min
        self.max = max


class FormatConstraint(Constraint):
    def __init__(self, table, field, format) -> None:
        super().__init__(table, field)
        self.format = format


class PresenceConstraint(Constraint):
    def __init__(self, table, field) -> None:
        super().__init__(table, field)
