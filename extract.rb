require_relative 'constropt/constr_extractor/engine'
require_relative 'constropt/constr_extractor/traversor'
require_relative 'constropt/constr_extractor/builtin_extractor'
require_relative 'constropt/constr_extractor/db_extractor'
require_relative 'constropt/constr_extractor/id_extractor'
require_relative 'constropt/constr_extractor/class_inheritance_extractor'
require_relative 'constropt/constr_extractor/constraint'
require_relative 'constropt/constr_extractor/serializer'
require_relative 'constropt/constr_extractor/relationship_extractor'

engine = Engine.new('constropt/constr_extractor/test/data/redmine_models')
root = engine.run

builtin_t = Traversor.new(BuiltinExtractor.new)
builtin_t.traverse(root)

rs_t = Traversor.new(RelationshipExtractor.new)
rs_t.traverse(root) 

class_inheritance_t = Traversor.new(ClassInheritanceExtractor.new)
class_inheritance_t.traverse(root)

db_t = Traversor.new(DBExtractor.new('constropt/constr_extractor/test/data/redmine_db/schema.rb'))
db_t.traverse(root)

id_t = Traversor.new(IdExtractor.new)
id_t.traverse(root)

Serializer.serialize_tree(root, 'constraints/redmine_dump')
