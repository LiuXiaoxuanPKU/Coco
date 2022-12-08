# frozen_string_literal: true

class RawUsageData < ApplicationRecord
  REPORTING_CADENCE = 7.days.freeze

  validates :payload, presence: true
  validates :recorded_at, presence: true, uniqueness: true

  scope :for_current_reporting_cycle, -> do
    where('created_at >= ?', REPORTING_CADENCE.ago.beginning_of_day)
      .order(created_at: :desc)
  end

  def update_version_metadata!(usage_data_id:)
    self.update_columns(sent_at: Time.current, version_usage_data_id_value: usage_data_id)
  end
end
