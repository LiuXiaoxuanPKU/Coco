require_relative './constraint'
require_relative './base_extractor'
require_relative './ast_handler'

# extract inclusion constraints with state machine type
class StateMachineExtractor < Extractor

  def visit(node, _params)
    return if node.ast.nil?

    ast = node.ast
    ast[2].children.select.each do |c|
      if c.type.to_s == 'command' && c[0].source == 'state_machine'
        constraint = extract_state_machine_inclusion(c)
        node.constraints.append(constraint)
      end
    end
  end

  # begin parsing state machine inclusion constraint
  # return one inclusion constraint extracted by key word "state machine"
  def extract_state_machine_inclusion(ast)
    # get column name
    column = handle_symbol_literal_node(ast[1][0])

    # get state values
    possible_values = []
    ast[2].children[0].each do |c|
      possible_values += parse_state_values(c)
      # get rid of nil
      possible_values = possible_values.compact
      possible_values = possible_values.uniq
    end
    constraint = InclusionConstraint.new(column, possible_values, 'state_machine')
    constraint
  end

  # return state values from state mahine
  def parse_state_values(cmd)
    possible_fields = []
    if cmd.children[0].source == 'event'
      possible_fields += parse_event_cmd(cmd)
    end

    if cmd.children[0].source == "state"
      cmd.children[1].each do |child|
        if child && child.type.to_s == "symbol_literal"
          possible_fields << handle_symbol_literal_node(child)
        end
      end
    end

    if cmd.children[0].source == "after_transition" or cmd.children[0].source == "before_transition" # analogy to "transition"
      # [:created, :manual, :waiting_for_resource] => :pending 
      ast = cmd[1].jump(":assoc")[0]
      possible_fields += parse_transition_cmd(cmd) unless ast.nil?
    end
    possible_fields
  end

  # parse event
  def parse_event_cmd(ast)
    possible_fields = []
    ast = ast.jump(:do_block)
    if ast.children.length != 1
      puts "[Error] even do block can only have one transition " + ast.children.to_s
    end
    ast = ast.children[0][0]
    if ast[0].source == "transition"
      # transition available: :stopped
      possible_fields += parse_transition_cmd(ast)
    end
    possible_fields
  end

  # parse transition
  def parse_transition_cmd(ast) 
    possible_fields = []
    ast = ast[1].jump(":assoc")[0]
    ast.each do |assoc|
      field1 = assoc[0].source if assoc[0].type.to_s == "vcall" # any
      field1 ||= handle_label_node(assoc[0]) if assoc[0].type.to_s == "label"
      next if field1 == "if"
      if field1 != "from" && field1 != "to" && field1 != "any" && field1 != "all"
        possible_fields << field1
      end
      if assoc[1].type.to_s == "array"
        fields = handle_array_node(assoc[1])
        possible_fields += fields if !fields.nil?
      elsif assoc[1].type.to_s == "symbol_literal"
        possible_fields << handle_symbol_literal_node(assoc[1])
      end
    end
    possible_fields
  end



  def handle_array_node(ast)
    scope = []
    if ast.type.to_s == "array" || ast.type.to_s == "var_ref"
      options = nil
  
      if ast.type.to_s == "array"
        options = ast[0]
      end
      if ast.type.to_s == "var_ref" && $cur_class.constants.has_key?(ast[0].source) && $cur_class.constants.has_key?(ast[0].source)
        options = $cur_class.constants[ast[0].source][0]
      end
  
      if options.type.to_s == "list"
        options.each do |child|
          if child.type.to_s == "symbol_literal"
            column = handle_symbol_literal_node(child)
            scope << column
          elsif child.type.to_s == "string_literal"
            column = handle_string_literal_node(child)
            scope << column
          elsif child.type.to_s == "var_ref"
            column = handle_constant_node(child)
            scope << column
          end
        end
      elsif options.type.to_s == "qsymbols_literal" || options.type.to_s == "qwords_literal"
        options.children.each do |child|
          if child.type.to_s == "tstring_content"
            column = handle_tstring_content_node(child)
            scope << column
          end
        end
      end
      return scope # return a list of all possible values
    end
    return nil
  end
  
  def handle_constant_node(ast)
    if $cur_class.constants.has_key?(ast.source)
      const_value = $cur_class.constants[ast.source]
      if const_value.type.to_s == "int"
        return const_value.source.to_i
      end
      return const_value.source
    end
    return nil
  end
end
