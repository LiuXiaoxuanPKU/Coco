require_relative "./ast_handler"

class Extractor
  BUILTIN_VALIDATOR = ["validates_presence_of", "validates_uniqueness_of", "validates_format_of",
                       "validates_length_of", "validates_inclusion_of"]

  def initialize(rules)
    @rules = rules
  end

  def setRule(rules)
    @rules = rules
  end

  # {:builtin => extractBuiltin}
  # files: a list of ConstraintFile objects
  def extractAll(files)
    @rules.each {
      method(rule).call(files)
    }
  end

  def extractBuiltin(files)
    constraints = []
    files.each { |f| constraints += extractBuiltinHelper(f.ast) }
    return constraints
  end

  def extractBuiltinHelper(ast)
    constraints = []
    if ast.type.to_s == "list"
      ast.children.each { |c| constraints += extractBuiltinHelper(c) }
    end
    if ast.type.to_s == "class"
      constraints += extractClass(ast)
    end
    return constraints
  end

  def extractClass(ast)
    constraints = []
    class_name = ast[0].source
    parent_class_name = ast[1].source
    commands = ast[2].children.select { |c| c.type.to_s == "command" }
    commands.each { |c| constraints += extractCmd(c, class_name) }
    return constraints
  end

  def extractCmd(c, class_name)
    constraints = []
    ident = c[0].source
    if BUILTIN_VALIDATOR.include? ident
      constraints += extractBultinValidator(c, class_name)
    end
    return constraints
  end

  def extractBultinValidator(ast, classname)
    # puts ast.source
    validate_type = ast.children[0].source
    case validate_type
    when "validates_presence_of"
      constraints = extractBuiltinPresence(ast, classname)
    when "validates_uniqueness_of"
      constraints = extractBuiltinUnique(ast, classname)
    when "validates_format_of"
      constraints = extractBuiltinFormat(ast, classname)
    when "validates_inclusion_of"
      constraints = extractBuiltinInclusion(ast, classname)
    when "validates_length_of"
      constraints = extractBuiltinLength(ast, classname)
    end
    return constraints
  end

  def extractBuiltinUnique(ast, classname)
    fields = []
    constraints = []
    scope = []
    content = ast[1].children
    cond = nil
    case_sensitive = nil
    content.each { |node|
      field = handle_symbol_literal_node(node)
      fields << field unless field.nil?
      node.children.each { |n|
        k, v = handle_assoc_node(n)
        if !k.nil? and k == "if"
          cond = v
        end
        if !k.nil? and k == "case_sensitive"
          case_sensitive = (v.source.downcase == "true")
        end
        if !k.nil? and k == "scope"
          v.children.each { |s|
            scope << handle_symbol_literal_node(s[0])
          }
        end
      }
    }
    fields.each { |field|
      c = UniqueConstraint.new(classname, field, cond, case_sensitive, scope)
      constraints << c
    }
    return constraints
  end

  def extractBuiltinPresence(ast, classname)
    fields = []
    constraints = []
    content = ast[1].children
    cond = nil
    content.each { |node|
      field = handle_symbol_literal_node(node)
      fields << field unless field.nil?
      k, v = handle_assoc_node(node[0])
      if !k.nil? and k == "if"
        cond = v
      end
    }
    fields.each { |field|
      c = PresenceConstraint.new
      c.cond = cond
      c.class_name = classname
      c.field_name = field
      constraints << c
    }
    return constraints
  end

  def extractBuiltinInclusion(ast, classname)
    []
  end

  def extractBuiltinFormat(ast, classname)
    constraints = []
    fields = []
    format = nil
    content = ast[1].children
    content.each { |node|
      field = handle_symbol_literal_node(node)
      fields << field unless field.nil?
      k, v = handle_assoc_node(node[0])
      if k == "with"
        format = v.source
      end
    }
    fields.each { |field|
      c = FormatConstraint.new
      c.format = format
      c.class_name = classname
      c.field_name = field
      constraints << c
    }
    return constraints
  end

  def extractBuiltinLength(ast, classname)
    constraints = []
    min = nil
    max = nil
    fields = []
    content = ast[1].children
    content.each { |node|
      field = handle_symbol_literal_node(node)
      fields << field unless field.nil?
      node.each { |n|
        k, v = handle_assoc_node(n)
        if !k.nil? && k == "maximum" && v.type.to_s == "int"
          max = v.source.to_i
        end
        if !k.nil? && k == "minimum" && v.type.to_s == "int"
          min = v.source.to_i
        end
      }
    }
    fields.each { |field|
      constraint = LengthConstraint.new
      constraint.class_name = classname
      constraint.field_name = field
      constraint.min = min
      constraint.max = max
      constraints << constraint
    }
    return constraints
  end

  def extractCustom(files)
  end

  def extractSingleFile(file)
  end

  def extractPolyMorphic(files)
  end

  def extractFieldDefinition(files)
  end

  def extractClassInheritance(files)
  end

  # input: list of files
  # output: list of constraints
end
