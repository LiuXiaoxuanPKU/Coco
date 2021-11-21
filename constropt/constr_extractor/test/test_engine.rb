#!/usr/bin/env ruby

require_relative '../engine'
require_relative '../traversor'
require_relative '../builtin_extractor'

class TestPrint
  def visit(node, _params)
    puts "#{node.name} => #{node.parent}"
    puts "constraints #{node.constraints.length}"
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
  roots = engine.run
  t.traverse(roots)

  t = Traversor.new(TestPrint.new)
  t.traverse(roots)
end

# test_naive
test_builtin
