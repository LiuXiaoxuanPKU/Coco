# frozen_string_literal: true

module Reports::UserToUserPrivateMessagesWithReplies
  extend ActiveSupport::Concern

  class_methods do
    def report_user_to_user_private_messages_with_replies(report)
      report.icon = 'envelope'
      topic_subtype = TopicSubtype.user_to_user
      subject = Post.where('posts.user_id > 0')
      basic_report_about report, subject, :private_messages_count_per_day, report.start_date, report.end_date, topic_subtype
      subject = Post.private_posts.where('posts.user_id > 0').with_topic_subtype(topic_subtype)
      add_counts report, subject, 'posts.created_at'
    end
  end
end
