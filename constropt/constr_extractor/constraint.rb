# validate.rb in the old repo (formatchecker)
# how to write validate function: https://guides.rubyonrails.org/active_record_validations.html#validates-each
require 'json'
require 'active_support/inflector'

class Constraint
  attr_accessor :class_name, :field_name, :db

  def initialize(field, db)
    @field_name = field
    @db = db
  end

  def eql?(other)
    return false if other.class != self.class
    self.field_name  == other.field_name &&
    self.db == other.db
  end
end

class InclusionConstraint < Constraint
  attr_accessor :values, :type

  def initialize(field, values, type, db)
    super(field, db)
    @values = values
    @type = type
  end

  def eql?(other)
    return false if other.class != self.class
    self.field_name  == other.field_name &&
    self.db == other.db &&
    self.values == other.values &&
    self.type == other.type 
  end

  def hash
    return (self.field_name + self.db.to_s + self.values.to_s + self.type).hash
  end
end

class UniqueConstraint < Constraint
  attr_accessor :cond, :case_sensitive, :type

  def initialize(field, cond, case_sensitive, type, db)
    super(field, db)
    raise "[Error] Unique Constraint case sensitive cannot be None" if case_sensitive.nil?
    raise "[Error] Unique Constraint type cannot be None" if type.nil?
    @cond = cond
    @case_sensitive = case_sensitive
    @type = type
  end

  def eql?(other)
    return false if other.class != self.class
    self.field_name  == other.field_name &&
    self.db == other.db &&
    self.cond == other.cond &&
    self.case_sensitive == other.case_sensitive &&
    self.type == other.type 
  end

  def hash
    return (self.field_name.to_s + self.db.to_s \
      + self.cond.to_s + self.type + self.case_sensitive.to_s).hash
  end
end

class PresenceConstraint < Constraint
  attr_accessor :cond

  def initialize(field, cond, db)
    super(field, db)
    @cond = cond
  end

  def eql?(other)
    return false if other.class != self.class
    self.field_name  == other.field_name &&
    self.db == other.db &&
    self.cond == other.cond
  end

  def hash
    return (self.field_name + self.db.to_s + self.cond.to_s).hash
  end
end

class LengthConstraint < Constraint
  attr_accessor :min, :max

  def initialize(field, min, max, db)
    super(field, db)
    @min = min
    @max = max
  end

  def eql?(other)
    return false if other.class != self.class
    self.field_name  == other.field_name &&
    self.db == other.db &&
    self.min == other.min && 
    self.max == other.max
  end

  def hash
    return (self.field_name + self.db.to_s + self.min.to_s + self.max.to_s).hash
  end
end

class FormatConstraint < Constraint
  attr_accessor :format

  def initialize(field, format_regex, db)
    super(field, db)
    @format = format_regex
  end

  def eql?(other)
    return false if other.class != self.class
    self.field_name  == other.field_name &&
    self.db == other.db &&
    self.format == other.format
  end

  def hash
    return (self.field_name + self.db.to_s + self.format.to_s).hash
  end
end

class NumericalConstraint < Constraint
  attr_accessor :min, :max

  def initialize(field, min, max, db)
    super(field, db)
    @min = min
    @max = max
  end

  def eql?(other)
    return false if other.class != self.class
    self.field_name  == other.field_name &&
    self.db == other.db &&
    self.min == other.min && 
    self.max == other.max
  end

  def hash
    return (self.field_name + self.db.to_s + self.min.to_s + self.max.to_s).hash
  end
end


class HasManyConstraint < Constraint
  attr_accessor :class_name, :foreign_key, :callable, :dependent, :inverse_of, :through, :as, :extend

  def initialize(field, class_name, foreign_key, callable, dependent, inverse_of, through, as, extend, db = false)
    super(field, db)
    @class_name = class_name
    @foreign_key = foreign_key
    @callable = callable
    @dependent = dependent
    @inverse_of = inverse_of
    @through = through
    @as = as
    @extend = extend # what is this???
  end

  def eql?(other)
    raise "Not Implement == for HasManyConstraint"
  end
end

class ForeignKeyConstraint < Constraint
  attr_accessor :class_name, :fk_column_name, :polymorphic

  def initialize(field, class_name, fk_column_name, polymorphic, db)
    super(field, db)
    @field_name = field
    @class_name = class_name
    @fk_column_name = fk_column_name
    @polymorphic = polymorphic
  end

  def eql?(other)
    return false if other.class != self.class
    self.field_name  == other.field_name &&
    self.db == other.db &&
    self.class_name == other.class_name && 
    self.fk_column_name == other.fk_column_name &&
    self.polymorphic == other.polymorphic
  end

  def hash
    return (self.field_name + self.db.to_s + self.class_name.to_s \
      + self.fk_column_name.to_s + self.polymorphic.to_s).hash
  end
end

class HasOneManyConstraint < Constraint
  attr_accessor :class_name, :foreign_key, :as_field, :type

  def initialize(field, class_name, foreign_key, as_field, type, through, db)
    @field_name = field
    @class_name = class_name
    @foreign_key = foreign_key
    @as_field = as_field
    @db = db
    @type = type
  end

  def eql?(other)
    return false if other.class != self.class
    self.field_name  == other.field_name &&
    self.db == other.db &&
    self.class_name == other.class_name &&
    self.foreign_key == other.foreign_key && 
    self.as_field == other.as_field &&
    self.type == other.type
  end

  def hash
    return (self.field_name + self.db.to_s + self.class_name.to_s \
      + self.foreign_key.to_s + self.as_field + self.type).hash
  end
end
