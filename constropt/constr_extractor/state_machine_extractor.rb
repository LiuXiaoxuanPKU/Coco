require_relative './constraint'
require_relative './base_extractor'

# extract inclusion constraints with state machine type
class StateMachineExtractor < Extractor

  def visit(node, _params)
    return if node.ast.nil?

    ast = node.ast
    constraints = []
    ast[2].children.select.each do |c|
      if c.type.to_s == 'command' && c[0].source == 'state_machine'
        constraints += extract_state_machine_inclusion(c)
      end
    end
    node.constraints += constraints
  end

  def extract_state_machine_inclusion(ast) 
    possible_values = []
    ast[2].children[0].each do |c|
      possible_values += parse_cmd_get_fields(c)
    end
      constraint = InclusionConstraint.new(column, possible_values, 'state_machine')
    constraint
  end

  def parse_cmd_get_fields(cmd)
    possible_fields = []
    if cmd.children[0].source == "event"
      possible_fields += parse_event_cmd(cmd)
    end
  
    if cmd.children[0].source == "state"
      cmd.children[1].each do |child|
        if child && child.type.to_s == "symbol_literal"
          possible_fields << handle_symbol_literal_node(child)
        end
      end
    end
    possible_fields
  end
end
