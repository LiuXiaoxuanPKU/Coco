class Tag < ApplicationRecord
  has_many :taggings
  has_many :taggable, :through => :taggings

  belongs_to :user

  DELIMITER = ",".freeze # Controls how to split and join tagnames from strings. You may need to change the <tt>validates_format_of parameters</tt> if you change this.
  JOIN_DELIMITER = ", ".freeze

  # If database speed becomes an issue, you could remove these validations and
  # rescue the ActiveRecord database constraint errors instead.
  validates :name, presence: true, uniqueness: { :scope => "user_id", :case_sensitive => false }

  before_create :before_create

  # Callback to strip extra spaces from the tagname before saving it. If you
  # allow tags to be renamed later, you might want to use the
  # <tt>before_save</tt> callback instead.
  def before_create
    self.name = name.downcase.strip.squeeze(' '.freeze)
  end

  def label
    @label ||= name.tr(' '.freeze, '-'.freeze)
  end

  def to_s
    name
  end
end
