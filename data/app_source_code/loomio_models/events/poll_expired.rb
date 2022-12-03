class Events::PollExpired < Event
  include Events::Notify::Author
  include Events::Notify::ThirdParty
  include Events::Notify::InApp

  def self.publish!(poll)
    super poll,
          user: poll.author,
          discussion: poll.discussion,
          created_at: poll.closed_at
  end

  # email the author and create an in-app notification
  def email_author!
    super
    notification_for(author).save
  end

  def notify_author?
    Queries::UsersByVolumeQuery.email_notifications(eventable).exists?(poll.author_id)
  end
end
