require_dependency 'spree/shipping_calculator'

module Spree
  module Calculator::Shipping
    class FlatRate < ShippingCalculator
      preference :amount, :decimal, default: 0
      preference :currency, :string, default: -> { Spree::Store.default.default_currency }

      def self.description
        Spree.t(:shipping_flat_rate_per_order)
      end

      def compute_package(_package)
        preferred_amount
      end
    end
  end
end
