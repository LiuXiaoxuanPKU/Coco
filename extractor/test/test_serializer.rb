require 'test/unit'
require 'oj'
require_relative '../constraint'
require_relative '../serializer'

class TestBulitin < Test::Unit::TestCase
  def test_naive
    c = InclusionConstraint.new('type', %w[A B C], 'test', false)
    json = Oj.dump(c)
    c_load = Oj.load(json)
    raise "Error #{c.field_name} != #{c_load.field_name}" unless c.field_name == c_load.field_name
    raise "Error #{c.values} != #{c_load.values}" unless c.values == c_load.values
  end

  def test_str
    str_slash = '[{"^o":"InclusionConstraint","field_name":"type","values":["A","B","C","D"],"type":"class_inheritance"}]'
    c_load = Oj.load(str_slash)[0]
    raise "Error #{c_load.field_name} != type" unless c_load.field_name == 'type'
  end

  def test_tree
    input_root = Serializer.deserialize_tree("#{__dir__}/data/classnode/tablename.json")
    json = Serializer.serialize_node(input_root)
    puts json
  end
end
