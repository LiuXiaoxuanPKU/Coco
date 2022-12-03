# frozen_string_literal: true

module Reports::ProfileViews
  extend ActiveSupport::Concern

  class_methods do
    def report_profile_views(report)
      group_filter = report.filters.dig(:group)
      report.add_filter('group', type: 'group', default: group_filter)

      start_date = report.start_date
      end_date = report.end_date
      basic_report_about report, UserProfileView, :profile_views_by_day, start_date, end_date, group_filter

      report.total = UserProfile.sum(:views)
      report.prev30Days = UserProfileView.where('viewed_at >= ? AND viewed_at < ?', start_date - 30.days, start_date + 1).count
    end
  end
end
