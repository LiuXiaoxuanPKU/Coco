#!/usr/bin/env ruby

require 'optparse'

require_relative 'engine'
require_relative 'traversor'
require_relative 'builtin_extractor'
require_relative 'db_extractor'
require_relative 'id_extractor'
require_relative 'class_inheritance_extractor'
require_relative 'state_machine_extractor'
require_relative 'hasone_belongto_extractor'
require_relative 'constraint'
require_relative 'serializer' 


options = {}
OptionParser.new do |opt|
  opt.on('--dir DATADIR') { |o| options[:dir] = o }
  opt.on('--app APPNAME') { |o| options[:app] = o }
end.parse!

start = Time.now
dir = options[:dir]
appname = options[:app]

engine = Engine.new("#{dir}/#{appname}_models")
root = engine.run

db_extractor = DBExtractor.new("#{dir}/#{appname}_db/schema.rb")
db_schema = db_extractor.db_schema
db_t = Traversor.new(db_extractor)
db_t.traverse(root)
# constraints_cnt = engine.get_constraints_cnt(root)
# puts "After extracting db constraints, # of constraints #{constraints_cnt}"

builtin_extractor = BuiltinExtractor.new(db_schema)
builtin_t = Traversor.new(builtin_extractor)
builtin_t.traverse(root)
# constraints_cnt = engine.get_constraints_cnt(root)
# puts "After extracting builtin constraints, # of constraints #{constraints_cnt}"

class_inheritance_t = Traversor.new(ClassInheritanceExtractor.new(db_schema))
class_inheritance_t.traverse(root)
# constraints_cnt = engine.get_constraints_cnt(root)
# puts "After extracting class inheritance constraints, # of constraints #{constraints_cnt}"

state_machine = Traversor.new(StateMachineExtractor.new(db_schema))
state_machine.traverse(root)
# constraints_cnt = engine.get_constraints_cnt(root)
# puts "After extracting state machine constraints, # of constraints #{constraints_cnt}"

hasone_belongto = Traversor.new(HasoneBelongtoExtractor.new(db_schema))
hasone_belongto.traverse(root)
# constraints_cnt = engine.get_constraints_cnt(root)
# puts "After extracting hasone belongto constraints, # of constraints #{constraints_cnt}"

id_t = Traversor.new(IdExtractor.new(db_schema))
id_t.traverse(root)
constraints_cnt = engine.get_constraints_cnt(root)
finish = Time.now

puts "Constraint Extraction Time: #{finish - start}"
puts "Bultin: #{builtin_extractor.builtin_validation_cnt}, \
      Custom: #{builtin_extractor.custom_validation_cnt}, \
      Total constraints: #{constraints_cnt}"
Serializer.serialize_tree(root, "#{dir}/../constraints/#{appname}")
