#copy over the relationship data in the initialization function
#within intialization pair all relationship data
#then traverse all nodes and create relationship constraints

require_relative 'ast_handler'
require_relative 'base_extractor'
require_relative 'constraint'

def trim_string(s)
  s.delete_prefix("'").delete_suffix("'").delete_prefix('"').delete_suffix('"').downcase
end

class RelationshipExtractor < Extractor

  def initialize
    @relationships = []
  end

  def visit(node, _params)
    #if it's the root node, must initialize relationships
    if node.parent.nil?
      has_ones = node.misc["has_ones"]
      has_manys = node.misc["has_manys"]
      belongs_tos = node.misc["belongs_tos"]
      has_ones.each do |x|
        belongs_tos.each do |y|
          if x["class_name"] == y["from_class"] and y["class_name"] == x["from_class"]
            if y["polymorphic"]

            end
            r = {"parent" => x["class_name"], "type" => "one-to-one", "child" => y["class_name"], "foreign_key" => y["foreign_key"]}
            @relationships += [r]

            next
          end
        end
      end

      has_manys.each do |x|
        belongs_tos.each do |y|
          if x["class_name"] == y["from_class"] and y["class_name"] == x["from_class"]
            if y["polymorphic"] == true

            end
            r = {"parent" => x["class_name"], "type" => "one-to-many", "child" => y["class_name"], "foreign_key" => y["foreign_key"]}
            @relationships += [r]
            next
          end
        end
      end
    end

    return if node.ast.nil?


    #create constraint if class name matches
    ast = node.ast
    constraints = []
    class_name = trim_string(ast[0].source.to_s)

    @relationships.each do |r|
      if trim_string(class_name) == r["parent"]
        c = ForeignKeyConstraint.new(r["parent"], r["type"], r["child"], r["foreign_key"])
        constraints += [c]
      end
    end

    node.constraints += constraints
  end




end
