# frozen_string_literal: true

module Integrations
  module EnableSslVerification
    extend ActiveSupport::Concern

    prepended do
      boolean_accessor :enable_ssl_verification
    end

    def initialize_properties
      super

      self.enable_ssl_verification = true if new_record? && enable_ssl_verification.nil?
    end

    def fields
      super.tap do |fields|
        url_index = fields.index { |field| field[:name].ends_with?('_url') }
        insert_index = url_index ? url_index + 1 : -1

        fields.insert(insert_index, {
          type: 'checkbox',
          name: 'enable_ssl_verification',
          title: s_('Integrations|SSL verification'),
          checkbox_label: s_('Integrations|Enable SSL verification'),
          help: s_('Integrations|Clear if using a self-signed certificate.')
        })
      end
    end
  end
end
