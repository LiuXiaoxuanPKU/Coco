module Spree
  class OptionValue < Spree::Base
    include Metadata

    belongs_to :option_type, class_name: 'Spree::OptionType', touch: true, inverse_of: :option_values
    acts_as_list scope: :option_type

    has_many :option_value_variants, class_name: 'Spree::OptionValueVariant'
    has_many :variants, through: :option_value_variants, class_name: 'Spree::Variant'

    with_options presence: true do
      validates :name, uniqueness: { scope: :option_type_id, case_sensitive: false }
      validates :presentation
    end

    scope :filterable, lambda {
      joins(:option_type).
        where(OptionType.table_name => { filterable: true }).
        distinct
    }

    scope :for_products, lambda { |products|
      joins(:variants).
        where(Variant.table_name => { product_id: products.map(&:id) })
    }

    after_touch :touch_all_variants

    delegate :name, :presentation, to: :option_type, prefix: true, allow_nil: true

    self.whitelisted_ransackable_attributes = ['presentation']

    private

    def touch_all_variants
      variants.update_all(updated_at: Time.current)
    end
  end
end
