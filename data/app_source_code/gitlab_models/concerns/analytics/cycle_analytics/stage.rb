# frozen_string_literal: true

module Analytics
  module CycleAnalytics
    module Stage
      extend ActiveSupport::Concern
      include RelativePositioning
      include Gitlab::Utils::StrongMemoize

      included do
        belongs_to :start_event_label, class_name: 'GroupLabel', optional: true
        belongs_to :end_event_label, class_name: 'GroupLabel', optional: true
        belongs_to :stage_event_hash, class_name: 'Analytics::CycleAnalytics::StageEventHash', foreign_key: :stage_event_hash_id, optional: true

        validates :name, presence: true
        validates :name, exclusion: { in: Gitlab::Analytics::CycleAnalytics::DefaultStages.names }, if: :custom?
        validates :start_event_identifier, presence: true
        validates :end_event_identifier, presence: true
        validates :start_event_label_id, presence: true, if: :start_event_label_based?
        validates :end_event_label_id, presence: true, if: :end_event_label_based?
        validate :validate_stage_event_pairs
        validate :validate_labels

        enum start_event_identifier: Gitlab::Analytics::CycleAnalytics::StageEvents.to_enum, _prefix: :start_event_identifier
        enum end_event_identifier: Gitlab::Analytics::CycleAnalytics::StageEvents.to_enum, _prefix: :end_event_identifier

        alias_attribute :custom_stage?, :custom
        scope :default_stages, -> { where(custom: false) }
        scope :ordered, -> { order(:relative_position, :id) }
        scope :with_preloaded_labels, -> { includes(:start_event_label, :end_event_label) }
        scope :for_list, -> { with_preloaded_labels.ordered }
        scope :by_value_stream, -> (value_stream) { where(value_stream_id: value_stream.id) }

        before_save :ensure_stage_event_hash_id
        after_commit :cleanup_old_stage_event_hash
      end

      def parent=(_)
        raise NotImplementedError
      end

      def parent
        raise NotImplementedError
      end

      def start_event
        strong_memoize(:start_event) do
          Gitlab::Analytics::CycleAnalytics::StageEvents[start_event_identifier].new(params_for_start_event)
        end
      end

      def end_event
        strong_memoize(:end_event) do
          Gitlab::Analytics::CycleAnalytics::StageEvents[end_event_identifier].new(params_for_end_event)
        end
      end

      def events_hash_code
        Digest::SHA256.hexdigest("#{start_event.hash_code}-#{end_event.hash_code}")
      end

      def start_event_label_based?
        start_event_identifier && start_event.label_based?
      end

      def end_event_label_based?
        end_event_identifier && end_event.label_based?
      end

      def start_event_identifier=(identifier)
        clear_memoization(:start_event)
        super
      end

      def end_event_identifier=(identifier)
        clear_memoization(:end_event)
        super
      end

      def params_for_start_event
        start_event_label.present? ? { label: start_event_label } : {}
      end

      def params_for_end_event
        end_event_label.present? ? { label: end_event_label } : {}
      end

      def default_stage?
        !custom
      end

      # The model class that is going to be queried, Issue or MergeRequest
      def subject_class
        start_event.object_type
      end

      def matches_with_stage_params?(stage_params)
        default_stage? &&
          start_event_identifier.to_s.eql?(stage_params[:start_event_identifier].to_s) &&
          end_event_identifier.to_s.eql?(stage_params[:end_event_identifier].to_s)
      end

      def find_with_same_parent!(id)
        parent.cycle_analytics_stages.find(id)
      end

      private

      def validate_stage_event_pairs
        return if start_event_identifier.nil? || end_event_identifier.nil?

        unless pairing_rules.fetch(start_event.class, []).include?(end_event.class)
          errors.add(:end_event, s_('CycleAnalytics|not allowed for the given start event'))
        end
      end

      def pairing_rules
        Gitlab::Analytics::CycleAnalytics::StageEvents.pairing_rules
      end

      def validate_labels
        validate_label_within_group(:start_event_label_id, start_event_label_id) if start_event_label_id_changed?
        validate_label_within_group(:end_event_label_id, end_event_label_id) if end_event_label_id_changed?
      end

      def validate_label_within_group(association_name, label_id)
        return unless label_id
        return unless group

        unless label_available_for_group?(label_id)
          errors.add(association_name, s_('CycleAnalyticsStage|is not available for the selected group'))
        end
      end

      def label_available_for_group?(label_id)
        LabelsFinder.new(nil, { group_id: group.id, include_ancestor_groups: true, only_group_labels: true })
          .execute(skip_authorization: true)
          .id_in(label_id)
          .exists?
      end

      def ensure_stage_event_hash_id
        previous_stage_event_hash = stage_event_hash&.hash_sha256

        if previous_stage_event_hash.blank? || events_hash_code != previous_stage_event_hash
          self.stage_event_hash_id = Analytics::CycleAnalytics::StageEventHash.record_id_by_hash_sha256(events_hash_code)
        end
      end

      def cleanup_old_stage_event_hash
        if stage_event_hash_id_previously_changed? && stage_event_hash_id_previously_was
          Analytics::CycleAnalytics::StageEventHash.cleanup_if_unused(stage_event_hash_id_previously_was)
        end
      end
    end
  end
end
