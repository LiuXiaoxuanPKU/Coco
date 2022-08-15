module Spree
  module UserMethods
    extend ActiveSupport::Concern

    include Spree::UserPaymentSource
    include Spree::UserReporting
    include Spree::UserRoles
    include Spree::RansackableAttributes

    included do
      # we need to have this callback before any dependent: :destroy associations
      # https://github.com/rails/rails/issues/3458
      before_validation :clone_billing_address, if: :use_billing?
      before_destroy :check_completed_orders
      after_destroy :nullify_approver_id_in_approved_orders

      attr_accessor :use_billing

      has_many :promotion_rule_users, class_name: 'Spree::PromotionRuleUser', foreign_key: :user_id, dependent: :destroy
      has_many :promotion_rules, through: :promotion_rule_users, class_name: 'Spree::PromotionRule'

      has_many :orders, foreign_key: :user_id, class_name: 'Spree::Order'
      has_many :store_credits, foreign_key: :user_id, class_name: 'Spree::StoreCredit'

      belongs_to :ship_address, class_name: 'Spree::Address', optional: true
      belongs_to :bill_address, class_name: 'Spree::Address', optional: true

      has_many :wishlists, class_name: 'Spree::Wishlist', foreign_key: :user_id

      self.whitelisted_ransackable_associations = %w[bill_address ship_address addresses]
      self.whitelisted_ransackable_attributes = %w[id email]

      def self.with_email(query)
        where("#{table_name}.email LIKE ?", "%#{query}%")
      end

      def self.with_address(query, address = :ship_address)
        left_outer_joins(address).
          where("#{Spree::Address.table_name}.firstname like ?", "%#{query}%").
          or(left_outer_joins(address).where("#{Spree::Address.table_name}.lastname like ?", "%#{query}%"))
      end

      def self.with_email_or_address(email, address)
        left_outer_joins(:addresses).
          where("#{Spree::Address.table_name}.firstname LIKE ? or #{Spree::Address.table_name}.lastname LIKE ? or #{table_name}.email LIKE ?",
                "%#{address}%", "%#{address}%", "%#{email}%")
      end
    end

    def last_incomplete_spree_order(store, options = {})
      orders.where(store: store).incomplete.
        includes(options[:includes]).
        order('created_at DESC').
        first
    end

    def total_available_store_credit(currency = nil, store = nil)
      store ||= Store.default
      currency ||= store.default_currency
      store_credits.for_store(store).where(currency: currency).reload.to_a.sum(&:amount_remaining)
    end

    def available_store_credits(store)
      store ||= Store.default

      store_credits.for_store(store).pluck(:currency).uniq.each_with_object([]) do |currency, arr|
        arr << Spree::Money.new(total_available_store_credit(currency, store), currency: currency)
      end
    end

    def default_wishlist_for_store(current_store)
      wishlists.find_or_create_by(is_default: true, store_id: current_store.id) do |wishlist|
        wishlist.name = Spree.t(:default_wishlist_name)
        wishlist.save
      end
    end

    private

    def check_completed_orders
      raise Spree::Core::DestroyWithOrdersError if orders.complete.present?
    end

    def nullify_approver_id_in_approved_orders
      Spree::Order.where(approver_id: id).update_all(approver_id: nil)
    end

    def clone_billing_address
      if bill_address && ship_address.nil?
        self.ship_address = bill_address.clone
      else
        ship_address.attributes = bill_address.attributes.except('id', 'updated_at', 'created_at')
      end
      true
    end

    def use_billing?
      use_billing.in?([true, 'true', '1'])
    end
  end
end
