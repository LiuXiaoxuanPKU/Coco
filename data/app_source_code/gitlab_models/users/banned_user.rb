# frozen_string_literal: true

module Users
  class BannedUser < ApplicationRecord
    self.primary_key = :user_id

    belongs_to :user

    validates :user, presence: true
    validates :user_id, uniqueness: { message: N_("banned user already exists") }
  end
end
