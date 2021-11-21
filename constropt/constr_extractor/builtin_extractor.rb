require_relative 'ast_handler'
require_relative 'base_extractor'
require_relative 'constraint'

class BuiltinExtractor < Extractor
  BUILTIN_VALIDATOR = %w[validates_presence_of validates_uniqueness_of
                         validates_format_of validates_length_of
                         validates_inclusion_of]

  def initialize
    @builtin_validation_cnt = 0
    @custom_validation_cnt = 0
  end

  def visit(node)
    ast = node.ast[0]
    commands = ast[2].children.select { |c| c.type.to_s == 'command' }
    constraints = []
    commands.each { |c| constraints += extract_cmd(c, node.name) }
    node.constraints += constraints
  end

  def extract_cmd(c, class_name)
    constraints = []
    ident = c[0].source
    if BUILTIN_VALIDATOR.include? ident
      @builtin_validation_cnt += 1
      constraints += extract_bultin_validator(c, class_name)
    elsif ident == 'validate'
      @custom_validation_cnt += 1
    end
    constraints
  end

  def extract_bultin_validator(ast, classname)
    # puts ast.source
    validate_type = ast.children[0].source
    case validate_type
    when 'validates_presence_of'
      constraints = extract_builtin_presence(ast, classname)
    when 'validates_uniqueness_of'
      constraints = extract_builtin_unique(ast, classname)
    when 'validates_format_of'
      constraints = extract_builtin_format(ast, classname)
    when 'validates_inclusion_of'
      constraints = extract_builtin_inclusion(ast, classname)
    when 'validates_length_of'
      constraints = extract_builtin_length(ast, classname)
    when 'validates_numericality_of'
      constraints = extract_builtin_numerical(ast, classname)
    end
    constraints
  end

  def extract_builtin_unique(ast, classname)
    fields = []
    constraints = []
    scope = []
    content = ast[1].children
    cond = nil
    case_sensitive = nil
    content.each do |node|
      field = handle_symbol_literal_node(node)
      fields << field unless field.nil?
      node.children.each do |n|
        k, v = handle_assoc_node(n)
        cond = v if !k.nil? && (k == 'if')
        case_sensitive = (v.source.downcase == 'true') if !k.nil? && (k == 'case_sensitive')
        next unless !k.nil? && (k == 'scope')

        v.children.each do |s|
          scope << if s.type.to_s == 'symbol'
                     s[0].source
                   else
                     handle_symbol_literal_node(s[0])
                   end
        end
      end
    end
    fields.each do |field|
      c = UniqueConstraint.new(classname, field, cond, case_sensitive, scope)
      constraints << c
    end
    constraints
  end

  def extract_builtin_presence(ast, classname)
    fields = []
    constraints = []
    content = ast[1].children
    cond = nil
    content.each do |node|
      field = handle_symbol_literal_node(node)
      fields << field unless field.nil?
      k, v = handle_assoc_node(node[0])
      cond = v if !k.nil? && (k == 'if')
    end
    fields.each do |field|
      c = PresenceConstraint.new(classname, field, cond)
      constraints << c
    end
    constraints
  end

  def extract_builtin_inclusion(ast, classname)
    constraints = []
    fields = []
    content = ast[1].children
    values = []
    type = nil
    content.each do |node|
      field = handle_symbol_literal_node(node)
      fields << field unless field.nil?
      node.each do |n|
        k, v = handle_assoc_node(n)
        if !k.nil? && k == 'in'
          type = v.type

          # #user code directly references a variable
          # if v.type.to_s == "var_ref" and $vars.has_key?(v.source)
          #   values += eval(to_extract.source)
          #   #   #example of to_extract.children:
          #   #   #[s(:tstring_content, "none"), s(:tstring_content, "descendants"), s(:tstring_content, "hierarchy"),
          #   #   #s(:tstring_content, "tree"), s(:tstring_content, "system")]
          # end

          # #user code performs a function call, use eval() to perform it here
          # if v.type.to_s == "call"
          #   to_eval = ""
          #   i = 0
          #   v.children.each { |elem|
          #     if elem.type.to_s == "var_ref" and $vars.has_key?(elem.source)
          #       to_eval << $vars[v.children[i].source].source
          #     else
          #       to_eval << elem.source
          #     end
          #     i = i + 1
          #   }
          #   #what it looks like before parsing:
          #   #[\n    [\"all\", :label_user_mail_option_all],\n    [\"selected\", :label_user_mail_option_selected],\n
          #   # [\"only_my_events\", :label_user_mail_option_only_my_events],\n    [\"only_assigned\", :label_user_mail_option_only_assigned],\n
          #   # [\"only_owner\", :label_user_mail_option_only_owner],\n    [\"none\", :label_user_mail_option_none],\n  ].collect(&:first)
          #   values += eval(to_eval)
          # end
        end

        # allow_blank means the empty string is allowed
        values << '' if !k.nil? && k == 'allow_blank'
      end
    end
    fields.each do |field|
      c = InclusionConstraint.new(classname, field, values, type)
      constraints << c
    end
    constraints
  end

  def extract_builtin_format(ast, classname)
    constraints = []
    fields = []
    format = nil
    content = ast[1].children
    content.each do |node|
      field = handle_symbol_literal_node(node)
      fields << field unless field.nil?
      k, v = handle_assoc_node(node[0])
      format = v.source if k == 'with'
    end
    fields.each do |field|
      c = FormatConstraint.new(classname, field, format)
      constraints << c
    end
    constraints
  end

  def extract_builtin_length(ast, classname)
    constraints = []
    min = nil
    max = nil
    fields = []
    content = ast[1].children
    content.each do |node|
      field = handle_symbol_literal_node(node)
      fields << field unless field.nil?
      node.each do |n|
        k, v = handle_assoc_node(n)
        max = v.source.to_i if !k.nil? && k == 'maximum' && v.type.to_s == 'int'
        min = v.source.to_i if !k.nil? && k == 'minimum' && v.type.to_s == 'int'
      end
    end
    fields.each do |field|
      constraint = LengthConstraint.new(classname, field, min, max)
      constraints << constraint
    end
    constraints
  end

  def extract_builtin_numerical(ast, _classname); end
end
