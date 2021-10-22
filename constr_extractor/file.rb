require "yard"
require "pathname"

class ConstraintClass
  attr_accessor :name, :constants, :parent

  def initialize(ast, file)
    @name = ast[0].source
    @file = file
    parent_node = ast[1]
    @parent = nil
    if not parent_node.nil?
      @parent = ast[1].source
    end

    # constants = Hash.new
    # ast.children.each { |c|
    #   if c.type.to_s == "list"
    #     c.children.each { |a|
    #       if a.type.to_s == "assign"
    #         puts a.type
    #         puts a.source
    #         # ignore assignment with lh = self.variable
    #         if a.source.include? "self"
    #           next
    #         end
    #         eval(a.source)
    #       end
    #     }
    #   end
    #   puts "#{c.type}"
    # }
    # puts "#{ast[0].source}, #{ast[1].source}"
    # puts ast[1]
  end
end

# more about yard ast
# 1. parse_model_constraint.rb
class ConstraintFile
  attr_accessor :ast, :name, :classes

  def initialize(filename)
    file = File.open(filename)
    contents = file.read
    file.close
    # doc:
    @ast = YARD::Parser::Ruby::RubyParser.parse(contents).root
    @name = filename
    @classes = []
    @ast.children.each { |class_ast|
      if class_ast.type.to_s == "class"
        class_obj = ConstraintClass.new(class_ast, filename)
        @classes << class_obj
      end
    }
    # puts "==========#{@classes.length}"
  end
end

class FileReader
  def self.readDir(dir)
    root = Pathname(dir)
    files = []
    dirs = []
    Pathname(root).find do |path|
      unless path == root
        dirs << path if path.directory?
        files << path if path.file?
      end
    end
    constraint_files = []
    # first pass on files to get inheritance relation
    files.each { |file| constraint_files << self.readFile(file) }

    # topological sort to get scan order
    order = toposort(constraint_files)
    # second pass on classes to get all constants
    # TODO: fix this
    constraint_files_with_constants = self.setConstants(order, constraint_files)
    # constraint_files_with_constants = constraint_files
    return constraint_files_with_constants
  end

  def self.readFile(filename)
    begin
      file = ConstraintFile.new(filename)
      return file
    rescue StandardError => e
      puts "Fail to parse file #{file} #{e}"
    end
  end

  def self.toposortHelper(c, visited, order, g)
    if (visited.include? c) and visited[c]
      return visited, order
    end
    visited[c] = true
    if not g[c].nil?
      visited, p_order = self.toposortHelper(g[c], visited, order, g)
    end
    order << c
    return visited, order
  end

  def self.toposort(constraint_files)
    g = Hash.new
    constraint_files.each { |f|
      f.classes.each { |c| g[c.name] = c.parent }
    }
    visited = Hash.new
    order = []
    g.each { |c, parent| visited, order = toposortHelper(c, visited, order, g) }
    return order
  end

  # {"ActiveRecord::Base"=>[{"Principal"=>[{"Group"=>[{"GroupBuiltin"=>["GroupNonMember", "GroupAnonymous"]}]}, {"User"=>["AnonymousUser"]}]}]}
  def self.getInheritanceDic(order, constraint_files)
    h = Hash.new
    class_file_map = Hash.new
    constraint_files.each { |f| f.classes.each { |class_obj| class_file_map[class_obj.name] = f } }
    order = order.reverse()
    order.each { |c|
      tmp = c
      if c == "ActiveRecord::Base"
        return h
      end

      if h.include? c
        tmp = { c => h[c] }
        h = h.reject! { |k| k == c }
      end

      # if the class does not have a corresponding file, it must come from lib, ignore it
      if not class_file_map.include? c
        next
      end
      clas = class_file_map[c].classes.select { |class_obj| class_obj.name == c }
      raise "[Error] multiple classes have name #{clas.name}" unless (clas.length == 1)
      clas = clas[0]
      if not h.include? clas.parent
        h[clas.parent] = []
      end
      h[clas.parent] << tmp
    }
    return h
  end

  def self.setConstantsLineage(lineage, constraint_files)
  end

  def self.setConstants(order, constraint_files)
    inheritance_info = self.getInheritanceDic(order, constraint_files)
    # only consider classes inherit from active record
    raise "ActiveRecord::Base not in the inheritance" unless inheritance_info.include? "ActiveRecord::Base"
    inheritance_info = inheritance_info["ActiveRecord::Base"]
    inheritance_info.each { |lineage|
      setConstantsLineage(lineage, constraint_files)
    }
    return constraint_files
  end
end
