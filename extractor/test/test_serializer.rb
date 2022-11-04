require 'oj'
require_relative '../constraint'
require_relative '../serializer'

def test_naive
  c = InclusionConstraint.new('type', %w[A B C], 'test')
  json = Oj.dump(c)
  puts json
  c_load = Oj.load(json)
  puts c_load
end

def test_str
  str_slash = "[{\"^o\":\"InclusionConstraint\",\"field_name\":\"type\",\"values\":[\"A\",\"B\",\"C\",\"D\"],\"type\":\"class_inheritance\"}]"
  c_load = Oj.load(str_slash)
  puts c_load
end

def test_tree
  input_root = Serializer.deserialize_tree('test/data/classnode/tablename.json')
  json = Serializer.serialize_node(input_root)
  puts json
end

# test_naive
# test_str
test_tree
