require_relative 'ast_handler'
require_relative 'base_extractor'
require_relative 'constraint'

def trim_string(s)
  s.delete_prefix("'").delete_suffix("'").delete_prefix('"').delete_suffix('"').downcase
end

class BuiltinExtractor < Extractor
  BUILTIN_VALIDATOR = %w[validates_presence_of validates_uniqueness_of
                         validates_format_of validates_length_of
                         validates_inclusion_of has_many has_one belongs_to]


  def initialize
    @builtin_validation_cnt = 0
    @custom_validation_cnt = 0
    @class_name = nil
    @vars = {}
    # @root = nil
    # @has_ones = []
    # @has_manys = []
    # @belongs_tos = []
  end

  def visit(node, _params)
    # if node.parent.nil? and @root.nil?
    #   @root = node
    # end
    return if node.ast.nil?

    ast = node.ast
    constraints = []
    @class_name = trim_string(ast[0].source.to_s)
    ast[2].children.select.each do |c|
      @vars[c[0].source] = c[1] if c.type.to_s == 'assign'

      constraints += extract_cmd(c) if c.type.to_s == 'command'
    end

    node.constraints += constraints

    #update root node's relationships
    # @root.misc["has_ones"] = @has_ones
    # @root.misc["has_manys"] = @has_manys
    # @root.misc["belongs_tos"] = @belongs_tos
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
    constraints = []
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
    # when 'has_one'
    #   extract_builtin_has_one(ast)
    # when 'has_many'
    #   extract_builtin_has_many(ast)
    when 'belongs_to'
      # extract_builtin_belongs_to(ast)
      extract_builtin_foreign(ast)
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
    # puts @class_name
    # p ast
    # p ast.source

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

  def extract_builtin_foreign(ast)
    constraints = []
    fields = []
    content = ast[1].children
    class_name = nil
    fk_column_name = nil
    content.each do |node|
      field = handle_symbol_literal_node(node)
      fields << field unless field.nil?
      node.children.each do |n|
        k, v = handle_assoc_node(n)
        fk_column_name = v if !k.nil? && (k == 'foreign_key')
        class_name = v if !k.nil? && (k == 'class_name')
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
      c = ForeignKeyConstraint.new(field, class_name, fk_column_name)
      constraints << c
    end
    constraints
  end

  # def extract_builtin_has_one(ast)
  #   fields = []
  #   content = ast[1].children
  #   foreign_key = nil
  #   content.each do |node|
  #     if node.type.to_s == "fcall"
  #       next
  #     end
  #     field = handle_symbol_literal_node(node)
  #     fields << field unless field.nil?
  #     node.each do |n|
  #       k, v = handle_assoc_node(n)
  #       if !k.nil? && k == 'class_name'
  #         fields[0] = trim_string(v.source.to_s)
  #       end
  #       if !k.nil? && k == 'foreign_key'
  #         foreign_key = trim_string(v.source.to_s)
  #       end
  #     end
  #   end
  #
  #   e = {"from_class" => @class_name, "class_name" => fields[0], "foreign_key" => foreign_key}
  #   @has_ones.append(e)
  # end
  #
  # def extract_builtin_has_many(ast)
  #   fields = []
  #   content = ast[1].children
  #   foreign_key = nil
  #   content.each do |node|
  #     if node.type.to_s == "fcall"
  #       next
  #     end
  #     field = handle_symbol_literal_node(node)
  #     fields << field unless field.nil?
  #     node.each do |n|
  #       k, v = handle_assoc_node(n)
  #       if !k.nil? && k == 'class_name'
  #         fields[0] = trim_string(v.source.to_s)
  #       end
  #       if !k.nil? && k == 'foreign_key'
  #         foreign_key = trim_string(v.source.to_s)
  #       end
  #     end
  #   end
  #
  #   e = {"from_class" => @class_name, "class_name" => fields[0].singularize, "foreign_key" => foreign_key}
  #   @has_manys.append(e)
  # end
  #
  # def extract_builtin_belongs_to(ast)
  #   fields = []
  #   content = ast[1].children
  #   foreign_key = nil
  #   polymorphic = false
  #   content.each do |node|
  #     if node.type.to_s == "fcall"
  #       next
  #     end
  #     field = handle_symbol_literal_node(node)
  #     fields << field unless field.nil?
  #     node.each do |n|
  #       k, v = handle_assoc_node(n)
  #       if !k.nil? && k == 'class_name'
  #         fields[0] = trim_string(v.source.to_s)
  #       end
  #       if !k.nil? && k == 'foreign_key'
  #         foreign_key = trim_string(v.source.to_s)
  #       end
  #       if !k.nil? && k == 'polymorphic'
  #         polymorphic = true
  #       end
  #
  #     end
  #   end
  #
  #   if foreign_key.nil?
  #     foreign_key = fields[0] + "_id"
  #   end
  #
  #   e = {"from_class" => @class_name, "class_name" => fields[0], "foreign_key" => foreign_key, "polymorphic" => polymorphic}
  #   @belongs_tos.append(e)
  # end

  def extract_builtin_state_machine(ast)
    []
  end


end
