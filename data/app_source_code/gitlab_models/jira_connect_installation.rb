# frozen_string_literal: true

class JiraConnectInstallation < ApplicationRecord
  attr_encrypted :shared_secret,
                 mode: :per_attribute_iv,
                 algorithm: 'aes-256-gcm',
                 key: Settings.attr_encrypted_db_key_base_32

  has_many :subscriptions, class_name: 'JiraConnectSubscription'

  validates :client_key, presence: true, uniqueness: true
  validates :shared_secret, presence: true
  validates :base_url, presence: true, public_url: true
  validates :instance_url, public_url: true, allow_blank: true

  scope :for_project, -> (project) {
    distinct
      .joins(:subscriptions)
      .where(jira_connect_subscriptions: {
        id: JiraConnectSubscription.for_project(project)
      })
  }

  scope :direct_installations, -> { joins(:subscriptions) }
  scope :proxy_installations, -> { where.not(instance_url: nil) }

  def client
    Atlassian::JiraConnect::Client.new(base_url, shared_secret)
  end

  def oauth_authorization_url
    return Gitlab.config.gitlab.url if instance_url.blank? || Feature.disabled?(:jira_connect_oauth_self_managed)

    instance_url
  end

  def audience_url
    return unless proxy?

    Gitlab::Utils.append_path(instance_url, '/-/jira_connect')
  end

  def audience_installed_event_url
    return unless proxy?

    Gitlab::Utils.append_path(instance_url, '/-/jira_connect/events/installed')
  end

  def proxy?
    instance_url.present?
  end
end
