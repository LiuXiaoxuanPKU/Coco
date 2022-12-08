# frozen_string_literal: true

module Ci
  class ResourceGroup < Ci::ApplicationRecord
    belongs_to :project, inverse_of: :resource_groups

    has_many :resources, class_name: 'Ci::Resource', inverse_of: :resource_group
    has_many :processables, class_name: 'Ci::Processable', inverse_of: :resource_group

    validates :key,
      length: { maximum: 255 },
      format: { with: Gitlab::Regex.environment_name_regex,
                message: Gitlab::Regex.environment_name_regex_message }

    before_create :ensure_resource

    enum process_mode: {
      unordered: 0,
      oldest_first: 1,
      newest_first: 2
    }

    ##
    # NOTE: This is concurrency-safe method that the subquery in the `UPDATE`
    # works as explicit locking.
    def assign_resource_to(processable)
      resources.free.limit(1).update_all(build_id: processable.id) > 0
    end

    def release_resource_from(processable)
      resources.retained_by(processable).update_all(build_id: nil) > 0
    end

    def upcoming_processables
      if unordered?
        processables.waiting_for_resource
      elsif oldest_first?
        processables.waiting_for_resource_or_upcoming
          .order(Arel.sql("commit_id ASC, #{sort_by_job_status}"))
      elsif newest_first?
        processables.waiting_for_resource_or_upcoming
          .order(Arel.sql("commit_id DESC, #{sort_by_job_status}"))
      else
        Ci::Processable.none
      end
    end

    private

    # In order to avoid deadlock, we do NOT specify the job execution order in the same pipeline.
    # The system processes wherever ready to transition to `pending` status from `waiting_for_resource`.
    # See https://gitlab.com/gitlab-org/gitlab/-/issues/202186 for more information.
    def sort_by_job_status
      <<~SQL
        CASE status
          WHEN 'waiting_for_resource' THEN 0
          ELSE 1
        END ASC
      SQL
    end

    def ensure_resource
      # Currently we only support one resource per group, which means
      # maximum one build can be set to the resource group, thus builds
      # belong to the same resource group are executed once at time.
      self.resources.build if self.resources.empty?
    end
  end
end
