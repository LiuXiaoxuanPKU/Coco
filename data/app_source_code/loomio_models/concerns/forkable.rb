module Forkable
  extend ActiveSupport::Concern

  included { attr_accessor :forked_event_ids }

  def forked_items
    Event.where(id: self.forked_event_ids).order(:sequence_id)
  end

  def forked_comments
    Comment.where(id: forked_items.where(kind: :new_comment).pluck(:eventable_id))
  end

  def forked_event
    events.find_by(kind: :discussion_forked)
  end
end
