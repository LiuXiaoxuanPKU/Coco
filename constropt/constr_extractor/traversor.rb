class Traversor
  def initialize(visitor)
    @visitor = visitor
  end

  def dfs(node, params)
    @visitor.visit(node, params)
    node.children.each do |child|
      cur_params = params.clone
      dfs(child, cur_params)
    end
  end

  def traverse(root)
    params = {}
    dfs(root, params)
  end
end
