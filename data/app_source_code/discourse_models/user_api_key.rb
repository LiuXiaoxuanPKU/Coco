# frozen_string_literal: true

class UserApiKey < ActiveRecord::Base
  self.ignored_columns = [
    "scopes" # TODO(2020-12-18): remove
  ]

  REVOKE_MATCHER = RouteMatcher.new(actions: "user_api_keys#revoke", methods: :post, params: [:id])

  belongs_to :user
  has_many :scopes, class_name: "UserApiKeyScope", dependent: :destroy

  scope :active, -> { where(revoked_at: nil) }
  scope :with_key, ->(key) { where(key_hash: ApiKey.hash_key(key)) }

  after_initialize :generate_key

  def generate_key
    if !self.key_hash
      @key ||= SecureRandom.hex
      self.key_hash = ApiKey.hash_key(@key)
    end
  end

  def key
    raise ApiKey::KeyAccessError.new "API key is only accessible immediately after creation" unless key_available?
    @key
  end

  def key_available?
    @key.present?
  end

  # Scopes allowed to be requested by external services
  def self.allowed_scopes
    Set.new(SiteSetting.allow_user_api_key_scopes.split("|"))
  end

  def self.available_scopes
    @available_scopes ||= Set.new(UserApiKeyScopes.all_scopes.keys.map(&:to_s))
  end

  def has_push?
    scopes.any? { |s| s.name == "push" || s.name == "notifications" } &&
      push_url.present? &&
      SiteSetting.allowed_user_api_push_urls.include?(push_url)
  end

  def allow?(env)
    scopes.any? { |s| s.permits?(env) } || is_revoke_self_request?(env)
  end

  def self.invalid_auth_redirect?(auth_redirect)
    SiteSetting.allowed_user_api_auth_redirects
      .split('|')
      .none? { |u| WildcardUrlChecker.check_url(u, auth_redirect) }
  end

  private

  def revoke_self_matcher
    REVOKE_MATCHER.with_allowed_param_values({ "id" => [nil, id.to_s] })
  end

  def is_revoke_self_request?(env)
    revoke_self_matcher.match?(env: env)
  end
end

# == Schema Information
#
# Table name: user_api_keys
#
#  id               :integer          not null, primary key
#  user_id          :integer          not null
#  client_id        :string           not null
#  application_name :string           not null
#  push_url         :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  revoked_at       :datetime
#  last_used_at     :datetime         not null
#  key_hash         :string           not null
#
# Indexes
#
#  index_user_api_keys_on_client_id  (client_id) UNIQUE
#  index_user_api_keys_on_key_hash   (key_hash) UNIQUE
#  index_user_api_keys_on_user_id    (user_id)
#
