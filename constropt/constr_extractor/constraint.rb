# validate.rb in the old repo (formatchecker)
# how to write validate function: https://guides.rubyonrails.org/active_record_validations.html#validates-each
require 'json'
require 'active_support/inflector'

class Constraint
  attr_accessor :class_name, :field_name
end

class InclusionConstraint < Constraint
  attr_accessor :values, :type

  def initialize(field, values, type)
    @field_name = field
    @values = values
    @type = type
  end

  def to_s
    {
      constraint_type: 'inclusion',
      field_name: @field_name,
      values: @values,
      type: type
    }
  end
end

class UniqueConstraint < Constraint
  attr_accessor :cond, :case_sensitive, :scope

  def initialize(field, cond, case_sensitive, scope)
    @field_name = field
    @cond = cond
    @case_sensitive = case_sensitive
    @scope = scope
  end

  def to_s
    {
      constraint_type: 'unique',
      field_name: @field_name,
      cond: @cond,
      case_sensitive: @case_sensitive,
      scope: @scope
    }
  end
end

class PresenceConstraint < Constraint
  attr_accessor :cond

  def initialize(field_name, cond)
    @field_name = field_name
    @cond = cond
  end

  def to_s
    {
      constraint_type: 'presence',
      field_name: @field_name
    }
  end
end

class LengthConstraint < Constraint
  attr_accessor :min, :max

  def initialize(field_name, min, max)
    @field_name = field_name
    @min = min
    @max = max
  end

  def to_s
    {
      constraint_type: 'length',
      field_name: @field_name,
      min: @min,
      max: @max
    }
  end
end

class FormatConstraint < Constraint
  attr_accessor :format

  def initialize(field_name, format_regex)
    @field_name = field_name
    @format = format_regex
  end

  def to_s
    {
      constraint_type: 'format',
      field_name: @field_name,
      format: @format
    }
  end
end
