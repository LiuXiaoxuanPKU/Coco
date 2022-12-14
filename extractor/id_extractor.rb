require_relative 'base_extractor'
require_relative 'constraint'

class IdExtractor < Extractor
  def visit(node, _params)
    # UniqueConstraint(field, cond, case_sensitive, scope)
    unique_pk = UniqueConstraint.new(['id'], nil, false, "pk", ConstrainType::PK)
    presence_pk = PresenceConstraint.new('id', nil, ConstrainType::PK)
    node.constraints.append(unique_pk)
    node.constraints.append(presence_pk)
    # set_constraints(node, filter_validate_constraints(node, [unique_pk, presence_pk]))
  end
end
