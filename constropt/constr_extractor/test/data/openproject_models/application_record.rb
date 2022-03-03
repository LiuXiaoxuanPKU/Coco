class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  ##
  # Determine whether this resource was just created ?
  def just_created?
    saved_change_to_attribute?(:id)
  end

  ##
  # Returns whether the given attribute is free of errors
  def valid_attribute?(attribute)
    valid? # Ensure validations have run

    errors[attribute].empty?
  end

  ##
  # Get the newest recently changed resource for the given record classes
  #
  # e.g., +most_recently_changed(WorkPackage, Type, Status)+
  #
  # Returns the timestamp of the most recently updated value
  def self.most_recently_changed(*record_classes)
    queries = record_classes.map do |clz|
      column_name = clz.send(:timestamp_attributes_for_update_in_model)&.first || 'updated_at'
      "(SELECT MAX(#{column_name}) AS max_updated_at FROM #{clz.table_name})"
    end
      .join(" UNION ")

    union_query = <<~SQL
      SELECT MAX(union_query.max_updated_at)
      FROM (#{queries})
      AS union_query
    SQL

    ActiveRecord::Base
      .connection
      .select_all(union_query)
      .rows
      &.first # first result row
      &.first # max column
  end
end
