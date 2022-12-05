# frozen_string_literal: true

# Note: initial thinking behind `icon_name` is for it to do triple duty:
# 1. one of our svg icon names, such as `external-link` or a new one `bug`
# 2. if it's an absolute url, then url to a user uploaded icon/image
# 3. an emoji, with the format of `:smile:`
class WorkItem::Type < ApplicationRecord
  self.table_name = 'work_item_types'

  include CacheMarkdownField

  cache_markdown_field :description, pipeline: :single_line

  enum base_type: Issue.issue_types

  belongs_to :group, foreign_key: :namespace_id, optional: true
  has_many :work_items, class_name: 'Issue', foreign_key: :work_item_type_id, inverse_of: :work_item_type

  before_validation :strip_whitespace

  # TODO: review validation rules
  # https://gitlab.com/gitlab-org/gitlab/-/issues/336919
  validates :name, presence: true
  validates :name, uniqueness: { case_sensitive: false, scope: [:namespace_id] }
  validates :name, length: { maximum: 255 }
  validates :icon_name, length: { maximum: 255 }

  private

  def strip_whitespace
    name&.strip!
  end
end
