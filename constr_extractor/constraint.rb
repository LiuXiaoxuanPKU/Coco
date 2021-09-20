# validate.rb in the old repo (formatchecker)
# how to write validate function: https://guides.rubyonrails.org/active_record_validations.html#validates-each

class Constraint
  attr_accessor :class_name, :field_name
end

class InclusionConstraint < Constraint
  attr_accessor :values, :type

  def to_string
  end
end

class UniqueConstraint < Constraint
  attr_accessor :cond

  def to_string
  end
end

class PresenceConstraint < Constraint
  attr_accessor :cond

  def to_string
  end
end

class LengthConstraint < Constraint
  attr_accessor :min, :max

  def to_string
  end
end
