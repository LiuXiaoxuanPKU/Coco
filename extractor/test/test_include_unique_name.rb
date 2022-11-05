require 'test/unit'
require 'yard'
require_relative '../builtin_extractor'
require_relative '../class_node'

class TestBulitin < Test::Unit::TestCase
  def test_naive
    class_def = <<-FOO
      class StockLocation < Spree::Base
        include UniqueName
      end
    FOO
    node = ClassNode.new('Test')
    node.ast = YARD::Parser::Ruby::RubyParser.parse(class_def).root[0]
    builtin_extractor = BuiltinExtractor.new
    builtin_extractor.visit(node, {})
    raise "expect 2 constraint, get #{node.constraints.length} constraints" unless node.constraints.length == 2
  end
end