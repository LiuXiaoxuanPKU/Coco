#!/usr/bin/env ruby

require_relative '../engine'
require_relative '../traversor'
require_relative '../builtin_extractor'
require_relative '../id_extractor'
require_relative '../constraint'

class TestPrint
  def visit(node, _params)
    puts "==================#{node.name} => #{node.parent}"
    puts "constraints #{node.constraints.length}"
    inclusion_constraints = node.constraints.select { |c| c.is_a? InclusionConstraint }
    unique_constraints = node.constraints.select { |c| c.is_a? UniqueConstraint }
    (inclusion_constraints + unique_constraints).each do |c|
      puts c.to_s
    end
  end
end

def test_naive
  t = Traversor.new(TestPrint.new)
  engine = Engine.new('spec/test_data/redmine_models')
  roots = engine.run
  t.traverse(roots)

  t = Traversor.new(IdExtractor.new)
  t.traverse(root)

  t = Traversor.new(TestPrint.new)
  t.traverse(root)
end

def test_app_builtin(appdir)
  t = Traversor.new(BuiltinExtractor.new)
  engine = Engine.new(appdir)
  root = engine.run
  t.traverse(root)
  constraints_cnt = engine.get_constraints_cnt(root)
  puts "#{appdir}"
  puts "extract #{constraints_cnt} builtin constraints"
end


# test_naive
test_app_builtin("test/data/redmine_models")
test_app_builtin("test/data/openproject_models")
test_app_builtin("test/data/forem_models")
