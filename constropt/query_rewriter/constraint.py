class Constraint:
    def __init__(self, table, field) -> None:
        self.table = table
        self.field = field


class UniqueConstraint(Constraint):
    def __init__(self, table, field, scope=[], cond=None) -> None:
        if table == "principals":
            table = "users"

        self.table = table
        self.field = field
        self.scope = scope
        self.cond = cond

    def __str__(self) -> str:
        return "Unique, table: %s, field: %s, scope: %s, cond: %s" % (self.table, self.field, self.scope, self.cond)


class InclusionConstraint(Constraint):
    def __init__(self, table, field, values) -> None:
        if table == "principals":
            table = "users"
        super().__init__(table, field)
        self.value_list = values

    def __str__(self) -> str:
        return "Inclusion, table: %s, field: %s, value_list: %s" % (self.table, self.field, self.value_list)


class LengthConstraint(Constraint):
    def __init__(self, table, field, min, max) -> None:
        super().__init__(table, field)
        self.min = min
        self.max = max

    def __str__(self) -> str:
        return "Length, table: %s, field: %s, min: %s, max: %s" % (self.table, self.field, self.min, self.max)


class FormatConstraint(Constraint):
    def __init__(self, table, field, format) -> None:
        super().__init__(table, field)
        self.format = format

    def __str__(self) -> str:
        return "Format, table: %s, field: %s, format: %s" % (self.table, self.field, self.format)


class PresenceConstraint(Constraint):
    def __init__(self, table, field) -> None:
        super().__init__(table, field)

    def __str__(self) -> str:
        return "Presence, table: %s, field: %s" % (self.table, self.field)
