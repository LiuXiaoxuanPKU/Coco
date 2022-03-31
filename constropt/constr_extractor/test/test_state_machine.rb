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
  node = ClassNode.new('Test')
  node.ast = YARD::Parser::Ruby::RubyParser.parse(class_def).root[0]
  state_machine_extractor = StateMachineExtractor.new
  state_machine_extractor.visit(node, {})
  # check for possible errors
  raise "expect 1 constraint, get #{node.constraints.length} constraints" unless node.constraints.length == 1

  if node.constraints[0].values.to_set != %w[done pending].to_set
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
  node = ClassNode.new('Test')
  node.ast = YARD::Parser::Ruby::RubyParser.parse(class_def).root[0]
  state_machine_extractor = StateMachineExtractor.new
  state_machine_extractor.visit(node, {})
  # check for possible errors
  raise "expect 1 constraint, get #{node.constraints.length} constraints" unless node.constraints.length == 1

  if node.constraints[0].values.to_set != %w[created running blocked success failed canceled skipped].to_set
    raise "values should be ['created', 'running', 'blocked', 'success', 'failed', 'canceled', 'skipped'], but get #{node.constraints[0].values}"
  end
end

# Note in the following case, keyword "all" should not be parsed as a state
def test_keyword_all
  class_def = <<-FOO
    class Test
      state_machine :state, initial: :none do
        state :scheduled
        state :ready
        state :failed
        state :obsolete

        event :schedule do
          transition none: :scheduled
        end

        event :mark_ready do
          transition [:scheduled, :failed] => :ready
        end

        event :mark_failed do
          transition all => :failed
        end

        event :mark_obsolete do
          transition all => :obsolete
        end
      end
    end
  FOO
  node = ClassNode.new('Test')
  node.ast = YARD::Parser::Ruby::RubyParser.parse(class_def).root[0]
  state_machine_extractor = StateMachineExtractor.new
  state_machine_extractor.visit(node, {})
  # check for possible errors
  raise "expect 1 constraint, get #{node.constraints.length} constraints" unless node.constraints.length == 1

  if node.constraints[0].values.to_set != %w[scheduled ready failed obsolete none].to_set
    raise "values should be ['scheduled', 'ready', 'failed', 'obsolete', 'none'], but get #{node.constraints[0].values}"
  end
end


def test_after_transition
  class_def = <<-FOO
    class Test
      state_machine :status do
        after_transition [:created, :manual, :waiting_for_resource] => :pending do |bridge|
          next unless bridge.triggers_downstream_pipeline?

          bridge.run_after_commit do
            ::Ci::CreateDownstreamPipelineWorker.perform_async(bridge.id)
          end
        end
      end
    end
  FOO
  node = ClassNode.new('Test')
  node.ast = YARD::Parser::Ruby::RubyParser.parse(class_def).root[0]
  state_machine_extractor = StateMachineExtractor.new
  state_machine_extractor.visit(node, {})
  # check for possible errors
  raise "expect 1 constraint, get #{node.constraints.length} constraints" unless node.constraints.length == 1

  if node.constraints[0].values.to_set != %w[pending manual created waiting_for_resource].to_set
    raise "values should be ['pending', 'manual', 'scheduled', 'created', 'waiting_for_resource'], but get #{node.constraints[0].values}"
  end
end


test_naive
test_naive2
test_keyword_all
test_after_transition