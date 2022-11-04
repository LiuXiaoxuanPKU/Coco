module Spree
  class RefundReason < Spree::Base
    include Spree::NamedType

    RETURN_PROCESSING_REASON = 'Return processing'

    has_many :refunds, dependent: :restrict_with_error

    def self.return_processing_reason
      find_by(name: RETURN_PROCESSING_REASON, mutable: false)
    end
  end
end
