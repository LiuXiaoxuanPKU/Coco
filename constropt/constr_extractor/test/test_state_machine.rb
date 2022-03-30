require_relative '../constraint'
require_relative '../engine'
require_relative '../traversor'
require_relative '../state_machine_extractor'
require_relative '../class_node'
require 'yard'


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

# uncomment the following if want to run through an application
# test_gitlab


############################## unit tests #################################
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
  # check for possible errors
  raise "expect 1 constraint, get #{node.constraints.length} constraints" unless node.constraints.length == 1

  if node.constraints[0].values != %w[done pending]
    raise "values should be ['done', 'pending'], but get #{node.constraints[0].values}"
  end
end

def test_naive2
  class_def = <<-FOO
    class Test
        state_machine :status, initial: :created do
            event :run do
            transition created: :running
            end

            event :block do
            transition created: :blocked
            end

            event :unblock do
            transition blocked: :created
            end

            event :succeed do
            transition any - [:success] => :success
            end

            event :drop do
            transition any - [:failed] => :failed
            end

            event :cancel do
            transition any - [:canceled] => :canceled
            end

            event :skip do
            transition any - [:skipped] => :skipped
            end
        end
    end
  FOO
  node = ClassNode .new('Test')
  node.ast = YARD::Parser::Ruby::RubyParser.parse(class_def).root[0]
  state_machine_extractor = StateMachineExtractor.new
  state_machine_extractor.visit(node, {})
  # check for possible errors
  raise "expect 1 constraint, get #{node.constraints.length} constraints" unless node.constraints.length == 1

  if node.constraints[0].values != %w[created running blocked success failed canceled skipped]
    raise "values should be ['created', 'running', 'blocked', 'success', 'failed', 'canceled', 'skipped'], but get #{node.constraints[0].values}"
  end
end

test_naive
test_naive2