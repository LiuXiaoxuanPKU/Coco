# frozen_string_literal: true

class Report
  # Change this line each time report format change
  # and you want to ensure cache is reset
  SCHEMA_VERSION = 4

  FILTERS = [:name, :start_date, :end_date, :category, :group, :trust_level, :file_extension, :include_subcategories]

  include Reports::PostEdits
  include Reports::TopTrafficSources
  include Reports::TopicsWithNoResponse
  include Reports::DauByMau
  include Reports::FlagsStatus
  include Reports::Emails
  include Reports::Likes
  include Reports::SystemPrivateMessages
  include Reports::UsersByType
  include Reports::StorageStats
  include Reports::NotifyModeratorsPrivateMessages
  include Reports::SuspiciousLogins
  include Reports::TopReferredTopics
  include Reports::Signups
  include Reports::NotifyUserPrivateMessages
  include Reports::NewContributors
  include Reports::TrendingSearch
  include Reports::UserToUserPrivateMessages
  include Reports::Flags
  include Reports::Topics
  include Reports::Posts
  include Reports::Bookmarks
  include Reports::StaffLogins
  include Reports::DailyEngagedUsers
  include Reports::UserToUserPrivateMessagesWithReplies
  include Reports::MobileVisits
  include Reports::TopReferrers
  include Reports::WebCrawlers
  include Reports::ModeratorsActivity
  include Reports::TopIgnoredUsers
  include Reports::UserFlaggingRatio
  include Reports::TrustLevelGrowth
  include Reports::ConsolidatedPageViews
  include Reports::Visits
  include Reports::TimeToFirstResponse
  include Reports::UsersByTrustLevel
  include Reports::ModeratorWarningPrivateMessages
  include Reports::ProfileViews
  include Reports::TopUploads

  attr_accessor :type, :data, :total, :prev30Days, :start_date,
                :end_date, :labels, :prev_period, :facets, :limit, :average,
                :percent, :higher_is_better, :icon, :modes, :prev_data,
                :prev_start_date, :prev_end_date, :dates_filtering, :error,
                :primary_color, :secondary_color, :filters, :available_filters

  def self.default_days
    30
  end

  def self.default_labels
    [
      {
        type: :date,
        property: :x,
        title: I18n.t("reports.default.labels.day")
      },
      {
        type: :number,
        property: :y,
        title: I18n.t("reports.default.labels.count")
      },
    ]
  end

  def initialize(type)
    @type = type
    @start_date ||= Report.default_days.days.ago.utc.beginning_of_day
    @end_date ||= Time.now.utc.end_of_day
    @prev_end_date = @start_date
    @average = false
    @percent = false
    @higher_is_better = true
    @modes = [:table, :chart]
    @prev_data = nil
    @dates_filtering = true
    @available_filters = {}
    @filters = {}

    tertiary = ColorScheme.hex_for_name('tertiary') || '0088cc'
    @primary_color = rgba_color(tertiary)
    @secondary_color = rgba_color(tertiary, 0.1)
  end

  def self.cache_key(report)
    [
      "reports",
      report.type,
      report.start_date.to_date.strftime("%Y%m%d"),
      report.end_date.to_date.strftime("%Y%m%d"),
      report.facets,
      report.limit,
      report.filters.blank? ? nil : MultiJson.dump(report.filters),
      SCHEMA_VERSION,
    ].compact.map(&:to_s).join(':')
  end

  def add_filter(name, options = {})
    if options[:type].blank?
      options[:type] = name
      Discourse.deprecate("#{name} filter should define a `:type` option. Temporarily setting type to #{name}.")
    end

    available_filters[name] = options
  end

  def remove_filter(name)
    available_filters.delete(name)
  end

  def add_category_filter
    category_id = filters[:category].to_i if filters[:category].present?
    add_filter('category', type: 'category', default: category_id)
    return if category_id.blank?

    include_subcategories = filters[:include_subcategories]
    include_subcategories = !!ActiveRecord::Type::Boolean.new.cast(include_subcategories)
    add_filter('include_subcategories', type: 'bool', default: include_subcategories)

    [category_id, include_subcategories]
  end

  def self.clear_cache(type = nil)
    pattern = type ? "reports:#{type}:*" : "reports:*"

    Discourse.cache.keys(pattern).each do |key|
      Discourse.cache.redis.del(key)
    end
  end

  def self.wrap_slow_query(timeout = 20000)
    ActiveRecord::Base.connection.transaction do
      # Allows only read only transactions
      DB.exec "SET TRANSACTION READ ONLY"
      # Set a statement timeout so we can't tie up the server
      DB.exec "SET LOCAL statement_timeout = #{timeout}"
      yield
    end
  end

  def prev_start_date
    self.start_date - (self.end_date - self.start_date)
  end

  def prev_end_date
    self.start_date
  end

  def as_json(options = nil)
    description = I18n.t("reports.#{type}.description", default: "")
    description_link = I18n.t("reports.#{type}.description_link", default: "")

    {
      type: type,
      title: I18n.t("reports.#{type}.title", default: nil),
      xaxis: I18n.t("reports.#{type}.xaxis", default: nil),
      yaxis: I18n.t("reports.#{type}.yaxis", default: nil),
      description: description.presence ? description : nil,
      description_link: description_link.presence ? description_link : nil,
      data: data,
      start_date: start_date&.iso8601,
      end_date: end_date&.iso8601,
      prev_data: self.prev_data,
      prev_start_date: prev_start_date&.iso8601,
      prev_end_date: prev_end_date&.iso8601,
      prev30Days: self.prev30Days,
      dates_filtering: self.dates_filtering,
      report_key: Report.cache_key(self),
      primary_color: self.primary_color,
      secondary_color: self.secondary_color,
      available_filters: self.available_filters.map { |k, v| { id: k }.merge(v) },
      labels: labels || Report.default_labels,
      average: self.average,
      percent: self.percent,
      higher_is_better: self.higher_is_better,
      modes: self.modes,
    }.tap do |json|
      json[:icon] = self.icon if self.icon
      json[:error] = self.error if self.error
      json[:total] = self.total if self.total
      json[:prev_period] = self.prev_period if self.prev_period
      json[:prev30Days] = self.prev30Days if self.prev30Days
      json[:limit] = self.limit if self.limit

      if type == 'page_view_crawler_reqs'
        json[:related_report] = Report.find('web_crawlers', start_date: start_date, end_date: end_date)&.as_json
      end
    end
  end

  def Report.add_report(name, &block)
    singleton_class.instance_eval { define_method("report_#{name}", &block) }
  end

  def self._get(type, opts = nil)
    opts ||= {}

    # Load the report
    report = Report.new(type)
    report.start_date = opts[:start_date] if opts[:start_date]
    report.end_date = opts[:end_date] if opts[:end_date]
    report.facets = opts[:facets] || [:total, :prev30Days]
    report.limit = opts[:limit] if opts[:limit]
    report.average = opts[:average] if opts[:average]
    report.percent = opts[:percent] if opts[:percent]
    report.filters = opts[:filters] if opts[:filters]
    report.labels = Report.default_labels

    report
  end

  def self.find_cached(type, opts = nil)
    report = _get(type, opts)
    Discourse.cache.read(cache_key(report))
  end

  def self.cache(report)
    duration = report.error == :exception ? 1.minute : 35.minutes
    Discourse.cache.write(cache_key(report), report.as_json, expires_in: duration)
  end

  def self.find(type, opts = nil)
    opts ||= {}

    begin
      report = _get(type, opts)
      report_method = :"report_#{type}"

      begin
        wrap_slow_query do
          if respond_to?(report_method)
            public_send(report_method, report)
          elsif type =~ /_reqs$/
            req_report(report, type.split(/_reqs$/)[0].to_sym)
          else
            return nil
          end
        end
      rescue ActiveRecord::QueryCanceled, PG::QueryCanceled => e
        report.error = :timeout
      end
    rescue Exception => e
      # In test mode, don't swallow exceptions by default to help debug errors.
      raise if Rails.env.test? && !opts[:wrap_exceptions_in_test]

      # ensures that if anything unexpected prevents us from
      # creating a report object we fail elegantly and log an error
      if !report
        Rails.logger.error("Couldn’t create report `#{type}`: <#{e.class} #{e.message}>")
        return nil
      end

      report.error = :exception

      # given reports can be added by plugins we don’t want dashboard failures
      # on report computation, however we do want to log which report is provoking
      # an error
      Rails.logger.error("Error while computing report `#{report.type}`: #{e.message}\n#{e.backtrace.join("\n")}")
    end

    report
  end

  def self.req_report(report, filter = nil)
    data =
      if filter == :page_view_total
        ApplicationRequest.where(req_type: [
          ApplicationRequest.req_types.reject { |k, v| k =~ /mobile/ }.map { |k, v| v if k =~ /page_view/ }.compact
        ].flatten)
      else
        ApplicationRequest.where(req_type: ApplicationRequest.req_types[filter])
      end

    if filter == :page_view_total
      report.icon = 'file'
    end

    report.data = []
    data.where('date >= ? AND date <= ?', report.start_date, report.end_date)
      .order(date: :asc)
      .group(:date)
      .sum(:count)
      .each do |date, count|
      report.data << { x: date, y: count }
    end

    report.total = data.sum(:count)

    report.prev30Days = data.where(
        'date >= ? AND date < ?',
        (report.start_date - 31.days), report.start_date
      ).sum(:count)
  end

  def self.report_about(report, subject_class, report_method = :count_per_day)
    basic_report_about report, subject_class, report_method, report.start_date, report.end_date
    add_counts report, subject_class
  end

  def self.basic_report_about(report, subject_class, report_method, *args)
    report.data = []

    subject_class.public_send(report_method, *args).each do |date, count|
      report.data << { x: date, y: count }
    end
  end

  def self.add_prev_data(report, subject_class, report_method, *args)
    if report.modes.include?(:chart) && report.facets.include?(:prev_period)
      prev_data = subject_class.public_send(report_method, *args)
      report.prev_data = prev_data.map { |k, v| { x: k, y: v } }
    end
  end

  def self.add_counts(report, subject_class, query_column = 'created_at')
    if report.facets.include?(:prev_period)
      prev_data = subject_class
        .where("#{query_column} >= ? and #{query_column} < ?",
          report.prev_start_date,
          report.prev_end_date)

      report.prev_period = prev_data.count
    end

    if report.facets.include?(:total)
      report.total = subject_class.count
    end

    if report.facets.include?(:prev30Days)
      report.prev30Days = subject_class
        .where("#{query_column} >= ? and #{query_column} < ?",
          report.start_date - 30.days,
          report.start_date).count
    end
  end

  def self.post_action_report(report, post_action_type)
    category_id, include_subcategories = report.add_category_filter

    report.data = []
    PostAction.count_per_day_for_type(post_action_type, category_id: category_id, include_subcategories: include_subcategories, start_date: report.start_date, end_date: report.end_date).each do |date, count|
      report.data << { x: date, y: count }
    end

    countable = PostAction.unscoped.where(post_action_type_id: post_action_type)
    if category_id
      if include_subcategories
        countable = countable.joins(post: :topic).where('topics.category_id IN (?)', Category.subcategory_ids(category_id))
      else
        countable = countable.joins(post: :topic).where('topics.category_id = ?', category_id)
      end
    end

    add_counts report, countable, 'post_actions.created_at'
  end

  def self.private_messages_report(report, topic_subtype)
    report.icon = 'envelope'
    subject = Topic.where('topics.user_id > 0')
    basic_report_about report, subject, :private_message_topics_count_per_day, report.start_date, report.end_date, topic_subtype
    subject = Topic.private_messages.where('topics.user_id > 0').with_subtype(topic_subtype)
    add_counts report, subject, 'topics.created_at'
  end

  def lighten_color(hex, amount)
    hex = adjust_hex(hex)
    rgb = hex.scan(/../).map { |color| color.hex }
    rgb[0] = [(rgb[0].to_i + 255 * amount).round, 255].min
    rgb[1] = [(rgb[1].to_i + 255 * amount).round, 255].min
    rgb[2] = [(rgb[2].to_i + 255 * amount).round, 255].min
    "#%02x%02x%02x" % rgb
  end

  def rgba_color(hex, opacity = 1)
    rgbs = hex_to_rgbs(adjust_hex(hex))
    "rgba(#{rgbs.join(',')},#{opacity})"
  end

  private

  def adjust_hex(hex)
    hex = hex.gsub('#', '')

    if hex.size == 3
      chars = hex.scan(/\w/)
      hex = chars.zip(chars).flatten.join
    end

    if hex.size < 3
      hex = hex.ljust(6, hex.last)
    end

    hex
  end

  def hex_to_rgbs(hex_color)
    hex_color = hex_color.gsub('#', '')
    rgbs = hex_color.scan(/../)
    rgbs
      .map! { |color| color.hex }
      .map! { |rgb| rgb.to_i }
  end
end
