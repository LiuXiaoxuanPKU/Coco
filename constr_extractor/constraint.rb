# validate.rb in the old repo (formatchecker)
# how to write validate function: https://guides.rubyonrails.org/active_record_validations.html#validates-each
require "json"

class Constraint
  attr_accessor :class_name, :field_name
end

class InclusionConstraint < Constraint
  attr_accessor :values, :type

  def to_string
  end
end

class UniqueConstraint < Constraint
  attr_accessor :cond, :case_sensitive, :scope

  def initialize(classname, field, cond, case_sensitive, scope)
    @class_name = classname
    @field_name = field
    @cond = cond
    @case_sensitive = case_sensitive
    @scope = scope
  end

  def to_string
    {
      :constraint_type => "unique",
      :class_name => @class_name,
      :field_name => @field_name,
      :cond => @cond,
      :case_sensitive => @case_sensitive,
      :scope => @scope,
    }.to_json
  end
end

class PresenceConstraint < Constraint
  attr_accessor :cond

  def initialize(class_name, field_name, cond)
    @class_name = class_name
    @field_name = field_name
    @cond = cond
  end

  def to_string
    {
      :constraint_type => "presence",
      :class_name => @class_name,
      :field_name => @field_name,
    }.to_json
  end
end

class LengthConstraint < Constraint
  attr_accessor :min, :max

  def initialize(class_name, field_name, min, max)
    @class_name = class_name
    @field_name = field_name
    @min = min
    @max = max
  end

  def to_string
    {
      :constraint_type => "length",
      :class_name => @class_name,
      :field_name => @field_name,
      :min => @min,
      :max => @max,
    }.to_json
  end
end

class FormatConstraint < Constraint
  attr_accessor :format

  def initialize(class_name, field_name, format_regex)
    @class_name = class_name
    @field_name = field_name
    @format = format_regex
  end

  def to_string
    {
      :constraint_type => "format",
      :class_name => @class_name,
      :field_name => @field_name,
      :format => @format,
    }.to_json
  end
end
