class User < ApplicationRecord
  resourcify
  rolify

  include CloudinaryHelper
  include Storext.model

  # @citizen428 Preparing to drop profile columns from the users table
  PROFILE_COLUMNS = %w[
    available_for
    behance_url
    bg_color_hex
    currently_hacking_on
    currently_learning
    currently_streaming_on
    dribbble_url
    education
    email_public
    employer_name
    employer_url
    employment_title
    facebook_url
    gitlab_url
    instagram_url
    linkedin_url
    location
    mastodon_url
    medium_url
    mostly_work_with
    stackoverflow_url
    summary
    text_color_hex
    twitch_url
    twitch_username
    website_url
    youtube_url
  ].freeze

  INACTIVE_PROFILE_COLUMNS = %w[
    bg_color_hex
    text_color_hex
    email_public
  ].freeze

  self.ignored_columns = PROFILE_COLUMNS

  # NOTE: @citizen428 This is temporary code during profile migration and will
  # be removed.
  concerning :ProfileMigration do
    included do
      # NOTE: There are rare cases were we want to skip this callback, primarily
      # in tests. `skip_callback` modifies global state, which is not thread-safe
      # and can cause hard to track down bugs. We use an instance-level attribute
      # instead. See `spec/factories/profiles.rb` for an example.
      attr_accessor :_skip_creating_profile

      # All new users should automatically have a profile
      after_create_commit -> { Profile.create(user: self) }, unless: :_skip_creating_profile

      # Getters and setters for unmapped profile attributes
      (PROFILE_COLUMNS - Profile::MAPPED_ATTRIBUTES.values).each do |column|
        next if INACTIVE_PROFILE_COLUMNS.include?(column)

        delegate column, "#{column}=", to: :profile, allow_nil: true
      end

      # Getters and setters for mapped profile attributes
      Profile::MAPPED_ATTRIBUTES.each do |profile_attribute, user_attribute|
        define_method(user_attribute) { profile&.public_send(profile_attribute) }
        define_method("#{user_attribute}=") do |value|
          profile&.public_send("#{profile_attribute}=", value)
        end
      end
    end
  end

  ANY_ADMIN_ROLES = %i[admin super_admin].freeze
  USERNAME_MAX_LENGTH = 30
  USERNAME_REGEXP = /\A[a-zA-Z0-9_]+\z/.freeze
  MESSAGES = {
    reserved_username: "username is reserved"
  }.freeze
  # follow the syntax in https://interledger.org/rfcs/0026-payment-pointers/#payment-pointer-syntax
  PAYMENT_POINTER_REGEXP = %r{
    \A                # start
    \$                # starts with a dollar sign
    ([a-zA-Z0-9\-.])+ # matches the hostname (ex ilp.uphold.com)
    (/[\x20-\x7F]+)?  # optional forward slash and identifier with printable ASCII characters
    \z
  }x.freeze

  attr_accessor :scholar_email, :new_note, :note_for_current_role, :user_status, :merge_user_id,
                :add_credits, :remove_credits, :add_org_credits, :remove_org_credits, :ip_address,
                :current_password

  acts_as_followable
  acts_as_follower

  has_one :profile, dependent: :destroy
  has_one :notification_setting, class_name: "Users::NotificationSetting", dependent: :destroy
  has_one :setting, class_name: "Users::Setting", dependent: :destroy

  has_many :access_grants, class_name: "Doorkeeper::AccessGrant", foreign_key: :resource_owner_id,
                           inverse_of: :resource_owner, dependent: :delete_all
  has_many :access_tokens, class_name: "Doorkeeper::AccessToken", foreign_key: :resource_owner_id,
                           inverse_of: :resource_owner, dependent: :delete_all
  has_many :affected_feedback_messages, class_name: "FeedbackMessage",
                                        inverse_of: :affected, foreign_key: :affected_id, dependent: :nullify
  has_many :ahoy_events, class_name: "Ahoy::Event", dependent: :destroy
  has_many :ahoy_visits, class_name: "Ahoy::Visit", dependent: :destroy
  has_many :api_secrets, dependent: :destroy
  has_many :articles, dependent: :destroy
  has_many :audit_logs, dependent: :nullify
  has_many :authored_notes, inverse_of: :author, class_name: "Note", foreign_key: :author_id, dependent: :delete_all
  has_many :badge_achievements, dependent: :destroy
  has_many :badge_achievements_rewarded, class_name: "BadgeAchievement", foreign_key: :rewarder_id,
                                         inverse_of: :rewarder, dependent: :nullify
  has_many :badges, through: :badge_achievements
  has_many :banished_users, class_name: "BanishedUser", foreign_key: :banished_by_id,
                            inverse_of: :banished_by, dependent: :nullify
  has_many :blocked_blocks, class_name: "UserBlock", foreign_key: :blocked_id,
                            inverse_of: :blocked, dependent: :delete_all
  has_many :blocker_blocks, class_name: "UserBlock", foreign_key: :blocker_id,
                            inverse_of: :blocker, dependent: :delete_all
  has_many :chat_channel_memberships, dependent: :destroy
  has_many :chat_channels, through: :chat_channel_memberships
  has_many :collections, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :created_podcasts, class_name: "Podcast", foreign_key: :creator_id, inverse_of: :creator, dependent: :nullify
  has_many :credits, dependent: :destroy
  has_many :discussion_locks, dependent: :destroy, inverse_of: :locking_user, foreign_key: :locking_user_id
  has_many :display_ad_events, dependent: :destroy
  has_many :email_authorizations, dependent: :delete_all
  has_many :email_messages, class_name: "Ahoy::Message", dependent: :destroy
  has_many :field_test_memberships, class_name: "FieldTest::Membership", as: :participant, dependent: :destroy
  has_many :github_repos, dependent: :destroy
  has_many :html_variants, dependent: :destroy
  has_many :identities, dependent: :destroy
  has_many :identities_enabled, -> { enabled }, class_name: "Identity", inverse_of: false
  has_many :listings, dependent: :destroy
  has_many :mentions, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :notes, as: :noteable, inverse_of: :noteable, dependent: :destroy
  has_many :notification_subscriptions, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :offender_feedback_messages, class_name: "FeedbackMessage",
                                        inverse_of: :offender, foreign_key: :offender_id, dependent: :nullify
  has_many :organization_memberships, dependent: :destroy
  has_many :organizations, through: :organization_memberships
  # we keep page views as they belong to the article, not to the user who viewed it
  has_many :page_views, dependent: :nullify
  has_many :podcast_episode_appearances, dependent: :destroy, inverse_of: :user
  has_many :podcast_episodes, through: :podcast_episode_appearances, source: :podcast_episode
  has_many :podcast_ownerships, dependent: :destroy, inverse_of: :owner
  has_many :podcasts_owned, through: :podcast_ownerships, source: :podcast
  has_many :poll_skips, dependent: :destroy
  has_many :poll_votes, dependent: :destroy
  has_many :profile_pins, as: :profile, inverse_of: :profile, dependent: :delete_all

  # we keep rating votes as they belong to the article, not to the user who viewed it
  has_many :rating_votes, dependent: :nullify

  has_many :reactions, dependent: :destroy
  has_many :reporter_feedback_messages, class_name: "FeedbackMessage",
                                        inverse_of: :reporter, foreign_key: :reporter_id, dependent: :nullify
  has_many :response_templates, inverse_of: :user, dependent: :destroy
  has_many :source_authored_user_subscriptions, class_name: "UserSubscription",
                                                foreign_key: :author_id, inverse_of: :author, dependent: :destroy
  has_many :subscribed_to_user_subscriptions, class_name: "UserSubscription",
                                              foreign_key: :subscriber_id, inverse_of: :subscriber, dependent: :destroy
  has_many :subscribers, through: :source_authored_user_subscriptions, dependent: :destroy
  has_many :tweets, dependent: :nullify
  has_many :webhook_endpoints, class_name: "Webhook::Endpoint", inverse_of: :user, dependent: :delete_all
  has_many :devices, dependent: :delete_all
  has_many :sponsorships, dependent: :destroy

  mount_uploader :profile_image, ProfileImageUploader

  devise :invitable, :omniauthable, :registerable, :database_authenticatable, :confirmable, :rememberable,
         :recoverable, :lockable

  validates :articles_count, presence: true
  validates :badge_achievements_count, presence: true
  validates :blocked_by_count, presence: true
  validates :blocking_others_count, presence: true
  validates :comments_count, presence: true
  validates :credits_count, presence: true
  validates :email, length: { maximum: 50 }, email: true, allow_nil: true
  validates :email, uniqueness: { allow_nil: true, case_sensitive: false }, if: :email_changed?
  validates :following_orgs_count, presence: true
  validates :following_tags_count, presence: true
  validates :following_users_count, presence: true
  validates :name, length: { in: 1..100 }
  validates :password, length: { in: 8..100 }, allow_nil: true
  validates :payment_pointer, format: PAYMENT_POINTER_REGEXP, allow_blank: true
  validates :rating_votes_count, presence: true
  validates :reactions_count, presence: true
  validates :sign_in_count, presence: true
  validates :spent_credits_count, presence: true
  validates :subscribed_to_user_subscriptions_count, presence: true
  validates :unspent_credits_count, presence: true
  validates :username, length: { in: 2..USERNAME_MAX_LENGTH }, format: USERNAME_REGEXP
  validates :username, presence: true, exclusion: { in: ReservedWords.all, message: MESSAGES[:invalid_username] }
  validates :username, uniqueness: { case_sensitive: false, message: lambda do |_obj, data|
    "#{data[:value]} is taken."
  end }, if: :username_changed?

  # add validators for provider related usernames
  Authentication::Providers.username_fields.each do |username_field|
    # make sure usernames are not empty string, to be able to use the database unique index
    clean_provider_username = proc do |record|
      cleaned_username = record.attributes[username_field.to_s].presence
      record.assign_attributes(username_field => cleaned_username)
    end
    before_validation clean_provider_username

    validates username_field, uniqueness: { allow_nil: true }, if: :"#{username_field}_changed?"
  end

  validate :non_banished_username, :username_changed?
  validate :unique_including_orgs_and_podcasts, if: :username_changed?
  validate :can_send_confirmation_email
  validate :update_rate_limit
  # NOTE: when updating the password on a Devise enabled model, the :encrypted_password
  # field will be marked as dirty, not :password.
  validate :password_matches_confirmation, if: :encrypted_password_changed?

  alias_attribute :public_reactions_count, :reactions_count

  scope :eager_load_serialized_data, -> { includes(:roles) }
  scope :registered, -> { where(registered: true) }
  # Unfortunately pg_search's default SQL query is not performant enough in this
  # particular case (~ 500ms). There are multiple reasons:
  # => creates a complex query like `SELECT FROM users INNER JOIN users` to compute ranking.
  #    See https://github.com/Casecommons/pg_search/issues/292#issuecomment-202604151
  # => it concatenates the content of `name` and the content of `username` to match
  #    against the search term. By doing that, it can't use `tsvector` indexes correctly
  #
  # For these reasons we need to build a query manually using an `OR` condition,
  # thus allowing the database to use the indexes properly. With this the SQL time is ~ 8-10ms.
  #
  # NOTE: we can't use unaccent() on the `tsvector` document because `unaccent()` can't be
  # used in expression indexes as it's a mutable function and depends on server settings
  # => https://stackoverflow.com/a/11007216/4186181
  #
  scope :search_by_name_and_username, lambda { |term|
    where(
      sanitize_sql_array(
        [
          "to_tsvector('simple', coalesce(name::text, '')) @@ to_tsquery('simple', ? || ':*')",
          connection.quote(term),
        ],
      ),
    ).or(
      where(
        sanitize_sql_array(
          [
            "to_tsvector('simple', coalesce(username::text, '')) @@ to_tsquery('simple', ? || ':*')",
            connection.quote(term),
          ],
        ),
      ),
    )
  }

  before_validation :check_for_username_change
  before_validation :downcase_email
  # make sure usernames are not empty, to be able to use the database unique index
  before_validation :verify_email
  before_validation :set_username
  before_validation :strip_payment_pointer
  before_create :create_users_settings_and_notification_settings_records
  before_destroy :unsubscribe_from_newsletters, prepend: true
  before_destroy :destroy_follows, prepend: true

  # NOTE: @citizen428 Temporary while migrating to generalized profiles
  after_save { |user| user.profile&.save if user.profile&.changed? }

  after_create_commit :send_welcome_notification

  after_commit :subscribe_to_mailchimp_newsletter
  after_commit :bust_cache

  def self.staff_account
    find_by(id: Settings::Community.staff_user_id)
  end

  def self.mascot_account
    find_by(id: Settings::General.mascot_user_id)
  end

  def tag_line
    summary
  end

  def twitter_url
    "https://twitter.com/#{twitter_username}" if twitter_username.present?
  end

  def github_url
    "https://github.com/#{github_username}" if github_username.present?
  end

  def set_remember_fields
    self.remember_token ||= self.class.remember_token if respond_to?(:remember_token)
    self.remember_created_at ||= Time.now.utc
  end

  def calculate_score
    score = (articles.where(featured: true).size * 100) + comments.sum(:score)
    update_column(:score, score)
  end

  def path
    "/#{username}"
  end

  def followed_articles
    Article
      .cached_tagged_with_any(cached_followed_tag_names).unscope(:select)
      .union(Article.where(user_id: cached_following_users_ids))
  end

  def cached_following_users_ids
    cache_key = "user-#{id}-#{last_followed_at}-#{following_users_count}/following_users_ids"
    Rails.cache.fetch(cache_key, expires_in: 12.hours) do
      Follow.follower_user(id).limit(150).pluck(:followable_id)
    end
  end

  def cached_following_organizations_ids
    cache_key = "user-#{id}-#{last_followed_at}-#{following_orgs_count}/following_organizations_ids"
    Rails.cache.fetch(cache_key, expires_in: 12.hours) do
      Follow.follower_organization(id).limit(150).pluck(:followable_id)
    end
  end

  def cached_following_podcasts_ids
    cache_key = "user-#{id}-#{last_followed_at}/following_podcasts_ids"
    Rails.cache.fetch(cache_key, expires_in: 12.hours) do
      Follow.follower_podcast(id).pluck(:followable_id)
    end
  end

  def cached_reading_list_article_ids
    Rails.cache.fetch("reading_list_ids_of_articles_#{id}_#{public_reactions_count}_#{last_reacted_at}") do
      Reaction.readinglist.where(
        user_id: id, reactable_type: "Article",
      ).where.not(status: "archived").order(created_at: :desc).pluck(:reactable_id)
    end
  end

  def processed_website_url
    profile.website_url.to_s.strip if profile.website_url.present?
  end

  def remember_me
    true
  end

  def cached_followed_tag_names
    cache_name = "user-#{id}-#{following_tags_count}-#{last_followed_at&.rfc3339}/followed_tag_names"
    Rails.cache.fetch(cache_name, expires_in: 24.hours) do
      Tag.where(
        id: Follow.where(
          follower_id: id,
          followable_type: "ActsAsTaggableOn::Tag",
        ).select(:followable_id),
      ).pluck(:name)
    end
  end

  def suspended?
    # TODO: [@jacobherrington] After all of our Forems have been successfully deployed,
    # and data scripts have successfully removed the banned role, we can remove `has_role?(:banned)`
    has_role?(:suspended) || has_role?(:banned)
  end

  def warned
    has_role?(:warned)
  end

  def admin?
    has_role?(:super_admin)
  end

  def any_admin?
    @any_admin ||= roles.where(name: ANY_ADMIN_ROLES).any?
  end

  def tech_admin?
    has_role?(:tech_admin) || has_role?(:super_admin)
  end

  def vomitted_on?
    Reaction.exists?(reactable_id: id, reactable_type: "User", category: "vomit", status: "confirmed")
  end

  def trusted
    return @trusted if defined? @trusted

    @trusted = Rails.cache.fetch("user-#{id}/has_trusted_role", expires_in: 200.hours) do
      has_role?(:trusted)
    end
  end

  def moderator_for_tags
    Rails.cache.fetch("user-#{id}/tag_moderators_list", expires_in: 200.hours) do
      tag_ids = roles.where(name: "tag_moderator").pluck(:resource_id)
      Tag.where(id: tag_ids).pluck(:name)
    end
  end

  def comment_suspended?
    # TODO: [@jacobherrington] After all of our Forems have been successfully deployed,
    # and data scripts have successfully removed the comment_banned role,
    # we can remove `has_role?(:comment_banned)`
    has_role?(:comment_suspended) || has_role?(:comment_banned)
  end

  def workshop_eligible?
    has_any_role?(:workshop_pass)
  end

  def admin_organizations
    org_ids = organization_memberships.where(type_of_user: "admin").pluck(:organization_id)
    organizations.where(id: org_ids)
  end

  def member_organizations
    org_ids = organization_memberships.where(type_of_user: %w[admin member]).pluck(:organization_id)
    organizations.where(id: org_ids)
  end

  def org_member?(organization)
    OrganizationMembership.exists?(user: self, organization: organization, type_of_user: %w[admin member])
  end

  def org_admin?(organization)
    OrganizationMembership.exists?(user: self, organization: organization, type_of_user: "admin")
  end

  def block; end

  def all_blocked_by
    UserBlock.where(blocked_id: id)
  end

  def blocking?(blocked_id)
    UserBlock.blocking?(id, blocked_id)
  end

  def blocked_by?(blocker_id)
    UserBlock.blocking?(blocker_id, id)
  end

  def unique_including_orgs_and_podcasts
    username_taken = (
      Organization.exists?(slug: username) ||
      Podcast.exists?(slug: username) ||
      Page.exists?(slug: username)
    )

    errors.add(:username, "is taken.") if username_taken
  end

  def non_banished_username
    errors.add(:username, "has been banished.") if BanishedUser.exists?(username: username)
  end

  def banished?
    username.starts_with?("spam_")
  end

  def subscribe_to_mailchimp_newsletter
    return unless registered && email.present?
    return if Settings::General.mailchimp_api_key.blank?
    return if saved_changes.key?(:unconfirmed_email) && saved_changes.key?(:confirmation_sent_at)
    return unless saved_changes.key?(:email)

    Users::SubscribeToMailchimpNewsletterWorker.perform_async(id)
  end

  def a_sustaining_member?
    monthly_dues.positive?
  end

  def resave_articles
    articles.find_each do |article|
      if article.path
        cache_bust = EdgeCache::Bust.new
        cache_bust.call(article.path)
        cache_bust.call("#{article.path}?i=i")
      end
      article.save
    end
  end

  def profile_image_90
    Images::Profile.call(profile_image_url, length: 90)
  end

  def unsubscribe_from_newsletters
    return if email.blank?
    return if Settings::General.mailchimp_api_key.blank?

    Mailchimp::Bot.new(self).unsubscribe_all_newsletters
  end

  def auditable?
    trusted || tag_moderator? || any_admin?
  end

  def tag_moderator?
    roles.where(name: "tag_moderator").any?
  end

  def enough_credits?(num_credits_needed)
    credits.unspent.size >= num_credits_needed
  end

  def receives_follower_email_notifications?
    email.present? && subscribed_to_email_follower_notifications?
  end

  def hotness_score
    search_score
  end

  def authenticated_through?(provider_name)
    return false unless Authentication::Providers.available?(provider_name)
    return false unless Authentication::Providers.enabled?(provider_name)

    identities_enabled.exists?(provider: provider_name)
  end

  def authenticated_with_all_providers?
    # ga_providers refers to Generally Available (not in beta)
    ga_providers = Authentication::Providers.enabled.reject { |sym| sym == :apple }
    enabled_providers = identities.pluck(:provider).map(&:to_sym)
    (ga_providers - enabled_providers).empty?
  end

  def rate_limiter
    RateLimitChecker.new(self)
  end

  def flipper_id
    "User:#{id}"
  end

  def subscribed_to_welcome_notifications?
    notification_setting.welcome_notifications
  end

  def subscribed_to_mod_roundrobin_notifications?
    notification_setting.mod_roundrobin_notifications
  end

  def subscribed_to_email_follower_notifications?
    notification_setting.email_follower_notifications
  end

  protected

  # Send emails asynchronously
  # see https://github.com/heartcombo/devise#activejob-integration
  def send_devise_notification(notification, *args)
    message = devise_mailer.public_send(notification, self, *args)
    message.deliver_later
  end

  private

  def create_users_settings_and_notification_settings_records
    self.setting = Users::Setting.create
    self.notification_setting = Users::NotificationSetting.create
  end

  def send_welcome_notification
    return unless (set_up_profile_broadcast = Broadcast.active.find_by(title: "Welcome Notification: set_up_profile"))

    Notification.send_welcome_notification(id, set_up_profile_broadcast.id)
  end

  def verify_email
    self.email = nil if email == ""
  end

  def set_username
    set_temp_username if username.blank?
    self.username = username&.downcase
  end

  def set_temp_username
    self.username = if temp_name_exists?
                      "#{temp_username}_#{rand(100)}"
                    else
                      temp_username
                    end
  end

  def temp_name_exists?
    User.exists?(username: temp_username) || Organization.exists?(slug: temp_username)
  end

  def temp_username
    Authentication::Providers.username_fields.each do |username_field|
      value = public_send(username_field)
      next if value.blank?

      return value.downcase.gsub(/[^0-9a-z_]/i, "").delete(" ")
    end
  end

  def downcase_email
    self.email = email.downcase if email
  end

  def check_for_username_change
    return unless username_changed?

    self.old_old_username = old_username
    self.old_username = username_was
    chat_channels.find_each do |channel|
      channel.slug = channel.slug.gsub(username_was, username)
      channel.save
    end
    articles.find_each do |article|
      article.path = article.path.gsub(username_was, username)
      article.save
    end
  end

  def bust_cache
    Users::BustCacheWorker.perform_async(id)
  end

  # TODO: @citizen428 I don't want to completely remove this method yet, as we
  # have similar methods in other models. But the previous implementation used
  # three profile fields that we can't guarantee to exist across all Forems. So
  # for now this method will just return an empty string.
  def tag_keywords_for_search
    ""
  end

  # TODO: this can be removed once we migrate away from ES
  def search_score
    counts_score = (articles_count + comments_count + reactions_count + badge_achievements_count) * 10
    score = (counts_score + tag_keywords_for_search.size) * reputation_modifier
    score.to_i
  end

  def destroy_follows
    follower_relationships = Follow.followable_user(id)
    follower_relationships.destroy_all
    follows.destroy_all
  end

  def can_send_confirmation_email
    return if changes[:email].blank? || id.blank?

    rate_limiter.track_limit_by_action(:send_email_confirmation)
    rate_limiter.check_limit!(:send_email_confirmation)
  rescue RateLimitChecker::LimitReached => e
    errors.add(:email, "confirmation could not be sent. #{e.message}")
  end

  def update_rate_limit
    return unless persisted?

    rate_limiter.track_limit_by_action(:user_update)
    rate_limiter.check_limit!(:user_update)
  rescue RateLimitChecker::LimitReached => e
    errors.add(:base, "User could not be saved. #{e.message}")
  end

  def password_matches_confirmation
    return true if password == password_confirmation

    errors.add(:password, "doesn't match password confirmation")
  end

  def strip_payment_pointer
    self.payment_pointer = payment_pointer.strip if payment_pointer
  end

  def confirmation_required?
    ForemInstance.smtp_enabled?
  end
end
