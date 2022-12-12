require_relative 'ast_handler'
require_relative 'base_extractor'
require_relative 'constraint'

def trim_string(s)
  s.delete_prefix("'").delete_suffix("'").delete_prefix('"').delete_suffix('"').delete_prefix(":")
end

class BuiltinExtractor < Extractor
  attr_accessor :builtin_validation_cnt, :custom_validation_cnt
  BUILTIN_VALIDATOR = %w[validates_presence_of validates_uniqueness_of
                         validates_format_of validates_length_of
                         belongs_to has_one has_many
                         validates_inclusion_of
                         validates_numericality_of validates].freeze

  def initialize(db_schema=nil)
    super(db_schema)
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
    set_constraints(node, filter_validate_constraints(node, constraints))
  end

  def extract_cmd(c)
    constraints = []
    ident = c[0].source
    if BUILTIN_VALIDATOR.include? ident
      @builtin_validation_cnt += 1
      constraints += extract_bultin_validator(c)
    elsif ident == 'validate'
      @custom_validation_cnt += 1
    elsif ident == 'with_options'
      constraints += extract_with_option(c)
    elsif ident == 'include'
      constraints += extract_unique_name_from_include(c)
    end
    constraints
  end

  def extract_unique_name_from_include(ast)
    if ast.source == 'include UniqueName'
      pc = PresenceConstraint.new('name', nil, ConstrainType::DATA_VALIDATION)
      uc = UniqueConstraint.new(['name'], nil, false, 'builtin', ConstrainType::DATA_VALIDATION)
      [pc, uc]
    else
      []
    end
  end

  def extract_with_option(ast)
    all_fields = []
    constraints = []
    is_validate = false

    do_block = ast.jump(:do_block)
    do_block.children[0].each do |cmd|
      label = cmd.children[0]
      case label.source
      when 'belongs_to'
        constraints += extract_builtin_foreign(cmd)
      when 'has_many', 'has_one'
        constraints += extract_builtin_has_one_many(cmd, label.source)
      when 'validates'
        is_validate = true
        content = cmd[1].children
        opt_start_idx, fields = extract_validates_constraint_fields(content)
        if opt_start_idx <= content.length - 1
          constraints, fields = extract_validates_constraint_options(fields, content[opt_start_idx])
        end
        all_fields += fields
      else
        puts "[Error] With Option: Does not handle #{cmd.source}"
      end
    end

    if is_validate
      common_options_ast = ast.children[1]
      tmp_constraints, valid_fields = extract_validates_constraint_options(all_fields, common_options_ast[0], false)
      constraints += tmp_constraints
    end
    constraints.uniq
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
    when 'has_one', 'has_many'
      constraints = extract_builtin_has_one_many(ast, validate_type)
    end
    constraints
  end

  def extract_validates_constraint_fields(tokens)
    fields = []
    next_idx = tokens.length
    tokens.each_with_index do |c, index|
      if c.type.to_s == 'symbol_literal'
        fields << handle_symbol_literal_node(c)
      else
        next_idx = index
        break
      end
    end
    [next_idx, fields]
  end

  def extract_validates_constraint_options(fields, validate_node, add_presence=true)
    constraints = []
    presence_fields = []
    allow_nil = false
    valid_fields = fields
    validate_node.each do |node|
      next if node.children.empty?

      node_type = node.children[0].type.to_s
      case node_type
      when 'label'
        label = handle_label_node(node.children[0])
      when 'symbol_literal'
        label = handle_symbol_literal_node(node.children[0])
      else
        puts "[Warning] Does not handle node #{node.source} of type #{node_type}"
        next
      end

      other = node.children[1]
      case label
      when 'presence'
        if other.source == 'true'
          cond = nil
        elsif other.type.to_s == 'hash'
          puts "[Warning] Does not handle #{other.source} for now"
          next
        end
        fields.each do |field|
          presence_fields << field
          constraints << PresenceConstraint.new(field, cond, ConstrainType::DATA_VALIDATION)
        end
      when 'uniqueness'
        cond = nil
        case_sensitive = false
        scope = []
        if other.source == 'true'
          cond = nil
        elsif other.type.to_s == 'hash'
          scope, cond, case_sensitive, allow_nil = extract_unique_scope_cond_sense(other.children)
        end
        fields.each do |field|
          type = 'builtin'
          constraints << UniqueConstraint.new([field] + scope, cond, case_sensitive, type, ConstrainType::DATA_VALIDATION)
        end
      when 'inclusion'
        values = []
        type = 'builtin'
        fields.each do |field|
          constraints << InclusionConstraint.new(field, values, type, ConstrainType::DATA_VALIDATION)
        end
      when 'length'
        min = -1
        max = -1
        fields.each do |field|
          constraints << LengthConstraint.new(field, min, max, ConstrainType::DATA_VALIDATION)
        end
      when 'numericality'
        # does not extract constraints from 'numericality: true'
        next if other.children.length == 1 && other.children[0].type == :kw

        min, max, allow_nil = extract_numerical_hash(other.children)
        fields.each do |field|
          constraints << NumericalConstraint.new(field, min, max, ConstrainType::DATA_VALIDATION)
        end
      when 'format'
        # TODO: extract format pattern
        fields.each do |field|
          constraints << FormatConstraint.new(field, nil, ConstrainType::DATA_VALIDATION)
        end
      when 'allow_blank', 'allow_nil'
        allow_nil = true
      when "characters", "associated", "image", "utf8", "confirmation", "whitespace"
        # do nothing
      else
        puts "[Warning] Does not handle complex validates: #{label}, #{other.source}"
        valid_fields = []
        # only keeps format and length constraints
        constraints = constraints.filter{|f| f.is_a?(LengthConstraint) || f.is_a?(FormatConstraint)}
        next
      end
    end

    return [constraints, valid_fields] if allow_nil
    return [constraints, valid_fields] if !add_presence
    
    # add corresponding presence constraints
    all_constraints = []
    valid_fields.each do |field|
      if !allow_nil && !(presence_fields.include? field)
        all_constraints << PresenceConstraint.new(field, nil, ConstrainType::DATA_VALIDATION)
      end
    end
    all_constraints += constraints
    [all_constraints, valid_fields]
  end

  def extract_validates(ast)
    content = ast[1].children
    # extract constraint fields
    opt_start_idx, fields = extract_validates_constraint_fields(content)

    # extract constraint options
    constraints, fields = extract_validates_constraint_options(fields, content[opt_start_idx])
    constraints
    # # set constraint fields
    # constraints = extract_validates_set_fields(fields, constraints)
  end

  def extract_unique_scope_cond_sense(nodes)
    scope = []
    cond = nil
    case_sensitive = false
    allow_nil = false # default is false for validate_uniqueness_of
    nodes.each do |n|
      k, v = handle_assoc_node(n)
      cond = v if !k.nil? && (k == 'if')
      case_sensitive = (v.source.downcase == 'true') if !k.nil? && (k == 'case_sensitive')
      allow_nil = (v.source.downcase == 'true') if !k.nil? && (%w[allow_nil allow_blank].include? k)
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
    [scope, cond, case_sensitive, allow_nil]
  end

  def extract_builtin_unique(ast)
    fields = []
    constraints = []
    scope = []
    content = ast[1].children
    cond = nil
    case_sensitive = false
    allow_nil = false
    content.each do |node|
      field = handle_symbol_literal_node(node)
      fields << field unless field.nil?
      scope, cond, case_sensitive, allow_nil = extract_unique_scope_cond_sense(node.children)
    end
    fields.each do |field|
      type = 'builtin'
      constraints << UniqueConstraint.new([field] + scope, cond, case_sensitive, type, ConstrainType::DATA_VALIDATION)
      constraints << PresenceConstraint.new(field, cond, ConstrainType::DATA_VALIDATION) unless allow_nil
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
      constraints << PresenceConstraint.new(field, cond, ConstrainType::DATA_VALIDATION)
      constraints << PresenceConstraint.new(field + "_id", cond, ConstrainType::DATA_VALIDATION)
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
        allow_nil = (v.source.downcase == 'true') if !k.nil? && (%w[allow_nil allow_blank].include? k)
      end
    end

    fields.each do |field|
      constraints << InclusionConstraint.new(field, values, type, ConstrainType::DATA_VALIDATION)
      constraints << PresenceConstraint.new(field, nil, ConstrainType::DATA_VALIDATION) unless allow_nil
    end
    constraints
  end

  def extract_builtin_format(ast)
    constraints = []
    fields = []
    format = nil
    allow_nil = false
    content = ast[1].children
    content.each do |node|
      field = handle_symbol_literal_node(node)
      fields << field unless field.nil?
      k, v = handle_assoc_node(node[0])
      format = v.source if k == 'with'
      allow_nil = (v.source.downcase == 'true') if !k.nil? && (%w[allow_nil allow_blank].include? k)
    end
    fields.each do |field|
      constraints << FormatConstraint.new(field, format, ConstrainType::DATA_VALIDATION)
      constraints << PresenceConstraint.new(field, nil, ConstrainType::DATA_VALIDATION) unless allow_nil
    end
    constraints
  end

  def extract_builtin_length(ast)
    constraints = []
    min = nil
    max = nil
    allow_nil = false
    fields = []
    content = ast[1].children
    content.each do |node|
      field = handle_symbol_literal_node(node)
      fields << field unless field.nil?
      node.each do |n|
        k, v = handle_assoc_node(n)
        max = v.source.to_i if !k.nil? && k == 'maximum' && v.type.to_s == 'int'
        min = v.source.to_i if !k.nil? && k == 'minimum' && v.type.to_s == 'int'
        allow_nil = (v.source.downcase == 'true') if !k.nil? && (%w[allow_nil allow_blank].include? k)
      end
    end
    fields.each do |field|
      constraints << LengthConstraint.new(field, min, max, ConstrainType::DATA_VALIDATION)
      constraints << PresenceConstraint.new(field, nil, ConstrainType::DATA_VALIDATION) if !allow_nil && (!min.nil? && min > 0)
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
        min = v.source.to_i if !k.nil? && %w[greater_than_or_equal_to greater_than].include?(k)
        max = v.source.to_i if !k.nil? && %w[less_than_or_equal_to less_than].include?(k)
      rescue StandardError
        puts "[Error] Fail to parse min, max value k: #{k}, v: #{v.source} #{v[0]}"
      end
      allow_nil = true if !k.nil? && %w[allow_nil allow_blank].include?(k) && v.source.downcase == 'true'
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
      constraints << NumericalConstraint.new(field, min, max, ConstrainType::DATA_VALIDATION)
      constraints << PresenceConstraint.new(field, nil, ConstrainType::DATA_VALIDATION) unless allow_nil
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
    optional = false
    content.each do |node|
      field = handle_symbol_literal_node(node)
      fields << field unless field.nil?
      node.children.each do |n|
        next if node.type == :lambda

        k, v = handle_assoc_node(n)
        fk_column_name = trim_string(v.source) if !k.nil? && (k == 'foreign_key')
        class_name = trim_string(v.source) if !k.nil? && (k == 'class_name')
        polymorphic = eval(trim_string(v.source)) if !k.nil? && (k == 'polymorphic')
        optional = true if !k.nil? && k == 'optional' && v.source == 'true'
      end
    end

    class_name = fields[0].capitalize if class_name.nil?
    if fk_column_name.nil?
      fk_column_name = fields[0].downcase
      fk_column_name << '_id'
    end

    fields.each do |field|
      constraints << ForeignKeyConstraint.new(fk_column_name, class_name, field, polymorphic, ConstrainType::CLASS_RELATIONSHIP)
      if !optional
        constraints << PresenceConstraint.new(fk_column_name, nil, ConstrainType::OTHER)
      end
    end
    constraints
  end

  def extract_builtin_has_one_many(ast, validate_type)
    constraints = []
    fields = []
    content = ast[1].children
    class_name = nil
    foreign_key = nil
    as_field = nil
    through = nil
    content.each do |node|
      field = handle_symbol_literal_node(node)
      fields << field unless field.nil?
      node.children.each do |n|
        if n[0].instance_of?(String) or n[0].nil?
          next
        else
          k, v = handle_assoc_node(n)
        end

        foreign_key = trim_string(v.source) if !k.nil? && (k == 'foreign_key')
        class_name = trim_string(v.source) if !k.nil? && (k == 'class_name')
        as_field = handle_symbol_literal_node(v) if !k.nil? && (k == 'as')
        through = handle_symbol_literal_node(v) if !k.nil? && (k == 'through')
      end
    end

    class_name = fields[0].classify if class_name.nil?
    if foreign_key.nil?
      foreign_key = @node_class.downcase
      foreign_key << '_id'
    end

    fields.each do |field|
      constraints << HasOneManyConstraint.new(field, class_name, foreign_key, as_field, validate_type, through,
        ConstrainType::OTHER)
    end
    constraints
  end

end
