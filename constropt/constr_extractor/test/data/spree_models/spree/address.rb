module Spree
  class Address < Spree::Base
    require 'validates_zipcode'

    include Metadata

    if Rails::VERSION::STRING >= '6.1'
      serialize :preferences, Hash, default: {}
    end

    NO_ZIPCODE_ISO_CODES ||= [
      'AO', 'AG', 'AW', 'BS', 'BZ', 'BJ', 'BM', 'BO', 'BW', 'BF', 'BI', 'CM', 'CF', 'KM', 'CG',
      'CD', 'CK', 'CUW', 'CI', 'DJ', 'DM', 'GQ', 'ER', 'FJ', 'TF', 'GAB', 'GM', 'GH', 'GD', 'GN',
      'GY', 'HK', 'IE', 'KI', 'KP', 'LY', 'MO', 'MW', 'ML', 'MR', 'NR', 'AN', 'NU', 'KP', 'PA',
      'QA', 'RW', 'KN', 'LC', 'ST', 'SC', 'SL', 'SB', 'SO', 'SR', 'SY', 'TZ', 'TL', 'TK', 'TG',
      'TO', 'TV', 'UG', 'AE', 'VU', 'YE', 'ZW'
    ].freeze

    # The required states listed below match those used by PayPal and Shopify.
    STATES_REQUIRED = [
      'AU', 'AE', 'BR', 'CA', 'CN', 'ES', 'HK', 'IE', 'IN',
      'IT', 'MY', 'MX', 'NZ', 'PT', 'RO', 'TH', 'US', 'ZA'
    ].freeze

    # we're not freezing this on purpose so developers can extend and manage
    # those attributes depending of the logic of their applications
    ADDRESS_FIELDS = %w(firstname lastname company address1 address2 city state zipcode country phone)
    EXCLUDED_KEYS_FOR_COMPARISON = %w(id updated_at created_at deleted_at label user_id)

    scope :not_deleted, -> { where(deleted_at: nil) }

    belongs_to :country, class_name: 'Spree::Country'
    belongs_to :state, class_name: 'Spree::State', optional: true
    belongs_to :user, class_name: Spree.user_class.name, optional: true

    has_many :shipments, inverse_of: :address

    before_validation :clear_invalid_state_entities, if: -> { country.present? }, on: :update

    with_options presence: true do
      validates :firstname, :lastname, :address1, :city, :country
      validates :zipcode, if: :require_zipcode?
      validates :phone, if: :require_phone?
    end

    validate :state_validate, :postal_code_validate

    validates :label, uniqueness: { conditions: -> { where(deleted_at: nil) },
                                    scope: :user_id,
                                    case_sensitive: false,
                                    allow_blank: true,
                                    allow_nil: true }

    delegate :name, :iso3, :iso, :iso_name, to: :country, prefix: true
    delegate :abbr, to: :state, prefix: true, allow_nil: true

    alias_attribute :first_name, :firstname
    alias_attribute :last_name, :lastname

    self.whitelisted_ransackable_attributes = ADDRESS_FIELDS
    self.whitelisted_ransackable_associations = %w[country state user]

    def self.build_default
      ActiveSupport::Deprecation.warn(<<-DEPRECATION, caller)
        `Address#build_default` is deprecated and will be removed in Spree 5.0.
        Please use standard rails `Address.new(country: current_store.default_country)`
      DEPRECATION
      new(country: Spree::Country.default)
    end

    def self.default(user = nil, kind = 'bill')
      ActiveSupport::Deprecation.warn(<<-DEPRECATION, caller)
        `Address#default` is deprecated and will be removed in Spree 5.0.
      DEPRECATION
      if user && user_address = user.public_send(:"#{kind}_address")
        user_address.clone
      else
        build_default
      end
    end

    def self.required_fields
      Spree::Address.validators.map do |v|
        v.is_a?(ActiveModel::Validations::PresenceValidator) ? v.attributes : []
      end.flatten
    end

    def full_name
      "#{firstname} #{lastname}".strip
    end

    def state_text
      state.try(:abbr) || state.try(:name) || state_name
    end

    def state_name_text
      state_name.present? ? state_name : state&.name
    end

    def to_s
      [
        full_name,
        company,
        address1,
        address2,
        "#{city}, #{state_text} #{zipcode}",
        country.to_s
      ].reject(&:blank?).map { |attribute| ERB::Util.html_escape(attribute) }.join('<br/>')
    end

    def clone
      self.class.new(value_attributes)
    end

    def ==(other)
      return false unless other&.respond_to?(:value_attributes)

      value_attributes == other.value_attributes
    end

    def value_attributes
      attributes.except(*EXCLUDED_KEYS_FOR_COMPARISON)
    end

    def empty?
      attributes.except('id', 'created_at', 'updated_at', 'country_id').all? { |_, v| v.nil? }
    end

    # Generates an ActiveMerchant compatible address hash
    def active_merchant_hash
      {
        name: full_name,
        address1: address1,
        address2: address2,
        city: city,
        state: state_text,
        zip: zipcode,
        country: country.try(:iso),
        phone: phone
      }
    end

    def require_phone?
      Spree::Config[:address_requires_phone]
    end

    def require_zipcode?
      country ? country.zipcode_required? : true
    end

    def editable?
      new_record? || (shipments.empty? && !Order.complete.where('bill_address_id = ? OR ship_address_id = ?', id, id).exists?)
    end

    def can_be_deleted?
      shipments.empty? && !Order.where('bill_address_id = ? OR ship_address_id = ?', id, id).exists?
    end

    def check
      attrs = attributes.except('id', 'updated_at', 'created_at')
      the_same_address = user&.addresses&.find_by(attrs)
      the_same_address || self
    end

    def destroy
      if can_be_deleted?
        super
      else
        update_column :deleted_at, Time.current
        assign_new_default_address_to_user
      end
    end

    private

    def clear_state
      self.state = nil
    end

    def clear_state_name
      self.state_name = nil
    end

    def clear_invalid_state_entities
      if state.present? && (state.country != country)
        clear_state
      elsif state_name.present? && !country.states_required? && country.states.empty?
        clear_state_name
      end
    end

    def state_validate
      # Skip state validation without country (also required)
      # or when disabled by preference
      return if country.blank? || !Spree::Config[:address_requires_state]
      return unless country.states_required

      # ensure associated state belongs to country
      if state.present?
        if state.country == country
          clear_state_name # not required as we have a valid state and country combo
        elsif state_name.present?
          clear_state
        else
          errors.add(:state, :invalid)
        end
      end

      # ensure state_name belongs to country without states, or that it matches a predefined state name/abbr
      if state_name.present?
        if country.states.present?
          states = country.states.find_all_by_name_or_abbr(state_name)

          if states.size == 1
            self.state = states.first
            clear_state_name
          else
            errors.add(:state, :invalid)
          end
        end
      end

      # ensure at least one state field is populated
      errors.add :state, :blank if state.blank? && state_name.blank?
    end

    def postal_code_validate
      return if country.blank? || country_iso.blank? || !require_zipcode? || zipcode.blank?
      return unless ::ValidatesZipcode::CldrRegexpCollection::ZIPCODES_REGEX.keys.include?(country_iso.upcase.to_sym)

      formatted_zip = ::ValidatesZipcode::Formatter.new(
        zipcode: zipcode.to_s.strip,
        country_alpha2: country_iso.upcase
      ).format

      errors.add(:zipcode, :invalid) unless ::ValidatesZipcode.valid?(formatted_zip, country_iso.upcase)
    end

    def assign_new_default_address_to_user
      return unless user

      user.bill_address = user.addresses.last if user.bill_address == self
      user.ship_address = user.addresses.last if user.ship_address == self
      user.save!
    end
  end
end
