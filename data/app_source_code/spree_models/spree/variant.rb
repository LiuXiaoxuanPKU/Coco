module Spree
  class Variant < Spree::Base
    acts_as_paranoid
    acts_as_list scope: :product

    include MemoizedData
    include Metadata

    MEMOIZED_METHODS = %w(purchasable in_stock backorderable tax_category options_text compare_at_price)

    belongs_to :product, -> { with_deleted }, touch: true, class_name: 'Spree::Product', inverse_of: :variants
    belongs_to :tax_category, class_name: 'Spree::TaxCategory', optional: true

    delegate :name, :name=, :description, :slug, :available_on, :shipping_category_id,
             :meta_description, :meta_keywords, :shipping_category, to: :product

    # we need to have this callback before any dependent: :destroy associations
    # https://github.com/rails/rails/issues/3458
    before_destroy :ensure_no_line_items

    # must include this after ensure_no_line_items to make sure price won't be deleted before validation
    include Spree::DefaultPrice

    with_options inverse_of: :variant do
      has_many :inventory_units
      has_many :line_items
      has_many :stock_items, dependent: :destroy
    end

    has_many :orders, through: :line_items
    with_options through: :stock_items do
      has_many :stock_locations
      has_many :stock_movements
    end

    has_many :option_value_variants, class_name: 'Spree::OptionValueVariant'
    has_many :option_values, through: :option_value_variants, dependent: :destroy, class_name: 'Spree::OptionValue'

    has_many :images, -> { order(:position) }, as: :viewable, dependent: :destroy, class_name: 'Spree::Image'

    has_many :prices,
             class_name: 'Spree::Price',
             dependent: :destroy,
             inverse_of: :variant

    has_many :wished_items, dependent: :destroy

    has_many :digitals

    before_validation :set_cost_currency

    validate :check_price

    validates :option_values, presence: true, unless: :is_master?

    with_options numericality: { greater_than_or_equal_to: 0, allow_nil: true } do
      validates :cost_price
      validates :price
    end
    validates :sku, uniqueness: { conditions: -> { where(deleted_at: nil) }, case_sensitive: false, scope: spree_base_uniqueness_scope },
                    allow_blank: true, unless: :disable_sku_validation?

    after_create :create_stock_items
    after_create :set_master_out_of_stock, unless: :is_master?

    after_touch :clear_in_stock_cache

    scope :in_stock, -> { joins(:stock_items).where("#{Spree::StockItem.table_name}.count_on_hand > ? OR #{Spree::Variant.table_name}.track_inventory = ?", 0, false) }
    scope :backorderable, -> { joins(:stock_items).where(spree_stock_items: { backorderable: true }) }
    scope :in_stock_or_backorderable, -> { in_stock.or(backorderable) }

    scope :eligible, -> {
      where(is_master: false).or(
        where(
          <<-SQL
            #{Variant.quoted_table_name}.id IN (
              SELECT MIN(#{Variant.quoted_table_name}.id) FROM #{Variant.quoted_table_name}
              GROUP BY #{Variant.quoted_table_name}.product_id
              HAVING COUNT(*) = 1
            )
          SQL
        )
      )
    }

    scope :not_discontinued, -> do
      where(
        arel_table[:discontinue_on].eq(nil).or(
          arel_table[:discontinue_on].gteq(Time.current)
        )
      )
    end

    scope :not_deleted, -> { where("#{Spree::Variant.quoted_table_name}.deleted_at IS NULL") }

    scope :for_currency_and_available_price_amount, ->(currency = nil) do
      currency ||= Spree::Store.default.default_currency
      joins(:prices).where('spree_prices.currency = ?', currency).where('spree_prices.amount IS NOT NULL').distinct
    end

    scope :active, ->(currency = nil) do
      not_discontinued.not_deleted.
        for_currency_and_available_price_amount(currency)
    end
    # FIXME: cost price should be represented with DisplayMoney class
    LOCALIZED_NUMBERS = %w(cost_price weight depth width height)

    LOCALIZED_NUMBERS.each do |m|
      define_method("#{m}=") do |argument|
        self[m] = Spree::LocalizedNumber.parse(argument) if argument.present?
      end
    end

    self.whitelisted_ransackable_associations = %w[option_values product tax_category prices default_price]
    self.whitelisted_ransackable_attributes = %w[weight depth width height sku discontinue_on is_master cost_price cost_currency track_inventory deleted_at]
    self.whitelisted_ransackable_scopes = %i(product_name_or_sku_cont search_by_product_name_or_sku)

    def self.product_name_or_sku_cont(query)
      joins(:product).where("LOWER(#{Product.table_name}.name) LIKE LOWER(:query) OR LOWER(sku) LIKE LOWER(:query)", query: "%#{query}%")
    end

    def self.search_by_product_name_or_sku(query)
      if defined?(SpreeGlobalize)
        joins(product: :translations).where("LOWER(#{Product::Translation.table_name}.name) LIKE LOWER(:query) OR LOWER(sku) LIKE LOWER(:query)",
                                            query: "%#{query}%")
      else
        product_name_or_sku_cont(query)
      end
    end

    def available?
      !discontinued? && product.available?
    end

    def in_stock_or_backorderable?
      self.class.in_stock_or_backorderable.exists?(id: id)
    end

    def tax_category
      @tax_category ||= if self[:tax_category_id].nil?
                          product.tax_category
                        else
                          Spree::TaxCategory.find(self[:tax_category_id])
                        end
    end

    def options_text
      @options_text ||= Spree::Variants::OptionsPresenter.new(self).to_sentence
    end

    # Default to master name
    def exchange_name
      is_master? ? name : options_text
    end

    def descriptive_name
      is_master? ? name + ' - Master' : name + ' - ' + options_text
    end

    # use deleted? rather than checking the attribute directly. this
    # allows extensions to override deleted? if they want to provide
    # their own definition.
    def deleted?
      !!deleted_at
    end

    def options=(options = {})
      options.each do |option|
        set_option_value(option[:name], option[:value])
      end
    end

    def set_option_value(opt_name, opt_value)
      # no option values on master
      return if is_master

      option_type = Spree::OptionType.where(name: opt_name).first_or_initialize do |o|
        o.presentation = opt_name
        o.save!
      end

      current_value = option_values.detect { |o| o.option_type.name == opt_name }

      if current_value.nil?
        # then we have to check to make sure that the product has the option type
        unless product.option_types.include? option_type
          product.option_types << option_type
        end
      else
        return if current_value.name == opt_value

        option_values.delete(current_value)
      end

      option_value = Spree::OptionValue.where(option_type_id: option_type.id, name: opt_value).first_or_initialize do |o|
        o.presentation = opt_value
        o.save!
      end

      option_values << option_value
      save
    end

    def option_value(opt_name)
      option_values.detect { |o| o.option_type.name == opt_name }.try(:presentation)
    end

    def price_in(currency)
      prices.detect { |price| price.currency == currency&.upcase } || prices.build(currency: currency&.upcase)
    end

    def amount_in(currency)
      price_in(currency).try(:amount)
    end

    def compare_at_amount_in(currency)
      price_in(currency).try(:compare_at_amount)
    end

    def price_modifier_amount_in(currency, options = {})
      return 0 unless options.present?

      options.keys.map do |key|
        m = "#{key}_price_modifier_amount_in".to_sym
        if respond_to? m
          send(m, currency, options[key])
        else
          0
        end
      end.sum
    end

    def price_modifier_amount(options = {})
      return 0 unless options.present?

      options.keys.map do |key|
        m = "#{key}_price_modifier_amount".to_sym
        if respond_to? m
          send(m, options[key])
        else
          0
        end
      end.sum
    end

    def compare_at_price
      @compare_at_price ||= price_in(cost_currency).try(:compare_at_amount)
    end

    def name_and_sku
      "#{name} - #{sku}"
    end

    def sku_and_options_text
      "#{sku} #{options_text}".strip
    end

    def in_stock?
      # Issue 10280
      # Check if model responds to cache version and fall back to updated_at for older rails versions
      # This makes sure a version is supplied when recyclable cache keys are disabled.
      version = respond_to?(:cache_version) ? cache_version : updated_at.to_i
      @in_stock ||= Rails.cache.fetch(in_stock_cache_key, version: version) do
        total_on_hand > 0
      end
    end

    def backorderable?
      @backorderable ||= Rails.cache.fetch(['variant-backorderable', cache_key_with_version]) do
        quantifier.backorderable?
      end
    end

    delegate :total_on_hand, :can_supply?, to: :quantifier

    alias is_backorderable? backorderable?

    def purchasable?
      @purchasable ||= in_stock? || backorderable?
    end

    # Shortcut method to determine if inventory tracking is enabled for this variant
    # This considers both variant tracking flag and site-wide inventory tracking settings
    def should_track_inventory?
      track_inventory? && Spree::Config.track_inventory_levels
    end

    def volume
      (width || 0) * (height || 0) * (depth || 0)
    end

    def dimension
      (width || 0) + (height || 0) + (depth || 0)
    end

    def discontinue!
      update_attribute(:discontinue_on, Time.current)
    end

    def discontinued?
      !!discontinue_on && discontinue_on <= Time.current
    end

    def backordered?
      @backordered ||= !in_stock? && stock_items.exists?(backorderable: true)
    end

    # Is this variant to be downloaded by the customer?
    def digital?
      digitals.present?
    end

    private

    def ensure_no_line_items
      if line_items.any?
        errors.add(:base, :cannot_destroy_if_attached_to_line_items)
        throw(:abort)
      end
    end

    def quantifier
      Spree::Stock::Quantifier.new(self)
    end

    def set_master_out_of_stock
      if product.master&.in_stock?
        product.master.stock_items.update_all(backorderable: false)
        product.master.stock_items.each(&:reduce_count_on_hand_to_zero)
      end
    end

    # Ensures a new variant takes the product master price when price is not supplied
    def check_price
      if price.nil? && Spree::Config[:require_master_price]
        return errors.add(:base, :no_master_variant_found_to_infer_price)  unless product&.master
        return errors.add(:base, :must_supply_price_for_variant_or_master) if self == product.master

        self.price = product.master.price
      end
      if price.present? && currency.nil?
        self.currency = Spree::Store.default.default_currency
      end
    end

    def set_cost_currency
      self.cost_currency = Spree::Store.default.default_currency if cost_currency.blank?
    end

    def create_stock_items
      StockLocation.where(propagate_all_variants: true).each do |stock_location|
        stock_location.propagate_variant(self)
      end
    end

    def in_stock_cache_key
      "variant-#{id}-in_stock"
    end

    def clear_in_stock_cache
      Rails.cache.delete(in_stock_cache_key)
    end

    def disable_sku_validation?
      Spree::Config[:disable_sku_validation]
    end
  end
end
