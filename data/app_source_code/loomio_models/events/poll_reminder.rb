class Events::PollReminder < Event
  include Events::Notify::InApp
  include Events::Notify::ByEmail

  def self.publish!(poll:, actor: , recipient_user_ids: [], recipient_message: nil, recipient_audience: nil)
    super(poll,
          discussion_id: nil,
          user: actor,
          recipient_user_ids: Array(recipient_user_ids).uniq.compact,
          recipient_audience: recipient_audience.presence,
          recipient_message: recipient_message.presence)
  end
end
