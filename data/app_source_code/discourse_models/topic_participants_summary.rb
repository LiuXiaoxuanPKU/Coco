# frozen_string_literal: true

# This is used on a topic page
class TopicParticipantsSummary
  attr_reader :topic, :options
  PARTICIPANT_COUNT = 5 # should match maxUserCount in topic list

  def initialize(topic, options = {})
    @topic = topic
    @options = options
    @user = options[:user]
  end

  def summary
    top_participants.compact.map(&method(:new_topic_poster_for))
  end

  def new_topic_poster_for(user)
    TopicPoster.new.tap do |topic_poster|
      topic_poster.user = user
      topic_poster.extras = 'latest' if is_latest_poster?(user)
    end
  end

  def is_latest_poster?(user)
    topic.last_post_user_id == user.id
  end

  def top_participants
    user_ids.map { |id| user_lookup[id] }.compact.uniq.take(PARTICIPANT_COUNT)
  end

  def user_ids
    return [] unless @user
    [topic.user_id] + topic.allowed_user_ids - [@user.id]
  end

  def user_lookup
    @user_lookup ||= options[:user_lookup] || UserLookup.new(user_ids)
  end
end
