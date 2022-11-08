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

builtin_extractor = BuiltinExtractor.new
builtin_t = Traversor.new(builtin_extractor)
builtin_t.traverse(root)

class_inheritance_t = Traversor.new(ClassInheritanceExtractor.new)
class_inheritance_t.traverse(root)

state_machine = Traversor.new(StateMachineExtractor.new)
state_machine.traverse(root)
constraints_cnt = engine.get_constraints_cnt(root)
puts "After extracting state machine constraints, # of constraints #{constraints_cnt}"

hasone_belongto = Traversor.new(HasoneBelongtoExtractor.new)
hasone_belongto.traverse(root)
constraints_cnt = engine.get_constraints_cnt(root)
puts "After extracting hasone belongto constraints, # of constraints #{constraints_cnt}"

db_t = Traversor.new(DBExtractor.new("#{dir}/#{appname}_db/schema.rb"))
db_t.traverse(root)
constraints_cnt = engine.get_constraints_cnt(root)
puts "After extracting db constraints, # of constraints #{constraints_cnt}"

id_t = Traversor.new(IdExtractor.new)
id_t.traverse(root)

finish = Time.now
puts "Constraint Extraction Time: #{finish - start}"
puts "Bultin: #{builtin_extractor.builtin_validation_cnt}, \
      Custom: #{builtin_extractor.custom_validation_cnt}"
# Serializer.serialize_tree(root, "#{dir}/constraints/#{appname}")
