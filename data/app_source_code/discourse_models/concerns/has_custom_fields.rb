# frozen_string_literal: true

module HasCustomFields
  extend ActiveSupport::Concern

  module Helpers

    def self.append_field(target, key, value, types)
      if target.has_key?(key)
        target[key] = [target[key]] if !target[key].is_a? Array
        target[key] << cast_custom_field(key, value, types, _return_array = false)
      else
        target[key] = cast_custom_field(key, value, types)
      end
    end

    CUSTOM_FIELD_TRUE ||= ['1', 't', 'true', 'T', 'True', 'TRUE'].freeze

    def self.get_custom_field_type(types, key)
      return unless types

      sorted_types = types.keys.select { |k| k.end_with?("*") }
        .sort_by(&:length)
        .reverse

      sorted_types.each do |t|
        return types[t] if key =~ /^#{t}/i
      end

      types[key]
    end

    def self.cast_custom_field(key, value, types, return_array = true)
      return value unless type = get_custom_field_type(types, key)

      array = nil

      if Array === type
        type = type[0]
        array = true if return_array
      end

      result =
        case type
        when :boolean then !!CUSTOM_FIELD_TRUE.include?(value)
        when :integer then value.to_i
        when :json    then parse_json_value(value, key)
        else
          value
        end

      array ? [result] : result
    end

    def self.parse_json_value(value, key)
      ::JSON.parse(value)
    rescue JSON::ParserError
      Rails.logger.warn("Value '#{value}' for custom field '#{key}' is not json, it is being ignored.")
      {}
    end
  end

  included do
    has_many :_custom_fields, dependent: :destroy, class_name: "#{name}CustomField"
    after_save :save_custom_fields

    attr_accessor :preloaded_custom_fields

    def custom_fields_fk
      @custom_fields_fk ||= "#{_custom_fields.reflect_on_all_associations(:belongs_to)[0].name}_id"
    end

    # To avoid n+1 queries, use this function to retrieve lots of custom fields in one go
    # and create a "sideloaded" version for easy querying by id.
    def self.custom_fields_for_ids(ids, allowed_fields)
      klass = "#{name}CustomField".constantize
      foreign_key = "#{name.underscore}_id".to_sym

      result = {}

      return result if allowed_fields.blank?

      klass.where(foreign_key => ids, :name => allowed_fields)
        .pluck(foreign_key, :name, :value).each do |cf|
        result[cf[0]] ||= {}
        append_custom_field(result[cf[0]], cf[1], cf[2])
      end

      result
    end

    def self.append_custom_field(target, key, value)
      HasCustomFields::Helpers.append_field(target, key, value, @custom_field_types)
    end

    def self.register_custom_field_type(name, type)
      @custom_field_types ||= {}
      @custom_field_types[name] = type
    end

    def self.get_custom_field_type(name)
      @custom_field_types ||= {}
      @custom_field_types[name]
    end

    def self.preload_custom_fields(objects, fields)
      if objects.present?
        map = {}

        empty = {}
        fields.each do |field|
          empty[field] = nil
        end

        objects.each do |obj|
          map[obj.id] = obj
          obj.preloaded_custom_fields = empty.dup
        end

        fk = (name.underscore << "_id")

        "#{name}CustomField".constantize
          .where("#{fk} in (?)", map.keys)
          .where("name in (?)", fields)
          .pluck(fk, :name, :value).each do |id, name, value|

          preloaded = map[id].preloaded_custom_fields

            if preloaded[name].nil?
              preloaded.delete(name)
            end

            HasCustomFields::Helpers.append_field(preloaded, name, value, @custom_field_types)
        end

      end
    end
  end

  def reload(options = nil)
    clear_custom_fields
    super
  end

  def on_custom_fields_change
    # Callback when custom fields have changed
    # Override in model
  end

  def custom_fields_preloaded?
    !!@preloaded_custom_fields
  end

  def custom_field_preloaded?(name)
    @preloaded_custom_fields && @preloaded_custom_fields.key?(name)
  end

  def clear_custom_fields
    @custom_fields = nil
    @custom_fields_orig = nil
  end

  class PreloadedProxy
    def initialize(preloaded)
      @preloaded = preloaded
    end

    def [](key)
      if @preloaded.key?(key)
        @preloaded[key]
      else
        # for now you can not mix preload an non preload, it better just to fail
        raise StandardError, "Attempted to access the non preloaded custom field '#{key}'. This is disallowed to prevent N+1 queries."
      end
    end
  end

  def custom_fields
    if @preloaded_custom_fields
      return @preloaded_proxy ||= PreloadedProxy.new(@preloaded_custom_fields)
    end

    @custom_fields ||= refresh_custom_fields_from_db.dup
  end

  def custom_fields=(data)
    custom_fields.replace(data)
  end

  def custom_fields_clean?
    # Check whether the cached version has been changed on this model
    !@custom_fields || @custom_fields_orig == @custom_fields
  end

  # `upsert_custom_fields` will only insert/update existing fields, and will not
  # delete anything. It is safer under concurrency and is recommended when
  # you just want to attach fields to things without maintaining a specific
  # set of fields.
  def upsert_custom_fields(fields)
    fields.each do |k, v|
      row_count = _custom_fields.where(name: k).update_all(value: v)
      if row_count == 0
        _custom_fields.create!(name: k, value: v)
      end

      custom_fields[k.to_s] = v # We normalize custom_fields as strings
    end

    on_custom_fields_change
  end

  def save_custom_fields(force = false)
    if force || !custom_fields_clean?
      dup = @custom_fields.dup.with_indifferent_access
      array_fields = {}

      ActiveRecord::Base.transaction do
        _custom_fields.reload.each do |f|
          if dup[f.name].is_a?(Array)
            # we need to collect Arrays fully before we can compare them
            if !array_fields.has_key?(f.name)
              array_fields[f.name] = [f]
            else
              array_fields[f.name] << f
            end
          elsif dup[f.name].is_a?(Hash)
            if dup[f.name].to_json != f.value
              f.destroy!
            else
              dup.delete(f.name)
            end
          else
            t = {}
            self.class.append_custom_field(t, f.name, f.value)

            if dup.has_key?(f.name) && dup[f.name] == t[f.name]
              dup.delete(f.name)
            else
              f.destroy!
            end
          end
        end

        # let's iterate through our arrays and compare them
        array_fields.each do |field_name, fields|
          if fields.length == dup[field_name].length && fields.map(&:value) == dup[field_name]
            dup.delete(field_name)
          else
            fields.each(&:destroy!)
          end
        end

        dup.each do |k, v|
          field_type = self.class.get_custom_field_type(k)

          if v.is_a?(Array) && field_type != :json
            v.each { |subv| _custom_fields.create!(name: k, value: subv) }
          else
            create_singular(k, v, field_type)
          end
        end
      end

      on_custom_fields_change
      refresh_custom_fields_from_db
    end
  end

  # We support unique indexes on certain fields. In the event two concurrent processes attempt to
  # update the same custom field we should catch the error and perform an update instead.
  def create_singular(name, value, field_type = nil)
    write_value = value.is_a?(Hash) || field_type == :json ? value.to_json : value
    write_value = 't' if write_value.is_a?(TrueClass)
    write_value = 'f' if write_value.is_a?(FalseClass)
    row_count = DB.exec(<<~SQL, name: name, value: write_value, id: id, now: Time.zone.now)
      INSERT INTO #{_custom_fields.table_name} (#{custom_fields_fk}, name, value, created_at, updated_at)
      VALUES (:id, :name, :value, :now, :now)
      ON CONFLICT DO NOTHING
    SQL
    _custom_fields.where(name: name).update_all(value: write_value) if row_count == 0
  end

protected

  def refresh_custom_fields_from_db
    target = HashWithIndifferentAccess.new
    _custom_fields.order('id asc').pluck(:name, :value).each do |key, value|
      self.class.append_custom_field(target, key, value)
    end
    @custom_fields_orig = target
    @custom_fields = @custom_fields_orig.dup
  end

end
