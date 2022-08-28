require 'yard'
require_relative '../builtin_extractor'
require_relative '../class_node'

def test_naive
  puts '==============Test Naive=============='
  class_def = <<-FOO
    class InventoryUnit < Spree::Base
      with_options inverse_of: :inventory_units do
        belongs_to :variant, -> { with_deleted }, class_name: 'Spree::Variant'
        belongs_to :order, class_name: 'Spree::Order'
        belongs_to :shipment, class_name: 'Spree::Shipment', touch: true, optional: true
        has_many :return_items, class_name: 'Spree::ReturnItem', inverse_of: :inventory_unit
        has_many :return_authorizations, class_name: 'Spree::ReturnAuthorization', through: :return_items
        belongs_to :line_item, class_name: 'Spree::LineItem'
      end
    end
  FOO
  node = ClassNode.new('Test')
  node.ast = YARD::Parser::Ruby::RubyParser.parse(class_def).root[0]
  builtin_extractor = BuiltinExtractor.new
  builtin_extractor.visit(node, {})
  puts "# of extracted constraints: #{node.constraints.length}"
end

def test_presence_inwith
  puts '==============Test Presence in With Option=============='
  class_def = <<-FOO
    class Address < Spree::Base
      with_options presence: true do
        validates :firstname, :lastname, :address1, :city, :country
        validates :zipcode, if: :require_zipcode?
        validates :phone, if: :require_phone?
      end
    end
  FOO
  node = ClassNode.new('Test')
  node.ast = YARD::Parser::Ruby::RubyParser.parse(class_def).root[0]
  builtin_extractor = BuiltinExtractor.new
  builtin_extractor.visit(node, {})
  puts "# of extracted constraints: #{node.constraints.length}"
  # node.constraints.each{|c| puts c}
end

test_naive
test_presence_inwith