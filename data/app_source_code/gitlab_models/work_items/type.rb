# frozen_string_literal: true

# Note: initial thinking behind `icon_name` is for it to do triple duty:
# 1. one of our svg icon names, such as `external-link` or a new one `bug`
# 2. if it's an absolute url, then url to a user uploaded icon/image
# 3. an emoji, with the format of `:smile:`
module WorkItems
  class Type < ApplicationRecord
    self.table_name = 'work_item_types'

    include CacheMarkdownField

    # type name is used in restrictions DB seeder to assure restrictions for
    # default types are pre-filled
    TYPE_NAMES = {
      issue: 'Issue',
      incident: 'Incident',
      test_case: 'Test Case',
      requirement: 'Requirement',
      task: 'Task',
      objective: 'Objective',
      key_result: 'Key Result'
    }.freeze

    # Base types need to exist on the DB on app startup
    # This constant is used by the DB seeder
    # TODO - where to add new icon names created?
    BASE_TYPES = {
      issue: { name: TYPE_NAMES[:issue], icon_name: 'issue-type-issue', enum_value: 0 },
      incident: { name: TYPE_NAMES[:incident], icon_name: 'issue-type-incident', enum_value: 1 },
      test_case: { name: TYPE_NAMES[:test_case], icon_name: 'issue-type-test-case', enum_value: 2 }, ## EE-only
      requirement: { name: TYPE_NAMES[:requirement], icon_name: 'issue-type-requirements', enum_value: 3 }, ## EE-only
      task: { name: TYPE_NAMES[:task], icon_name: 'issue-type-task', enum_value: 4 },
      objective: { name: TYPE_NAMES[:objective], icon_name: 'issue-type-objective', enum_value: 5 }, ## EE-only
      key_result: { name: TYPE_NAMES[:key_result], icon_name: 'issue-type-keyresult', enum_value: 6 } ## EE-only
    }.freeze

    WIDGETS_FOR_TYPE = {
      issue: [
        Widgets::Assignees,
        Widgets::Labels,
        Widgets::Description,
        Widgets::Hierarchy,
        Widgets::StartAndDueDate,
        Widgets::Milestone,
        Widgets::Notes
      ],
      incident: [
        Widgets::Description,
        Widgets::Hierarchy,
        Widgets::Notes
      ],
      test_case: [
        Widgets::Description,
        Widgets::Notes
      ],
      requirement: [
        Widgets::Description,
        Widgets::Notes
      ],
      task: [
        Widgets::Assignees,
        Widgets::Labels,
        Widgets::Description,
        Widgets::Hierarchy,
        Widgets::StartAndDueDate,
        Widgets::Milestone,
        Widgets::Notes
      ],
      objective: [
        Widgets::Assignees,
        Widgets::Labels,
        Widgets::Description,
        Widgets::Hierarchy,
        Widgets::Milestone,
        Widgets::Notes
      ],
      key_result: [
        Widgets::Assignees,
        Widgets::Labels,
        Widgets::Description,
        Widgets::Hierarchy,
        Widgets::StartAndDueDate,
        Widgets::Notes
      ]
    }.freeze

    WI_TYPES_WITH_CREATED_HEADER = %w[issue incident].freeze

    cache_markdown_field :description, pipeline: :single_line

    enum base_type: BASE_TYPES.transform_values { |value| value[:enum_value] }

    belongs_to :namespace, optional: true
    has_many :work_items, class_name: 'Issue', foreign_key: :work_item_type_id, inverse_of: :work_item_type

    before_validation :strip_whitespace

    # TODO: review validation rules
    # https://gitlab.com/gitlab-org/gitlab/-/issues/336919
    validates :name, presence: true
    validates :name, uniqueness: { case_sensitive: false, scope: [:namespace_id] }
    validates :name, length: { maximum: 255 }
    validates :icon_name, length: { maximum: 255 }

    scope :default, -> { where(namespace: nil) }
    scope :order_by_name_asc, -> { order(arel_table[:name].lower.asc) }
    scope :by_type, ->(base_type) { where(base_type: base_type) }

    def self.available_widgets
      WIDGETS_FOR_TYPE.values.flatten.uniq
    end

    def self.default_by_type(type)
      found_type = find_by(namespace_id: nil, base_type: type)
      return found_type if found_type

      Gitlab::DatabaseImporters::WorkItems::BaseTypeImporter.upsert_types
      Gitlab::DatabaseImporters::WorkItems::HierarchyRestrictionsImporter.upsert_restrictions
      find_by(namespace_id: nil, base_type: type)
    end

    def self.default_issue_type
      default_by_type(:issue)
    end

    def self.allowed_types_for_issues
      base_types.keys.excluding('task', 'objective', 'key_result')
    end

    def default?
      namespace.blank?
    end

    def widgets
      WIDGETS_FOR_TYPE[base_type.to_sym]
    end

    private

    def strip_whitespace
      name&.strip!
    end
  end
end

WorkItems::Type.prepend_mod
