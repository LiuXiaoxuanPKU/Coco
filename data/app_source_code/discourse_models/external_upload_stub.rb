# frozen_string_literal: true

require "digest/sha1"

class ExternalUploadStub < ActiveRecord::Base
  CREATED_EXPIRY_HOURS = 1
  UPLOADED_EXPIRY_HOURS = 24

  belongs_to :created_by, class_name: 'User'

  scope :expired_created, -> {
    where(
      "status = ? AND created_at <= ?",
      ExternalUploadStub.statuses[:created],
      CREATED_EXPIRY_HOURS.hours.ago
    )
  }

  scope :expired_uploaded, -> {
    where(
      "status = ? AND created_at <= ?",
      ExternalUploadStub.statuses[:uploaded],
      UPLOADED_EXPIRY_HOURS.hours.ago
    )
  }

  before_create do
    self.unique_identifier = SecureRandom.uuid
    self.status = ExternalUploadStub.statuses[:created] if self.status.blank?
  end

  def self.statuses
    @statuses ||= Enum.new(
      created: 1,
      uploaded: 2,
      failed: 3
    )
  end

  # TODO (martin): Lifecycle rule would be best to clean stuff up in the external
  # systems, I don't think we really want to be calling out to the external systems
  # here right?
  def self.cleanup!
    expired_created.delete_all
    expired_uploaded.delete_all
  end
end

# == Schema Information
#
# Table name: external_upload_stubs
#
#  id                :bigint           not null, primary key
#  key               :string           not null
#  original_filename :string           not null
#  status            :integer          default(1), not null
#  unique_identifier :uuid             not null
#  created_by_id     :integer          not null
#  upload_type       :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_external_upload_stubs_on_created_by_id  (created_by_id)
#  index_external_upload_stubs_on_key            (key) UNIQUE
#  index_external_upload_stubs_on_status         (status)
#
