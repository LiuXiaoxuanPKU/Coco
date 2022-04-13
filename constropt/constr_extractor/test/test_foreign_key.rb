require 'yard'
require_relative '../builtin_extractor'
require_relative '../class_node'

#test defaults
def test_defaults
  class_def = <<-FOO
    class Test
      belongs_to :user
    end
  FOO

  node = ClassNode.new('Test')
  node.ast = YARD::Parser::Ruby::RubyParser.parse(class_def).root[0]

  e = BuiltinExtractor.new
  e.visit(node, {})

  raise "expect 1 constraint, get #{node.constraints.length} constraints" unless node.constraints.length == 1

  class_name = node.constraints[0].class_name
  fk_column_name = node.constraints[0].fk_column_name

  raise "expect class_name = 'User', get #{class_name} instead" unless class_name == 'User'
  raise "expect fk_column_name = 'User', get #{fk_column_name} instead" unless fk_column_name == 'user_id'
end

#test when explicitly stated
def test_explicit
  class_def = <<-FOO
    class Test
      belongs_to :page, :class_name => 'WikiPage', :foreign_key => 'wp_id'
    end
  FOO

  node = ClassNode.new('Test')
  node.ast = YARD::Parser::Ruby::RubyParser.parse(class_def).root[0]

  e = BuiltinExtractor.new
  e.visit(node, {})

  raise "expect 1 constraint, get #{node.constraints.length} constraints" unless node.constraints.length == 1

  class_name = node.constraints[0].class_name
  fk_column_name = node.constraints[0].fk_column_name

  raise "expect class_name = 'WikiPage', get #{class_name} instead" unless class_name == 'WikiPage'
  raise "expect fk_column_name = 'wp_id', get #{fk_column_name} instead" unless fk_column_name == 'wp_id'
end

test_defaults
test_explicit
