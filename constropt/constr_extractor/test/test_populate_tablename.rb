#!/usr/bin/env ruby

require_relative '../engine'
require_relative '../traversor'
require_relative '../populate_tablename'
require_relative '../constraint'

class TestPrint
  def visit(node, _params)
    puts "#{node.name} => #{node.parent}, table #{node.table}"
  end
end

def test_builtin
  t = Traversor.new(PopulateTableName.new)
  engine = Engine.new('test/data/redmine_models')
  roots = engine.run
  t.traverse(roots)

  t = Traversor.new(TestPrint.new)
  t.traverse(roots)
end

# test_naive
test_builtin
