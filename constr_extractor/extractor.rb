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
    validate_type = ast.children[0].source
    case validate_type
    when "validates_presence_of"
      constraints = [Constraint.new]
    when "validates_uniqueness_of"
      constraints = [Constraint.new]
    when "validates_format_of"
      constraints = [Constraint.new]
    when "validates_inclusion_of"
      constraints = [Constraint.new]
    when "validates_length_of"
      constraints = extractBuiltinLength(ast, classname)
    end
    return constraints
  end

  def extractBuiltinUnique()
  end

  def extractBuiltinPresence()
  end

  def extractBuiltinInclusion()
  end

  def extractBuiltinFormat()
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
      k, v = handle_assoc_node(node[0])
      if !k.nil? && k == "maximum"
        max = v.source
      end
      if !k.nil? && k == "minimum"
        min = v.source
      end
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
