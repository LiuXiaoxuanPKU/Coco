require_relative '../constraint'
require_relative '../engine'
require_relative '../traversor'
require_relative '../state_machine_extractor'

class TestPrint
  def visit(node, _params)
    puts "#{node.name} => #{node.constraints.length}, table #{node.table}"
  end
end

def test_gitlab 
  engine = Engine.new('./data/gitlab_models')
  root = engine.run

  t = Traversor.new(StateMachineExtractor.new)
  t.traverse(root)

  t = Traversor.new(TestPrint.new)
  t.traverse(root)
end

test_gitlab