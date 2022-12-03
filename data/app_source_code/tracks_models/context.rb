class Context < ApplicationRecord
  has_many :todos, -> { order(Arel.sql("todos.due IS NULL, todos.due ASC, todos.created_at ASC")).includes(:project) }, :dependent => :delete_all
  has_many :recurring_todos, :dependent => :delete_all
  belongs_to :user

  scope :active,    -> { where state: :active }
  scope :hidden,    -> { where state: :hidden }
  scope :closed,    -> { where state: :closed }
  scope :with_name, lambda { |name| where("name " + Common.like_operator + " ?", name) }

  acts_as_list :scope => :user, :top_of_list => 0

  # state machine
  include AASM

  aasm :column => :state do
    state :active, :initial => true
    state :closed
    state :hidden

    event :close do
      transitions :to => :closed, :from => [:active, :hidden], :guard => :no_active_todos?
    end

    event :hide do
      transitions :to => :hidden, :from => [:active, :closed]
    end

    event :activate do
      transitions :to => :active, :from => [:closed, :hidden]
    end
  end

  validates :name, presence: { message: "context must have a name" }, length: { maximum: 255, message: "context name must be less than 256 characters" }, uniqueness: { message: "already exists", scope: "user_id", case_sensitive: false }

  def self.null_object
    NullContext.new
  end

  def title
    name
  end

  def no_active_todos?
    return todos.active.count == 0
  end
end

class NullContext
  def nil?
    true
  end

  def id
    nil
  end

  def name
    ''
  end
end
