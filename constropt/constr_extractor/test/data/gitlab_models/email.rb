# frozen_string_literal: true

class Email < ApplicationRecord
  include Sortable
  include Gitlab::SQL::Pattern

  belongs_to :user, optional: false

  validates :email, presence: true, uniqueness: true, devise_email: true

  validate :unique_email, if: ->(email) { email.email_changed? }

  scope :confirmed, -> { where.not(confirmed_at: nil) }

  after_commit :update_invalid_gpg_signatures, if: -> { previous_changes.key?('confirmed_at') }

  devise :confirmable

  # This module adds async behaviour to Devise emails
  # and should be added after Devise modules are initialized.
  include AsyncDeviseEmail
  include ForcedEmailConfirmation

  self.reconfirmable = false # currently email can't be changed, no need to reconfirm

  delegate :username, :can?, :pending_invitations, :accept_pending_invitations!, to: :user

  def email=(value)
    write_attribute(:email, value.downcase.strip)
  end

  def unique_email
    self.errors.add(:email, 'has already been taken') if primary_email_of_another_user?
  end

  # once email is confirmed, update the gpg signatures
  def update_invalid_gpg_signatures
    user.update_invalid_gpg_signatures if confirmed?
  end

  def user_primary_email?
    email.casecmp?(user.email)
  end

  private

  def primary_email_of_another_user?
    User.where(email: email).where.not(id: user_id).exists?
  end
end
