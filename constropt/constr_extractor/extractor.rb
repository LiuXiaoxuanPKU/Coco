require "active_support/all"
require_relative "./ast_handler"
require_relative "./constraint"

class Extractor
  BUILTIN_VALIDATOR = ["validates_presence_of", "validates_uniqueness_of", "validates_format_of",
                       "validates_length_of", "validates_inclusion_of"]
  RULE_MAP = { :builtin => "extractBuiltin",
               :inheritance => "extractClassInheritance" }

  def initialize(rules)
    @rules = rules
  end

  def setRule(rules)
    @rules = rules
  end

  # {:builtin => extractBuiltin}
  # files: a list of ConstraintFile objects
  def extractAll(files)
    constraints = []
    @rules.each { |rule|
      constraints += method(RULE_MAP[rule].to_sym).call(files)
    }
    return constraints
  end

  def extractBuiltin(files)
    constraints = []
    files.each { |f|
      file_constraints = extractBuiltinHelper(f.ast, files)
      # puts "Extract #{file_constraints.length} constraints from #{f.name}"
      constraints += file_constraints
    }
    return constraints
  end

  def extractBuiltinHelper(ast, files)
    constraints = []
    if ast.type.to_s == "list"
      ast.children.each { |c| constraints += extractBuiltinHelper(c, files) }
    end
    if ast.type.to_s == "class"
      constraints += extractClass(ast, files)
    end
    return constraints
  end

  def extractClass(ast, files)
    constraints = []
    class_name = ast[0].source
    parent_class_node = ast[1]
    if parent_class_node.nil? # does not inherit from any parent class
      return constraints
    end
    parent_class_name = ast[1].source
    commands = ast[2].children.select { |c| c.type.to_s == "command" }
    commands.each { |c| constraints += extractCmd(c, class_name, files) }
    return constraints
  end

  def extractCmd(c, class_name, files)
    constraints = []
    ident = c[0].source
    if BUILTIN_VALIDATOR.include? ident
      constraints += extractBultinValidator(c, class_name, files)
    end
    return constraints
  end

  def extractBultinValidator(ast, classname, files)
    # puts ast.source
    validate_type = ast.children[0].source
    case validate_type
    when "validates_presence_of"
      constraints = extractBuiltinPresence(ast, classname, files)
    when "validates_uniqueness_of"
      constraints = extractBuiltinUnique(ast, classname, files)
    when "validates_format_of"
      constraints = extractBuiltinFormat(ast, classname, files)
    when "validates_inclusion_of"
      constraints = extractBuiltinInclusion(ast, classname, files)
    when "validates_length_of"
      constraints = extractBuiltinLength(ast, classname, files)
    end
    return constraints
  end

  def extractBuiltinUnique(ast, classname, files)
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
            if s.type.to_s == "symbol"
              scope << s[0].source
            else
              scope << handle_symbol_literal_node(s[0])
            end
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

  def extractBuiltinPresence(ast, classname, files)
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
      c = PresenceConstraint.new(classname, field, cond)
      constraints << c
    }
    return constraints
  end

  def extractBuiltinInclusion(ast, classname, files)
    constraints = []
    fields = []
    content = ast[1].children
    values = []
    type = nil
    content.each { |node|
      field = handle_symbol_literal_node(node)
      fields << field unless field.nil?
      node.each { |n|
        k, v = handle_assoc_node(n)
        if !k.nil? && k == "in"
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

        #allow_blank means the empty string is allowed
        if !k.nil? && k == "allow_blank"
          values << ""
        end
      }
    }
    fields.each { |field|
      c = InclusionConstraint.new(classname, field, values, type)
      constraints << c
    }
    return constraints
  end

  def extractBuiltinFormat(ast, classname, files)
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
      c = FormatConstraint.new(classname, field, format)
      constraints << c
    }
    return constraints
  end

  def extractBuiltinLength(ast, classname, files)
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
      constraint = LengthConstraint.new(classname, field, min, max)
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

  def flattenLineage(lineage, class_name, values)
    if lineage.is_a? String
      values << lineage
      return values
    end
    lineage.each { |k, v|
      values << k
      v.each { |vv| values = flattenLineage(vv, class_name, values) }
    }
    return values
  end

  def extractClassInheritanceHelper(lineage)
    # the class inherits from activerecord and does not have any children
    # do not create any constraints
    if lineage.is_a? String
      return nil
    end

    raise "[Error] Lineage #{lineage} has more than one element" unless lineage.length == 1
    class_name = lineage.keys[0]
    field = "type" # default class inheritance column
    # { "Principal" => [{ "Group" => [{ "GroupBuiltin" => ["GroupNonMember", "GroupAnonymous"] }] }
    values = flattenLineage(lineage, class_name, [])
    constraint = InclusionConstraint.new(class_name, field, values, "class_inheritance")
    return constraint
  end

  def extractClassInheritance(files)
    inheritance_constraints = []
    order = FileReader.toposort(files)
    inheritance_info = FileReader.getInheritanceDic(order, files)
    # only consider active record
    inheritance_info = inheritance_info["ActiveRecord::Base"]
    inheritance_info.each { |lineage|
      c = extractClassInheritanceHelper(lineage)
      unless c.nil?
        inheritance_constraints << c
      end
    }
    return inheritance_constraints
  end

  # input: list of files
  # output: list of constraints
end
