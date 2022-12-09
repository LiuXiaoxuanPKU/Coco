require_relative 'base_extractor'
require_relative 'constraint'

class IdExtractor < Extractor
  def visit(node, _params)
    # UniqueConstraint(field, cond, case_sensitive, scope)
    node.constraints.append(UniqueConstraint.new(['id'], nil, false, "pk", ConstrainType::PK))
    node.constraints.append(PresenceConstraint.new('id', nil, ConstrainType::PK))
  end
end
