# validate.rb in the old repo (formatchecker)
# how to write validate function: https://guides.rubyonrails.org/active_record_validations.html#validates-each
require 'json'
require 'active_support/inflector'

class Constraint
  attr_accessor :class_name, :field_name, :db, :allow_nil
end

class InclusionConstraint < Constraint
  attr_accessor :values, :type

  def initialize(field, values, type, db: false, allow_nil: false)
    @field_name = field
    @values = values
    @type = type
    @db = db
    @allow_nil = allow_nil
  end
end

class UniqueConstraint < Constraint
  attr_accessor :cond, :case_sensitive, :scope

  def initialize(field, cond, case_sensitive, scope, db: false, allow_nil: false)
    @field_name = field
    @cond = cond
    @case_sensitive = case_sensitive
    @scope = scope
    @db = db
    @allow_nil = allow_nil
  end
end

class PresenceConstraint < Constraint
  attr_accessor :cond

  def initialize(field_name, cond, db: false, allow_nil: false)
    @field_name = field_name
    @cond = cond
    @db = db
    @allow_nil = allow_nil
  end
end

class LengthConstraint < Constraint
  attr_accessor :min, :max

  def initialize(field_name, min, max, db: false, allow_nil: false)
    @field_name = field_name
    @min = min
    @max = max
    @db = db
    @allow_nil = allow_nil
  end
end

class FormatConstraint < Constraint
  attr_accessor :format

  def initialize(field_name, format_regex, db: false, allow_nil: false)
    @field_name = field_name
    @format = format_regex
    @db = db
    @allow_nil = allow_nil
  end
end

class NumericalConstraint < Constraint
  attr_accessor :min, :max, :allow_nil

  def initialize(field, min, max, db: false, allow_nil: false)
    @field_name = field
    @min = min
    @max = max
    @db = db
    @allow_nil = allow_nil
  end
end

class HasOneConstraint < Constraint
  attr_accessor :class_name, :foreign_key, :callable, :dependent

  def initialize(field, class_name, foreign_key, callable, dependent, db: false)
    @field_name = field
    @class_name = class_name
    @foreign_key = foreign_key
    @callable = callable
    @dependent = dependent
    @db = db
  end
end

class HasManyConstraint < Constraint
  attr_accessor :class_name, :foreign_key, :callable, :dependent, :inverse_of, :through, :as, :extend

  def initialize(field, class_name, foreign_key, callable, dependent, inverse_of, through, as, extend, db: false)
    @field_name = field
    @class_name = class_name
    @foreign_key = foreign_key
    @callable = callable
    @dependent = dependent
    @inverse_of = inverse_of
    @through = through
    @as = as
    @extend = extend
    @db = db
  end
end

class BelongsToConstraint < Constraint
  attr_accessor :class_name, :polymorphic, :counter_cache

  def initialize(field, class_name, polymorphic, counter_cache, db: false)
    @field_name = field
    @class_name = class_name
    @polymorphic = polymorphic
    @counter_cache = counter_cache
    @db = db
  end
end

class ForeignKeyConstraint < Constraint
  attr_accessor :class_name, :fk_column_name

  def initialize(field, class_name, fk_column_name, db=false)
    @field_name = field
    @class_name = class_name
    @fk_column_name = fk_column_name
    @db = db
  end
end
