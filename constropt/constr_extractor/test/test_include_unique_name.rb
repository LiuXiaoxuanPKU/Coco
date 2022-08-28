require 'yard'
require_relative '../builtin_extractor'
require_relative '../class_node'

def test_naive
  puts '==============Test Naive=============='
  class_def = <<-FOO
    class StockLocation < Spree::Base
      include UniqueName
    end
  FOO
  node = ClassNode.new('Test')
  node.ast = YARD::Parser::Ruby::RubyParser.parse(class_def).root[0]
  builtin_extractor = BuiltinExtractor.new
  builtin_extractor.visit(node, {})
  puts "# of extracted constraints: #{node.constraints.length}"
end

test_naive