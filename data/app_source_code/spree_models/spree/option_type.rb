module Spree
  class OptionType < Spree::Base
    include UniqueName
    include Metadata

    acts_as_list

    with_options dependent: :destroy, inverse_of: :option_type do
      has_many :option_values, -> { order(:position) }
      has_many :product_option_types
    end

    has_many :products, through: :product_option_types

    has_many :option_type_prototypes, class_name: 'Spree::OptionTypePrototype'
    has_many :prototypes, through: :option_type_prototypes, class_name: 'Spree::Prototype'

    validates :presentation, presence: true

    default_scope { order(:position) }

    scope :filterable, -> { where(filterable: true) }

    accepts_nested_attributes_for :option_values, reject_if: ->(ov) { ov[:name].blank? || ov[:presentation].blank? }, allow_destroy: true

    after_touch :touch_all_products

    def filter_param
      name.parameterize
    end

    def self.color
      find_by(name: 'color')
    end

    private

    def touch_all_products
      products.update_all(updated_at: Time.current)
    end
  end
end
