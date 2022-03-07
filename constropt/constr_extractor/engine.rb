require 'yard'
require 'pathname'

require_relative 'class_node'
require_relative 'traversor'
require_relative 'populate_tablename'
require_relative 'serializer'

class Engine
  def initialize(dir)
    @appdir = dir
  end

  def run
    files = read_dir(@appdir)
    files = files.reject(&:nil?)
    root = build(files)
    # populate table name
    populate_tablename_traversor = Traversor.new(PopulateTableName.new)
    populate_tablename_traversor.traverse(root)
    root
  end

  def get_constraints(root)
    visitor = TreeVisitor.new
    t = Traversor.new(visitor)
    t.traverse(root)
    visitor.constraints
  end

  ############################## Helper Functions #########################
  def build(asts)
    class_nodes = {}
    roots = []
    # create nodes
    asts.each do |ast|
      classname_parents = get_classname_and_parents(ast)
      classname_parents.each do |class_name, parent_and_classast|
        class_node = ClassNode.new(class_name)
        class_node.parent = parent_and_classast[0]
        class_node.ast = parent_and_classast[1]
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
    active_record_node = nil
    roots.each do |root|
      # up to rails 4.2, use activatereocrd::base
      active_record_node = root if root.name == 'ActiveRecord::Base'
      # if ApplicationRecord < ActiveRecord::Base, use ApplicationRecord, requires rails > 4.2
      application_record_node = root.children.select { |c| c.name == 'ApplicationRecord' }
      active_record_node = application_record_node if application_record_node.nil?
    end
    active_record_node
  end

  def get_classname_and_parents(ast)
    classname_parents = {}
    ast.children.each do |class_ast|
      next unless class_ast.type.to_s == 'class'

      class_name = class_ast[0].source
      parent_name = class_ast[1]
      parent_name = class_ast[1].source unless parent_name.nil?
      classname_parents[class_name] = [parent_name, class_ast]
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
