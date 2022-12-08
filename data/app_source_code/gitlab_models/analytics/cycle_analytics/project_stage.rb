# frozen_string_literal: true

module Analytics
  module CycleAnalytics
    class ProjectStage < ApplicationRecord
      include Analytics::CycleAnalytics::Stage

      validates :project, presence: true
      belongs_to :project
      belongs_to :value_stream, class_name: 'Analytics::CycleAnalytics::ProjectValueStream', foreign_key: :project_value_stream_id

      alias_attribute :parent, :project
      alias_attribute :parent_id, :project_id

      alias_attribute :value_stream_id, :project_value_stream_id

      delegate :group, to: :project

      validate :validate_project_group_for_label_events, if: -> { start_event_label_based? || end_event_label_based? }

      def self.relative_positioning_query_base(stage)
        where(project_id: stage.project_id)
      end

      def self.relative_positioning_parent_column
        :project_id
      end

      def self.distinct_stages_within_hierarchy(group)
        with_preloaded_labels
          .where(project_id: group.all_projects.select(:id))
          .select("DISTINCT ON(stage_event_hash_id) #{quoted_table_name}.*")
      end

      private

      # Project should belong to a group when the stage has Label based events since only GroupLabels are allowed.
      def validate_project_group_for_label_events
        errors.add(:project, s_('CycleAnalyticsStage|should be under a group')) unless project.group
      end
    end
  end
end
