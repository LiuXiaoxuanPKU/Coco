# This extractor has two goals
# 1. extract unique constraints from has_one constraint, and put it to the correct node
# [TODO] 2. extract polymorphic definitions (inclusion constraints) from has_one/has_many + belong_to pairs

require_relative './base_extractor'
require_relative './constraint'

class HasoneBelongtoExtractor < Extractor
  def initialize
    @class_node_map = {}
    @class_constraint_map = {}
  end

  def visit(node, _params)
    @class_node_map[node.name] = node
    node.constraints.each do |constraint|
      next unless constraint.is_a? HasOneConstraint
      next unless constraint.as_field.nil? # if as field is nil, it's a polymorphic assoc, the unique constriant does not hold anymore
      @class_constraint_map[constraint.class_name.classify] = \
        UniqueConstraint.new(constraint.foreign_key, nil, true, nil, false, false)
    end
  end

  def post_visit(_root)
    @class_constraint_map.each do |class_name, constraint|
      if !@class_node_map.include? class_name
        class_name = class_name.split(":")[-1] # Users::Setting
        if !@class_node_map.include? class_name
          puts "[Error] HasoneBelongtoExtractor: Does not have class #{class_name}"
          next
        end
      end
      node = @class_node_map[class_name]
      node.constraints.append(constraint)
    end
  end
end
