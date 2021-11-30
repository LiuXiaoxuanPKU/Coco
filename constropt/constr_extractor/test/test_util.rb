require_relative '../traversor'

class Reset
  def initialize(fields)
    @fields = fields
  end

  def visit(node, _params)
    @fields.each do |field|
      if node.instance_variable_get(field).is_a?(Array)
        node.instance_variable_set(field, [])
      else
        node.instance_variable_set(field, nil)
      end
    end
  end
end

class TestUtil
  def self.reset(node, fields)
    t = Traversor.new(Reset.new(fields))
    t.traverse(node)
    node
  end

  def self.check_equal(t1, t2)
    # :name, :parent, :constants, :ast, :table, :children, :constraints
    raise "name: #{t1.name} != #{t2.name}" unless t1.name == t2.name

    if t1.parent.nil?
      raise "parent: #{t1.parent} != #{t2.parent}" unless t2.parent.nil?
    else
      raise "parent: #{t1.parent} != #{t2.parent}" unless t1.parent.name == t2.parent.name
    end
    raise "ast: #{t1.ast} != #{t2.ast}" unless t1.ast == t2.ast
    raise "table: #{t1.table} != #{t2.table}" unless t1.table == t2.table
    # TODO: define equal for constraint
    unless t1.constraints.length == t2.constraints.length
      raise "constraints length: #{t1.constraints.length} != #{t1.constraints.length}"
    end
    unless t1.constants.length == t2.constants.length
      raise "constants length: #{t1.constants.length} != #{t1.constants.length}"
    end
    unless t1.children.length == t2.children.length
      raise "children length: #{t1.children.length} != #{t1.children.length}"
    end

    t1.children.each do |child|
      # I know you want to build a hash map, but I dont care
      t2_child = t2.children.select { |c| c.name == child.name }
      raise "different children have the same name #{c.name}" unless t2_child.length == 1

      t2_child = t2_child[0]
      check_equal(child, t2_child)
    end
  end
end
