require_relative 'ast_handler'
require_relative 'base_extractor'
require_relative 'constraint'

class BuiltinExtractor < Extractor
  BUILTIN_VALIDATOR = %w[validates_presence_of validates_uniqueness_of
                         validates_format_of validates_length_of
                         validates_inclusion_of has_many has_one has_and_belongs_to_many belongs_to]



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
    validate_type = ast.children[0].source
    case validate_type
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
    when 'has_many'
      constraints = extract_builtin_has_many(ast)
    when 'has_one'
      constraints = extract_builtin_has_one(ast)
    when 'belongs_to'
      constraints = extract_builtin_belongs_to(ast)
    when 'has_and_belongs_to_many'
      constraints = extract_builtin_has_and_belongs_to_many(ast)
    when 'state_machine'
      constraints = extract_builtin_state_machine(ast)
    end
    constraints
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
          if v.type.to_s == "dot2"
            return extract_builtin_numerical(ast)
          end

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

  def extract_builtin_has_one(ast)
    constraints = []
    fields = []
    content = ast[1].children
    class_name = nil
    foreign_key = nil
    callable = nil
    dependent = nil
    content.each do |node|
      #check type
      if node.type.to_s == "fcall"
        callable = node.source.to_s
        next
      end
      field = handle_symbol_literal_node(node)
      fields << field unless field.nil?
      node.each do |n|
        k, v = handle_assoc_node(n)
        if !k.nil? && k == 'class_name'
          class_name = v
        end
        if !k.nil? && k == 'foreign_key'
          foreign_key = v
        end
        if !k.nil? && k == 'dependent'
          dependent = v
        end
      end
    end

    fields.each do |field|
      c = HasOneConstraint.new(field, class_name, foreign_key, callable, dependent)
      constraints << c
    end
    constraints
  end

  def extract_builtin_has_many(ast)
    constraints = []
    fields = []
    content = ast[1].children
    class_name = nil
    foreign_key = nil
    callable = nil
    dependent = nil
    inverse_of = nil
    through = nil
    as = nil
    extend = nil
    content.each do |node|
      #check type
      if node.type.to_s == "fcall"
        callable = node.source.to_s
        next
      end
      field = handle_symbol_literal_node(node)
      fields << field unless field.nil?
      node.each do |n|
        k, v = handle_assoc_node(n)
        if !k.nil? && k == 'class_name'
          class_name = v
        end
        if !k.nil? && k == 'foreign_key'
          foreign_key = v
        end
        if !k.nil? && k == 'dependent'
          dependent = v
        end
        if !k.nil? && k == 'inverse_of'
          inverse_of = v
        end
        if !k.nil? && k == 'through'
          through = v
        end
        if !k.nil? && k == 'as'
          as = v
        end
        if !k.nil? && k == 'extend'
          extend = v
        end
      end
    end

    fields.each do |field|
      c = HasManyConstraint.new(field, class_name, foreign_key, callable, dependent, inverse_of, through, as, extend)
      constraints << c
    end
    constraints
  end

  def extract_builtin_belongs_to(ast)
    constraints = []
    fields = []
    content = ast[1].children
    class_name = nil
    polymorphic = nil
    counter_cache = nil
    content.each do |node|
      #check type
      field = handle_symbol_literal_node(node)
      fields << field unless field.nil?
      node.each do |n|
        k, v = handle_assoc_node(n)
        if !k.nil? && k == 'class_name'
          class_name = v
        end
        if !k.nil? && k == 'polymorphic'
          polymorphic = v
        end
        if !k.nil? && k == 'counter_cache'
          counter_cache = v
        end
      end
    end

    fields.each do |field|
      c = BelongsToConstraint.new(field, class_name, polymorphic, counter_cache)
      constraints << c
      c = PresenceConstraint.new(field, nil)
      constraints << c
    end
    constraints
  end

  def extract_builtin_has_and_belongs_to_many(ast)
    constraints = []
    fields = []
    content = ast[1].children
    class_name = nil
    join_table = nil
    foreign_key = nil
    callable = nil
    content.each do |node|
      #check type
      if node.type.to_s == "fcall"
        callable = node.source.to_s
        next
      end
      field = handle_symbol_literal_node(node)
      fields << field unless field.nil?
      node.each do |n|
        k, v = handle_assoc_node(n)
        if !k.nil? && k == 'class_name'
          class_name = v
        end
        if !k.nil? && k == 'foreign_key'
          foreign_key = v
        end
        if !k.nil? && k == 'join_table'
          join_table = v
        end
      end
    end

    fields.each do |field|
      c = HasAndBelongsToManyConstraint.new(field, class_name, join_table, foreign_key, callable)
      constraints << c
    end
    constraints
  end

  def extract_builtin_state_machine(ast)
    []
  end 

end
