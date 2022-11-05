require 'test/unit'

require_relative '../engine'
require_relative '../traversor'
require_relative '../class_inheritance_extractor'
require_relative '../constraint'
require_relative '../serializer'
require_relative './testutil'

class TestBulitin < Test::Unit::TestCase
  def test_naive
    input_root = Serializer.deserialize_tree("#{__dir__}/data/classnode/tablename.json")
    expect_root = Serializer.deserialize_tree("#{__dir__}/data/classnode/tablename.json")
    input_root = TestUtil.reset(input_root, [:@constraints])
    t = Traversor.new(ClassInheritanceExtractor.new)
    t.traverse(input_root)
    TestUtil.check_equal(input_root, expect_root)
    puts Serializer.serialize_node(input_root)
  end
end
