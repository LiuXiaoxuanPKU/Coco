require_relative 'ast_handler'
require_relative 'base_extractor'
require_relative 'constraint'

def trim_string(s)
  s.delete_prefix("'").delete_suffix("'").delete_prefix('"').delete_suffix('"')
end

class BuiltinExtractor < Extractor
  BUILTIN_VALIDATOR = %w[validates_presence_of validates_uniqueness_of
                         validates_format_of validates_length_of
                         belongs_to has_one validates_inclusion_of
                         validates_numericality_of validates].freeze

  def initialize
    @builtin_validation_cnt = 0
    @custom_validation_cnt = 0
    @vars = {}
    @node_class = nil
  end

  def visit(node, _params)
    return if node.ast.nil?

    ast = node.ast
    constraints = []
    @node_class = node.name 
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
    when 'belongs_to'
      constraints = extract_builtin_foreign(ast)
    when 'has_one'
      constraints = extract_builtin_has_one(ast)
    end
    constraints
  end

  def extract_validates(ast)
    content = ast[1].children
    constraints = []
    fields = []
    validate_node = nil
    content.each do |c|
      if c.type.to_s == "symbol_literal"
        fields << handle_symbol_literal_node(c)
      else
        validate_node = c
        break
      end
    end

    validate_node.each do |node|
      node_type = node.children[0].type.to_s 
      if node_type == 'label' 
        label = handle_label_node(node.children[0])
      elsif node_type == 'symbol_literal'
        label = handle_symbol_literal_node(node.children[0])
      else
        puts "[Warning] Does not handle node #{node.source} of type #{node_type}, #{ast.source}"
      end
      other = node.children[1]
      if label == 'presence'
        if other.source == 'true'
          cond = nil
        elsif other.type.to_s == 'hash'
        end
        fields.each do |field|
          constraints << PresenceConstraint.new(field, cond)
        end
      elsif label == 'uniqueness'
        cond = nil
        case_sensitive = false
        scope = []
        if other.source == 'true'
          cond = nil
        elsif other.type.to_s == 'hash'
          scope, cond, case_sensitive = extract_unique_scope_cond_sense(other.children)
        end
        fields.each do |field|
          constraints << UniqueConstraint.new(field, cond, case_sensitive, scope)
        end
      elsif label == 'inclusion'
        values = []
        type = 'builtin'
        fields.each do |field|
          constraints << InclusionConstraint.new(field, values, type)
        end
      elsif label == 'length'
        min = -1
        max = -1
        fields.each do |field|
          constraints << LengthConstraint.new(field, min, max)
        end
      elsif label == 'numericality'
        min, max, allow_nil = extract_numerical_hash(other.children)
        fields.each do |field|
          constraints << NumericalConstraint.new(field, min, max, false, allow_nil)
        end
      elsif label == 'allow_blank'
        constraints.each { |c| c.allow_nil = true }
      else
        begin
          puts "[Warning] Does not handle #{field}, #{label.type} #{label.type.to_s}"
          puts "#{other.children}"
        rescue StandardError
        end
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
        if s.type.to_s == 'list'
          s.children.each do |c|
            scope << handle_symbol_literal_node(c)
          end
        elsif s.type.to_s == 'symbol'
          scope << s[0].source
        elsif s.type.to_s == 'qsymbols_literal'
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
    allow_nil = false
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
            begin
              values += Array(eval(to_eval))
            rescue StandardError
              puts "[Error] Fail to eval inclusion value #{to_eval}"
            end
          end
        end

        # allow_blank means the empty string is allowed
        allow_nil = true if !k.nil? && k == 'allow_blank'
      end
    end

    fields.each do |field|
      c = InclusionConstraint.new(field, values, type, false, allow_nil)
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

  def extract_numerical_hash(node)
    min = nil
    max = nil
    allow_nil = false
    node.each do |n|
      k, v = handle_assoc_node(n)
      if !k.nil? && k == 'in'
        min = v[0].source.to_i
        max = v[1].source.to_i
      end
      begin
        min = v[0].to_i if !k.nil? && %w[greater_than_or_equal_to greater_than].include?(k)
        max = v[0].to_i if !k.nil? && %w[less_than_or_equal_to less_than].include?(k)
      rescue StandardError
        puts "[Error] Fail to parse min, max value k: #{k}, v: #{v.source}"
      end
      allow_nil = true if !k.nil? && %w[allow_nil allow_blank].include?(k)
    end
    [min, max, allow_nil]
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
      tmp_min, tmp_max, tmp_allow_nil = extract_numerical_hash(node)
      min = tmp_min unless tmp_min.nil?
      max = tmp_max unless tmp_max.nil?
      allow_nil ||= tmp_allow_nil
    end
    fields.each do |field|
      c = NumericalConstraint.new(field, min, max, false, allow_nil)
      constraints << c
    end
    constraints
  end

  def extract_builtin_foreign(ast)
    constraints = []
    fields = []
    content = ast[1].children
    class_name = nil
    fk_column_name = nil
    polymorphic = nil
    content.each do |node|
      field = handle_symbol_literal_node(node)
      fields << field unless field.nil?
      node.children.each do |n|
        k, v = handle_assoc_node(n)
        fk_column_name = trim_string(v.source) if !k.nil? && (k == 'foreign_key')
        class_name = trim_string(v.source) if !k.nil? && (k == 'class_name')
        polymorphic = eval(trim_string(v.source)) if !k.nil? && (k == 'polymorphic')
      end
    end

    if class_name.nil?
      class_name = fields[0].capitalize
    end
    if fk_column_name.nil?
      fk_column_name = fields[0].downcase
      fk_column_name << "_id"
    end

    fields.each do |field|
      c = ForeignKeyConstraint.new(field, class_name, fk_column_name, polymorphic)
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
    as_field = nil
    content.each do |node|
      field = handle_symbol_literal_node(node)
      fields << field unless field.nil?
      node.children.each do |n|
        if n[0].class == String or n[0] == nil
          next
        else
          k, v = handle_assoc_node(n)
        end
        foreign_key = trim_string(v.source) if !k.nil? && (k == 'foreign_key')
        class_name = trim_string(v.source) if !k.nil? && (k == 'class_name')
        as_field = trim_string(v.source) if !k.nil? && (k == 'as')
      end
    end

    if class_name.nil?
      class_name = fields[0].capitalize
    end
    if foreign_key.nil?
      foreign_key = @node_class.downcase
      foreign_key << "_id"
    end

    fields.each do |field|
      c = HasOneConstraint.new(field, class_name, foreign_key, as_field)
      constraints << c
    end
    constraints
  end

end
