require_relative 'ast_handler'
require_relative 'base_extractor'
require_relative 'constraint'

class BuiltinExtractor < Extractor
  BUILTIN_VALIDATOR = %w[validates_presence_of validates_uniqueness_of
                         validates_format_of validates_length_of
                         validates].freeze

  def initialize
    @builtin_validation_cnt = 0
    @custom_validation_cnt = 0
    @vars = {}
  end

  def visit(node, _params)
    return if node.ast.nil?

    ast = node.ast
    constraints = []
    ast[2].children.select.each do |c|
      @vars[c[0].source] = c[1] if c.type.to_s == 'assign'

      constraints += extract_cmd(c) if c.type.to_s == 'command'
    end
    node.constraints += constraints
  end

  def extract_cmd(c)
    constraints = []
    ident = c[0].source
    if BUILTIN_VALIDATOR.include? ident
      @builtin_validation_cnt += 1
      constraints += extract_bultin_validator(c)
    elsif ident == 'validate'
      @custom_validation_cnt += 1
    end
    constraints
  end

  def extract_bultin_validator(ast)
    # puts ast.source
    validate_type = ast.children[0].source
    case validate_type
    when 'validates'
      constraints = extract_validates(ast)
    when 'validates_presence_of'
      constraints = extract_builtin_presence(ast)
    when 'validates_uniqueness_of'
      constraints = extract_builtin_unique(ast)
    when 'validates_format_of'
      constraints = extract_builtin_format(ast)
    when 'validates_inclusion_of'
      constraints = extract_builtin_inclusion(ast)
    when 'validates_length_of'
      constraints = extract_builtin_length(ast)
    when 'validates_numericality_of'
      constraints = extract_builtin_numerical(ast)
    end
    constraints
  end

  def extract_validates(ast)
    content = ast[1].children
    constraints = []
    field = handle_symbol_literal_node(content[0])
    content[1].each do |node|
      label = handle_label_node(node.children[0])
      other = node.children[1]
      if label == 'presence'
        if other.source == 'true'
          cond = nil
        elsif other.type.to_s == 'hash'
        end
        constraints << PresenceConstraint.new(field, cond)
      elsif label == 'uniqueness'
        cond = nil
        case_sensitive = false
        scope = []
        if other.source == 'true'
          cond = nil
        elsif other.type.to_s == 'hash'
          scope, cond, case_sensitive = extract_unique_scope_cond_sense(other.children)
        end
        constraints << UniqueConstraint.new(field, cond, case_sensitive, scope)
      elsif label == 'inclusion'
        values = []
        type = 'builtin'
        constraints << InclusionConstraint.new(field, values, type)
      elsif label == 'length'
        min = -1
        max = -1
        constraints << LengthConstraint.new(field, min, max)
      end
    end
    constraints
  end

  def extract_unique_scope_cond_sense(nodes)
    scope = []
    cond = nil
    case_sensitive = nil
    nodes.each do |n|
      k, v = handle_assoc_node(n)
      cond = v if !k.nil? && (k == 'if')
      case_sensitive = (v.source.downcase == 'true') if !k.nil? && (k == 'case_sensitive')
      next if k.nil? || (k != 'scope')

      v.children.each do |s|
        if s.type.to_s == "list"
          s.children.each do |c|
            scope << handle_symbol_literal_node(c)
          end
        elsif s.type.to_s == "symbol"
          scope << s[0].source
        elsif s.type.to_s == "qsymbols_literal"
          scope = handle_qsymbols_literal(s)
        else
          puts "[Warning] Unsupport scope #{s.source} of type #{s.type}"
        end
      end  
    end
    [scope, cond, case_sensitive]
  end

  def extract_builtin_unique(ast)
    fields = []
    constraints = []
    scope = []
    content = ast[1].children
    cond = nil
    case_sensitive = nil
    content.each do |node|
      field = handle_symbol_literal_node(node)
      fields << field unless field.nil?
      scope, cond, case_sensitive = extract_unique_scope_cond_sense(node.children)
    end
    fields.each do |field|
      c = UniqueConstraint.new(field, cond, case_sensitive, scope)
      constraints << c
    end
    constraints
  end

  def extract_builtin_presence(ast)
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
      c = PresenceConstraint.new(field, cond)
      constraints << c
    end
    constraints
  end

  def extract_builtin_inclusion(ast)
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
          return extract_builtin_numerical(ast) if v.type.to_s == 'dot2'

          type = 'builtin'

          unless %w[proc Proc].include? v[0].source # just excluding two edge cases
            to_eval = v.source.to_s
            old_eval = ''
            # replaces all instances of the variable name with a string
            # of the corresponding value before eval
            while old_eval != to_eval
              old_eval = to_eval.dup
              @vars.each do |key, value|
                to_eval.gsub! key, value.source.to_s
              end
            end
            values += Array(eval(to_eval))
          end
        end

        # allow_blank means the empty string is allowed
        values << '' if !k.nil? && k == 'allow_blank'
      end
    end

    fields.each do |field|
      c = InclusionConstraint.new(field, values, type)
      constraints << c
    end
    constraints
  end

  def extract_builtin_format(ast)
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
      c = FormatConstraint.new(field, format)
      constraints << c
    end
    constraints
  end

  def extract_builtin_length(ast)
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
      constraint = LengthConstraint.new(field, min, max)
      constraints << constraint
    end
    constraints
  end

  def extract_builtin_numerical(ast)
    constraints = []
    fields = []
    content = ast[1].children
    min = nil
    max = nil
    allow_nil = false
    content.each do |node|
      field = handle_symbol_literal_node(node)
      fields << field unless field.nil?
      node.each do |n|
        k, v = handle_assoc_node(n)
        if !k.nil? && k == 'in'
          min = v[0].source.to_i
          max = v[1].source.to_i
        end

        allow_nil = true if !k.nil? && k == 'allow_nil'
      end
    end

    fields.each do |field|
      c = NumericalConstraint.new(field, min, max, allow_nil)
      constraints << c
    end
    constraints
  end
end
