require 'yard'
require 'pathname'

require_relative 'class_node'

class Engine
  def initialize(dir)
    @appdir = dir
  end

  def run
    files = read_dir(@appdir)
    build(files)
  end

  def build(asts)
    class_nodes = {}
    roots = []
    # create nodes
    asts.each do |ast|
      classname_parents = get_classname_and_parents(ast)
      classname_parents.each do |class_name, parent|
        class_node = ClassNode.new(class_name)
        class_node.parent = parent
        class_nodes[class_name] = class_node
      end
    end

    # connect
    # class might inherit from the library
    # we don't analyze the source code of the library
    # we just create a dummy node for the library file
    full_class_nodes = {}
    class_nodes.each do |name, node|
      if !node.parent.nil? && (!class_nodes.include? node.parent)
        parent_node = ClassNode.new(node.parent)
        full_class_nodes[node.parent] = parent_node
      end
      full_class_nodes[name] = node
    end
    full_class_nodes.each do |_name, node|
      if node.parent.nil?
        roots.append(node)
      else
        full_class_nodes[node.parent].children.append(node)
      end
    end

    # set table name
    dfs = lambda { |root, tablename|
      root.table = tablename
      root.children.each { |child| dfs.call(child, tablename) }
    }
    roots.each do |root|
      dfs.call(root, root.name)
    end

    roots
  end

  def get_classname_and_parents(ast)
    classname_parents = {}
    ast.children.each do |class_ast|
      next unless class_ast.type.to_s == 'class'

      class_name = class_ast[0].source
      parent_name = class_ast[1]
      parent_name = class_ast[1].source unless parent_name.nil?
      classname_parents[class_name] = parent_name
    end
    classname_parents
  end

  def read_file(filename)
    file = File.open(filename)
    contents = file.read
    file.close
    YARD::Parser::Ruby::RubyParser.parse(contents).root
  rescue StandardError => e
    puts "Fail to parse file #{file} #{e}"
  end

  def read_dir(dir)
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
    files.each { |file| constraint_files << read_file(file) }
    constraint_files
  end
end
