class Rule:
    def __init__(self, name) -> None:
        self.name = name

    def __str__(self) -> str:
        return self.name


class RemoveDistinct(Rule):
    def __init__(self) -> None:
        super().__init__("RemoveDistinct")

    def apply(self):
        pass


class AddLimitOne(Rule):
    def __init__(self) -> None:
        super().__init__("AddLimitOne")

    def apply(self):
        pass
