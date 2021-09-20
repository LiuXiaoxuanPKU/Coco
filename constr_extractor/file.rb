require "yard"

# more about yard ast
# 1. parse_model_constraint.rb
# 2.
class ConstraintFile
  attr_accessor :ast

  def initialize(filename)
    file = File.open(filename)
    contents = file.read
    file.close
    # doc:
    @ast = YARD::Parser::Ruby::RubyParser.parse(contents).root
    @name = filename
    @class = getClass
    # puts @ast.type
    # puts @ast.length
    # puts @ast.children[0].source
    # puts @ast.children[2].source
    # puts @ast.children[0].source
    # puts @ast.children[2].source
  end

  def getClass
  end
end

class FileReader
  def self.readDir(dir)
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
