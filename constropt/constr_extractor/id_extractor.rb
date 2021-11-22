require_relative 'base_extractor'
require_relative 'constraint'

class IdExtractor < Extractor
  def visit(node, _params)
    # UniqueConstraint(classname, field, cond, case_sensitive, scope)
    node.constraints.append(UniqueConstraint.new(node.table, 'id', nil, false, []))
  end
end
