# frozen_string_literal: true

module Integrations
  class BaseSlackNotification < BaseChatNotification
    SUPPORTED_EVENTS_FOR_USAGE_LOG = %w[
      push issue confidential_issue merge_request note confidential_note tag_push wiki_page deployment
    ].freeze

    prop_accessor EVENT_CHANNEL['alert']

    override :default_channel_placeholder
    def default_channel_placeholder
      _('#general, #development')
    end

    override :get_message
    def get_message(object_kind, data)
      return Integrations::ChatMessage::AlertMessage.new(data) if object_kind == 'alert'

      super
    end

    override :supported_events
    def supported_events
      additional = ['alert']

      super + additional
    end

    override :configurable_channels?
    def configurable_channels?
      true
    end

    private

    override :log_usage
    def log_usage(event, user_id)
      return unless user_id

      return unless SUPPORTED_EVENTS_FOR_USAGE_LOG.include?(event)

      key = "#{metrics_key_prefix}_#{event}_notification"

      Gitlab::UsageDataCounters::HLLRedisCounter.track_event(key, values: user_id)

      return unless Feature.enabled?(:route_hll_to_snowplow_phase2)

      optional_arguments = {
        project: project,
        namespace: group || project&.namespace
      }.compact

      Gitlab::Tracking.event(
        self.class.name,
        Integration::SNOWPLOW_EVENT_ACTION,
        label: Integration::SNOWPLOW_EVENT_LABEL,
        property: key,
        user: User.find(user_id),
        context: [Gitlab::Tracking::ServicePingContext.new(data_source: :redis_hll, event: key).to_context],
        **optional_arguments
      )
    end

    def metrics_key_prefix
      raise NotImplementedError
    end
  end
end
