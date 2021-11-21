require 'yard'
require_relative '../builtin_extractor'
require_relative '../class_node'

def test_naive
  class_def = <<-FOO
    class Test
        validates_presence_of :login, :firstname, :lastname
    end
  FOO
  node = ClassNode.new('Test')
  node.ast = YARD::Parser::Ruby::RubyParser.parse(class_def).root[0]
  builtin_extractor = BuiltinExtractor.new
  builtin_extractor.visit(node)
  puts "# of extracted constraints: #{node.constraints.length}"
end

def test_length; end

def test_inclusion; end

def test_format; end

test_naive
test_length
test_inclusion
test_format
