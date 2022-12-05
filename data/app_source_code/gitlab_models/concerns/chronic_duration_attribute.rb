# frozen_string_literal: true

module ChronicDurationAttribute
  extend ActiveSupport::Concern

  class_methods do
    def chronic_duration_attr_reader(virtual_attribute, source_attribute)
      define_method(virtual_attribute) do
        chronic_duration_attributes[virtual_attribute] || output_chronic_duration_attribute(source_attribute)
      end
    end

    def chronic_duration_attr_writer(virtual_attribute, source_attribute, parameters = {})
      chronic_duration_attr_reader(virtual_attribute, source_attribute)

      define_method("#{virtual_attribute}=") do |value|
        chronic_duration_attributes[virtual_attribute] = value.presence || parameters[:default].presence.to_s

        begin
          new_value = value.present? ? ChronicDuration.parse(value).to_i : parameters[:default].presence
          assign_attributes(source_attribute => new_value)
        rescue ChronicDuration::DurationParseError
          # ignore error as it will be caught by validation
        end
      end

      validates virtual_attribute, allow_nil: true, duration: { message: parameters[:error_message] }
    end

    alias_method :chronic_duration_attr, :chronic_duration_attr_writer
  end

  def chronic_duration_attributes
    @chronic_duration_attributes ||= {}
  end

  def output_chronic_duration_attribute(source_attribute)
    value = attributes[source_attribute.to_s]
    ChronicDuration.output(value, format: :short) if value
  end
end
