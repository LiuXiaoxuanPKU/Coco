# frozen_string_literal: true

class WorkItem < Issue
  include Gitlab::Utils::StrongMemoize

  self.table_name = 'issues'
  self.inheritance_column = :_type_disabled

  belongs_to :namespace, inverse_of: :work_items
  has_one :parent_link, class_name: '::WorkItems::ParentLink', foreign_key: :work_item_id
  has_one :work_item_parent, through: :parent_link, class_name: 'WorkItem'

  has_many :child_links, class_name: '::WorkItems::ParentLink', foreign_key: :work_item_parent_id
  has_many :work_item_children, through: :child_links, class_name: 'WorkItem',
                                foreign_key: :work_item_id, source: :work_item

  scope :inc_relations_for_permission_check, -> { includes(:author, project: :project_feature) }

  class << self
    def assignee_association_name
      'issue'
    end

    def test_reports_join_column
      'issues.id'
    end
  end

  def noteable_target_type_name
    'issue'
  end

  def widgets
    strong_memoize(:widgets) do
      work_item_type.widgets.map do |widget_class|
        widget_class.new(self)
      end
    end
  end

  private

  override :parent_link_confidentiality
  def parent_link_confidentiality
    if confidential? && work_item_children.public_only.exists?
      errors.add(:base, _('A confidential work item cannot have a parent that already has non-confidential children.'))
    end

    if !confidential? && work_item_parent&.confidential?
      errors.add(:base, _('A non-confidential work item cannot have a confidential parent.'))
    end
  end

  def record_create_action
    super

    Gitlab::UsageDataCounters::WorkItemActivityUniqueCounter.track_work_item_created_action(author: author)
  end
end

WorkItem.prepend_mod
