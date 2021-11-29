require_relative '../constraint'
require_relative '../engine'
require_relative '../traversor'
require_relative '../db_extractor'

class TestPrint
  def visit(node, _params)
    puts "#{node.name} => #{node.constraints}, table #{node.table}"
  end
end

def test_redmine
  engine = Engine.new('test/data/redmine_models')
  root = engine.run
  t = Traversor.new(DBExtractor.new('test/data/redmine_db/schema.rb'))
  t.traverse(root)
  t = Traversor.new(TestPrint.new)
  t.traverse(root)
end

test_redmine
