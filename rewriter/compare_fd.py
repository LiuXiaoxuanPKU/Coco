from loader import Loader
from config import get_filename, FileType
from constraint import UniqueConstraint, PresenceConstraint

constraint_file = get_filename(FileType.CONSTRAINT, "spree")
cons = Loader.load_constraints(constraint_file)
cons = [c for c in cons if isinstance(c, UniqueConstraint)]
for c in cons:
  print(c.field, c.table)
  

