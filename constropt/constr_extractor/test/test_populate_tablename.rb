#!/usr/bin/env ruby

require_relative '../engine'
require_relative '../traversor'
require_relative '../populate_tablename'
require_relative '../constraint'
require_relative '../serializer'
require_relative './test_util'

class TestPrint
  def visit(node, _params)
    puts "#{node.name} => #{node.parent}, table #{node.table}"
  end
end

def test_naive
  input_root = Serializer.deserialize_tree('test/data/classnode/tablename.json')
  expect_root = Serializer.deserialize_tree('test/data/classnode/tablename.json')
  input_root = TestUtil.reset(input_root, [:@table])
  t = Traversor.new(PopulateTableName.new)
  t.traverse(input_root)
  TestUtil.check_equal(input_root, expect_root)
  t = Traversor.new(TestPrint.new)
  t.traverse(input_root)
end

def test_redmine
  t = Traversor.new(PopulateTableName.new)
  engine = Engine.new('test/data/redmine_models')
  roots = engine.run
  t.traverse(roots)

  t = Traversor.new(TestPrint.new)
  t.traverse(roots)
end

test_naive
# test_redmine
