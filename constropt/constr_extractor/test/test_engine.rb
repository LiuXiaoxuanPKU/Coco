#!/usr/bin/env ruby

require_relative '../engine'
require_relative '../traversor'
require_relative '../builtin_extractor'
require_relative '../id_extractor'
require_relative '../constraint'

class TestPrint
  def visit(node, _params)
    puts "==================#{node.name} => #{node.parent}"
    puts "constraints #{node.constraints.length}"
    inclusion_constraints = node.constraints.select { |c| c.is_a? InclusionConstraint }
    unique_constraints = node.constraints.select { |c| c.is_a? UniqueConstraint }
    (inclusion_constraints + unique_constraints).each do |c|
      puts c.to_s
    end
  end
end

def test_naive
  t = Traversor.new(TestPrint.new)
  engine = Engine.new('spec/test_data/redmine_models')
  roots = engine.run
  t.traverse(roots)
end

def test_builtin
  t = Traversor.new(BuiltinExtractor.new)
  engine = Engine.new('test/data/redmine_models')
  root = engine.run
  t.traverse(root)

  t = Traversor.new(IdExtractor.new)
  t.traverse(root)

  t = Traversor.new(TestPrint.new)
  t.traverse(root)
end

# test_naive
test_builtin
