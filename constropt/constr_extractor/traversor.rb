class Traversor
  def initialize(visitor)
    @visitor = visitor
  end

  def dfs(node)
    @visitor.visit(node)
    node.children.each do |child|
      dfs(child)
    end
  end

  def traverse(roots)
    roots.each do |root|
      dfs(root)
    end
  end
end
