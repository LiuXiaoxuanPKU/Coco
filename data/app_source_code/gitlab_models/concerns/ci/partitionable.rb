# frozen_string_literal: true

module Ci
  ##
  # This module implements a way to set the `partion_id` value on a dependent
  # resource from a parent record.
  # Usage:
  #
  #     class PipelineVariable < Ci::ApplicationRecord
  #       include Ci::Partitionable
  #
  #       belongs_to :pipeline
  #       partitionable scope: :pipeline
  #       # Or
  #       partitionable scope: ->(record) { record.partition_value }
  #
  #
  module Partitionable
    extend ActiveSupport::Concern
    include ::Gitlab::Utils::StrongMemoize

    module Testing
      InclusionError = Class.new(StandardError)

      PARTITIONABLE_MODELS = %w[
        CommitStatus
        Ci::BuildMetadata
        Ci::BuildNeed
        Ci::BuildReportResult
        Ci::BuildRunnerSession
        Ci::BuildTraceChunk
        Ci::BuildTraceMetadata
        Ci::BuildPendingState
        Ci::JobArtifact
        Ci::JobVariable
        Ci::Pipeline
        Ci::PendingBuild
        Ci::RunningBuild
        Ci::PipelineVariable
        Ci::Sources::Pipeline
        Ci::Stage
        Ci::UnitTestFailure
      ].freeze

      def self.check_inclusion(klass)
        return if PARTITIONABLE_MODELS.include?(klass.name)

        raise Partitionable::Testing::InclusionError,
          "#{klass} must be included in PARTITIONABLE_MODELS"

      rescue InclusionError => e
        Gitlab::ErrorTracking.track_and_raise_for_dev_exception(e)
      end
    end

    included do
      Partitionable::Testing.check_inclusion(self)

      before_validation :set_partition_id, on: :create
      validates :partition_id, presence: true

      def set_partition_id
        return if partition_id_changed? && partition_id.present?
        return unless partition_scope_value

        self.partition_id = partition_scope_value
      end
    end

    class_methods do
      def partitionable(scope:, through: nil, partitioned: false)
        handle_partitionable_through(through)
        handle_partitionable_dml(partitioned)
        handle_partitionable_scope(scope)
      end

      private

      def handle_partitionable_through(options)
        return unless options

        define_singleton_method(:routing_table_name) { options[:table] }
        define_singleton_method(:routing_table_name_flag) { options[:flag] }

        include Partitionable::Switch
      end

      def handle_partitionable_dml(partitioned)
        define_singleton_method(:partitioned?) { partitioned }
        return unless partitioned

        include Partitionable::PartitionedFilter
      end

      def handle_partitionable_scope(scope)
        define_method(:partition_scope_value) do
          strong_memoize(:partition_scope_value) do
            next Ci::Pipeline.current_partition_value if respond_to?(:importing?) && importing?

            record = scope.to_proc.call(self)
            record.respond_to?(:partition_id) ? record.partition_id : record
          end
        end
      end
    end
  end
end
