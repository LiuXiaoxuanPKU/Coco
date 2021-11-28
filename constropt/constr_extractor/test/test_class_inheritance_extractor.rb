#!/usr/bin/env ruby

require_relative '../engine'
require_relative '../traversor'
require_relative '../class_inheritance_extractor'
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
  input_root = TestUtil.reset(input_root, [:@constraints])
  t = Traversor.new(ClassInheritanceExtractor.new)
  t.traverse(input_root)
  TestUtil.check_equal(input_root, expect_root)
  puts Serializer.serialize_node(input_root)
end

test_naive
