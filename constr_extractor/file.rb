require "yard"
require "pathname"

class ConstraintClass
  attr_accessor :name, :constrants, :parents

  def initialize(ast)
    puts ast[0]
    puts ast[1]
  end
end

# more about yard ast
# 1. parse_model_constraint.rb
class ConstraintFile
  attr_accessor :ast

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
        class_obj = ConstraintClass.new(class_ast)
        @classes << class_obj
      end
    }
    puts "==========#{@classes.length}"
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
    files.each { |file| constraint_files << self.readFile(file) }
    return files
  end

  def self.readFile(filename)
    begin
      file = ConstraintFile.new(filename)
      return file
    rescue StandardError => e
      puts "Fail to parse file #{file} #{e}"
    end
  end
end
