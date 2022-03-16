require_relative '../constraint'
require_relative '../engine'
require_relative '../traversor'
require_relative '../state_machine_extractor'
require_relative '../class_node'
require 'yard'

# class TestPrint
#   def visit(node, _params)
#     puts "#{node.name} => #{node.constraints.length}, table #{node.table}"
#   end
# end

# def test_gitlab 
#   engine = Engine.new('./data/gitlab_models')
#   root = engine.run

#   t = Traversor.new(StateMachineExtractor.new)
#   t.traverse(root)

#   t = Traversor.new(TestPrint.new)
#   t.traverse(root)
# end

# test_gitlab

def test_naive 
  class_def = <<-FOO
    class Test
      state_machine :state, initial: :pending do
        event :done do
          transition [:pending] => :done
        end
        
        state :pending
        state :done
      end
    end
  FOO
  node = ClassNode .new('Test')
  node.ast = YARD::Parser::Ruby::RubyParser.parse(class_def).root[0]
  state_machine_extractor = StateMachineExtractor.new
  state_machine_extractor.visit(node, {})
  puts "# of extracted constraints: #{node.constraints.length}"
  puts "extracted constraints: #{node.constraints}"
end

test_naive