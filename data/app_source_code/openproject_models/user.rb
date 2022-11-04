#-- encoding: UTF-8

#-- copyright
# OpenProject is an open source project management software.
# Copyright (C) 2012-2021 the OpenProject GmbH
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See docs/COPYRIGHT.rdoc for more details.
#++

require 'digest/sha1'

class User < Principal
  USER_FORMATS_STRUCTURE = {
    firstname_lastname: %i[firstname lastname],
    firstname: [:firstname],
    lastname_firstname: %i[lastname firstname],
    lastname_coma_firstname: %i[lastname firstname],
    username: [:login]
  }.freeze

  include ::Associations::Groupable
  extend DeprecatedAlias

  has_many :categories, foreign_key: 'assigned_to_id',
                        dependent: :nullify
  has_many :watches, class_name: 'Watcher',
                     dependent: :delete_all
  has_many :changesets, dependent: :nullify
  has_many :passwords, -> {
    order('id DESC')
  }, class_name: 'UserPassword',
     dependent: :destroy,
     inverse_of: :user
  has_one :rss_token, class_name: '::Token::RSS', dependent: :destroy
  has_one :api_token, class_name: '::Token::API', dependent: :destroy
  belongs_to :auth_source

  # Authorized OAuth grants
  has_many :oauth_grants,
           class_name: 'Doorkeeper::AccessGrant',
           foreign_key: 'resource_owner_id'

  # User-defined oauth applications
  has_many :oauth_applications,
           class_name: 'Doorkeeper::Application',
           as: :owner

  has_many :notification_settings, dependent: :destroy

  # Users blocked via brute force prevention
  # use lambda here, so time is evaluated on each query
  scope :blocked, -> { create_blocked_scope(self, true) }
  scope :not_blocked, -> { create_blocked_scope(self, false) }

  scopes :find_by_login,
         :newest,
         :notified_on_all,
         :watcher_recipients

  def self.create_blocked_scope(scope, blocked)
    scope.where(blocked_condition(blocked))
  end

  def self.blocked_condition(blocked)
    block_duration = Setting.brute_force_block_minutes.to_i.minutes
    blocked_if_login_since = Time.now - block_duration
    negation = blocked ? '' : 'NOT'

    ["#{negation} (users.failed_login_count >= ? AND users.last_failed_login_on > ?)",
     Setting.brute_force_block_after_failed_logins.to_i,
     blocked_if_login_since]
  end

  acts_as_customizable

  attr_accessor :password, :password_confirmation, :last_before_login_on

  validates_presence_of :login,
                        :firstname,
                        :lastname,
                        :mail,
                        unless: Proc.new { |user| user.builtin? }

  validates_uniqueness_of :login, if: Proc.new { |user| !user.login.blank? }, case_sensitive: false
  validates_uniqueness_of :mail, allow_blank: true, case_sensitive: false
  # Login must contain letters, numbers, underscores only
  validates_format_of :login, with: /\A[a-z0-9_\-@.+ ]*\z/i
  validates_length_of :login, maximum: 256
  validates_length_of :firstname, :lastname, maximum: 256
  validates :mail, email: true, unless: Proc.new { |user| user.mail.blank? }
  validates_length_of :mail, maximum: 256, allow_nil: true
  validates_confirmation_of :password, allow_nil: true

  auto_strip_attributes :login, nullify: false
  auto_strip_attributes :mail, nullify: false

  validate :login_is_not_special_value
  validate :password_meets_requirements

  after_save :update_password

  scope :admin, -> { where(admin: true) }

  def self.unique_attribute
    :login
  end
  prepend ::Mixins::UniqueFinder

  def current_password
    passwords.first
  end

  def password_expired?
    current_password.expired?
  end

  # create new password if password was set
  def update_password
    if password && auth_source_id.blank?
      new_password = passwords.build(type: UserPassword.active_type.to_s)
      new_password.plain_password = password
      new_password.save

      # force reload of passwords, so the new password is sorted to the top
      passwords.reload

      clean_up_former_passwords
      clean_up_password_attribute
    end
  end

  def reload(*args)
    @name = nil
    @projects_by_role = nil
    @authorization_service = ::Authorization::UserAllowedService.new(self)
    @project_role_cache = ::Users::ProjectRoleCache.new(self)

    super
  end

  def mail=(arg)
    write_attribute(:mail, arg.to_s.strip)
  end

  def self.search_in_project(query, options)
    options.fetch(:project).users.like(query)
  end

  # Returns the user that matches provided login and password, or nil
  def self.try_to_login(login, password, session = nil)
    # Make sure no one can sign in with an empty password
    return nil if password.to_s.empty?

    user = find_by_login(login)
    user = if user
             try_authentication_for_existing_user(user, password, session)
           else
             try_authentication_and_create_user(login, password)
           end
    unless prevent_brute_force_attack(user, login).nil?
      user.log_successful_login if user && !user.new_record?
      return user
    end
    nil
  end

  # Tries to authenticate a user in the database via external auth source
  # or password stored in the database
  def self.try_authentication_for_existing_user(user, password, session = nil)
    activate_user! user, session if session

    return nil if !user.active? || OpenProject::Configuration.disable_password_login?

    if user.auth_source
      # user has an external authentication method
      return nil unless user.auth_source.authenticate(user.login, password)
    else
      # authentication with local password
      return nil unless user.check_password?(password)
      return nil if user.force_password_change
      return nil if user.password_expired?
    end
    user
  end

  def self.activate_user!(user, session)
    if session[:invitation_token]
      token = Token::Invitation.find_by_plaintext_value session[:invitation_token]
      invited_id = token&.user&.id

      if user.id == invited_id
        user.activate!
        token.destroy
        session.delete :invitation_token
      end
    end
  end

  # Tries to authenticate with available sources and creates user on success
  def self.try_authentication_and_create_user(login, password)
    return nil if OpenProject::Configuration.disable_password_login?

    attrs = AuthSource.authenticate(login, password)
    try_to_create(attrs) if attrs
  end

  # Try to create the user from attributes
  def self.try_to_create(attrs, notify: false)
    new(attrs).tap do |user|
      user.language = Setting.default_language

      if OpenProject::Enterprise.user_limit_reached?
        OpenProject::Enterprise.send_activation_limit_notification_about(user) if notify

        Rails.logger.error("User '#{user.login}' could not be created as user limit exceeded.")
        user.errors.add :base, I18n.t(:error_enterprise_activation_user_limit)
      elsif user.save
        user.reload
        Rails.logger.info("User '#{user.login}' created from external auth source: #{user.auth_source&.type} - #{user.auth_source&.name}")
      else
        Rails.logger.error("User '#{user.login}' could not be created: #{user.errors.full_messages.join('. ')}")
      end
    end
  end

  # Returns the user who matches the given autologin +key+ or nil
  def self.try_to_autologin(key)
    token = Token::AutoLogin.find_by_plaintext_value(key)
    # Make sure there's only 1 token that matches the key
    if token && ((token.created_at > Setting.autologin.to_i.day.ago) && token.user && token.user.active?)
      token.user.log_successful_login
      token.user
    end
  end

  # Formats the user's name.
  def name(formatter = nil)
    case formatter || Setting.user_format

    when :firstname_lastname      then "#{firstname} #{lastname}"
    when :lastname_firstname      then "#{lastname} #{firstname}"
    when :lastname_coma_firstname then "#{lastname}, #{firstname}"
    when :firstname               then firstname
    when :username                then login

    else
      "#{firstname} #{lastname}"
    end
  end

  # Return user's authentication provider for display
  def authentication_provider
    return if identity_url.blank?

    identity_url.split(':', 2).first.titleize
  end

  ##
  # Allows the API and other sources to determine locking actions
  # on represented collections of children of Principals.
  # This only covers the transition from:
  # lockable?: active -> locked.
  # activatable?: locked -> active.
  alias_method :lockable?, :active?
  alias_method :activatable?, :locked?

  def activate
    self.status = self.class.statuses[:active]
  end

  def register
    self.status = self.class.statuses[:registered]
  end

  def invite
    self.status = self.class.statuses[:invited]
  end

  def lock
    self.status = self.class.statuses[:locked]
  end

  deprecated_alias :activate!, :active!
  deprecated_alias :register!, :registered!
  deprecated_alias :invite!, :invited!
  deprecated_alias :lock!, :locked!

  # Returns true if +clear_password+ is the correct user's password, otherwise false
  # If +update_legacy+ is set, will automatically save legacy passwords using the current
  # format.
  def check_password?(clear_password, update_legacy: true)
    if auth_source_id.present?
      auth_source.authenticate(login, clear_password)
    else
      return false if current_password.nil?

      current_password.matches_plaintext?(clear_password, update_legacy: update_legacy)
    end
  end

  # Does the backend storage allow this user to change their password?
  def change_password_allowed?
    return false if uses_external_authentication? ||
                    OpenProject::Configuration.disable_password_login?
    return true if auth_source_id.blank?

    auth_source.allow_password_changes?
  end

  # Is the user authenticated via an external authentication source via OmniAuth?
  def uses_external_authentication?
    identity_url.present?
  end

  #
  # Generate and set a random password.
  #
  # Also force a password change on the next login, since random passwords
  # are at some point given to the user, we do this via email. These passwords
  # are stored unencrypted in mail accounts, so they must only be valid for
  # a short time.
  def random_password!
    self.password = OpenProject::Passwords::Generator.random_password
    self.password_confirmation = password
    self.force_password_change = true
    self
  end

  ##
  # Brute force prevention - public instance methods
  #
  def failed_too_many_recent_login_attempts?
    block_threshold = Setting.brute_force_block_after_failed_logins.to_i
    return false if block_threshold == 0 # disabled

    (last_failed_login_within_block_time? and
            failed_login_count >= block_threshold)
  end

  def log_failed_login
    log_failed_login_count
    log_failed_login_timestamp
    save
  end

  def log_successful_login
    update_attribute(:last_login_on, Time.now)
  end

  def pref
    preference || build_preference
  end

  def time_zone
    @time_zone ||= (pref.time_zone.blank? ? nil : ActiveSupport::TimeZone[pref.time_zone])
  end

  def wants_comments_in_reverse_order?
    pref.comments_in_reverse_order?
  end

  # Find a user account by matching the exact login and then a case-insensitive
  # version.  Exact matches will be given priority.
  def self.find_by_login(login)
    # First look for an exact match
    user = find_by(login: login)
    # Fail over to case-insensitive if none was found
    user || where(["LOWER(login) = ?", login.to_s.downcase]).first
  end

  def self.find_by_rss_key(key)
    return nil unless Setting.feeds_enabled?

    token = Token::RSS.find_by(value: key)

    if token&.user&.active?
      token.user
    end
  end

  def self.find_by_api_key(key)
    return nil unless Setting.rest_api_enabled?

    token = Token::API.find_by_plaintext_value(key)

    if token&.user&.active?
      token.user
    end
  end

  ##
  # Finds all users with the mail address matching the given mail
  # Includes searching for suffixes from +Setting.mail_suffix_separtors+.
  #
  # For example:
  #  - With Setting.mail_suffix_separators = '+'
  #  - Will find 'foo+bar@example.org' with input of 'foo@example.org'
  def self.where_mail_with_suffix(mail)
    skip_suffix_check, regexp = mail_regexp(mail)

    # If the recipient part already contains a suffix, don't expand
    if skip_suffix_check
      where("LOWER(mail) = ?", mail)
    else
      where("LOWER(mail) ~* ?", regexp)
    end
  end

  ##
  # Finds a user by mail where it checks whether the mail exists
  # NOTE: This will return the FIRST matching user.
  def self.find_by_mail(mail)
    where_mail_with_suffix(mail).first
  end

  def rss_key
    token = rss_token || ::Token::RSS.create(user: self)
    token.value
  end

  def to_s
    name
  end

  # Returns the current day according to user's time zone
  def today
    if time_zone.nil?
      Date.today
    else
      Time.now.in_time_zone(time_zone).to_date
    end
  end

  def logged?
    true
  end

  def anonymous?
    !logged?
  end

  # Return user's roles for project
  def roles_for_project(project)
    project_role_cache.fetch(project)
  end
  alias :roles :roles_for_project

  # Cheap version of Project.visible.count
  def number_of_known_projects
    if admin?
      Project.count
    else
      Project.public_projects.count + memberships.size
    end
  end

  # Return true if the user is a member of project
  def member_of?(project)
    roles_for_project(project).any?(&:member?)
  end

  # Returns a hash of user's projects grouped by roles
  def projects_by_role
    return @projects_by_role if @projects_by_role

    @projects_by_role = Hash.new { |h, k| h[k] = [] }
    memberships.each do |membership|
      membership.roles.each do |role|
        @projects_by_role[role] << membership.project if membership.project
      end
    end
    @projects_by_role.each do |_role, projects|
      projects.uniq!
    end

    @projects_by_role
  end

  # Returns true if user is arg or belongs to arg
  def is_or_belongs_to?(arg)
    if arg.is_a?(User)
      self == arg
    elsif arg.is_a?(Group)
      arg.users.include?(self)
    else
      false
    end
  end

  def self.allowed(action, project)
    Authorization.users(action, project)
  end

  def self.allowed_members(action, project)
    Authorization.users(action, project).where.not(members: { id: nil })
  end

  def allowed_to?(action, context, options = {})
    authorization_service.call(action, context, options).result
  end

  def allowed_to_in_project?(action, project, options = {})
    authorization_service.call(action, project, options).result
  end

  def allowed_to_globally?(action, options = {})
    authorization_service.call(action, nil, options.merge(global: true)).result
  end

  def preload_projects_allowed_to(action)
    authorization_service.preload_projects_allowed_to(action)
  end

  def reported_work_package_count
    WorkPackage.on_active_project.with_author(self).visible.count
  end

  def self.current=(user)
    RequestStore[:current_user] = user
  end

  def self.current
    RequestStore[:current_user] || User.anonymous
  end

  def self.execute_as(user, &block)
    previous_user = User.current
    User.current = user
    OpenProject::LocaleHelper.with_locale_for(user, &block)
  ensure
    User.current = previous_user
  end

  ##
  # Returns true if no authentication method has been chosen for this user yet.
  # There are three possible methods currently:
  #
  #   - username & password
  #   - OmniAuth
  #   - LDAP
  def missing_authentication_method?
    identity_url.nil? && passwords.empty? && auth_source.nil?
  end

  # Returns the anonymous user.  If the anonymous user does not exist, it is created.  There can be only
  # one anonymous user per database.
  def self.anonymous
    RequestStore[:anonymous_user] ||= begin
      anonymous_user = AnonymousUser.first

      if anonymous_user.nil?
        (anonymous_user = AnonymousUser.new.tap do |u|
          u.lastname = 'Anonymous'
          u.login = ''
          u.firstname = ''
          u.mail = ''
          u.status = User.statuses[:active]
        end).save
        raise 'Unable to create the anonymous user.' if anonymous_user.new_record?
      end
      anonymous_user
    end
  end

  def self.system
    system_user = SystemUser.first

    if system_user.nil?
      system_user = SystemUser.new(
        firstname: "",
        lastname: "System",
        login: "",
        mail: "",
        admin: true,
        status: User.statuses[:active],
        first_login: false
      )

      system_user.save(validate: false)

      raise 'Unable to create the automatic migration user.' unless system_user.persisted?
    end

    system_user
  end

  protected

  # Login must not be special value 'me'
  def login_is_not_special_value
    if login.present? && login == 'me'
      errors.add(:login, :invalid)
    end
  end

  # Password requirement validation based on settings
  def password_meets_requirements
    # Passwords are stored hashed as UserPasswords,
    # self.password is only set when it was changed after the last
    # save. Otherwise, password is nil.
    unless password.nil? or anonymous?
      password_errors = OpenProject::Passwords::Evaluator.errors_for_password(password)
      password_errors.each { |error| errors.add(:password, error) }

      if former_passwords_include?(password)
        errors.add(:password,
                   I18n.t(:reused,
                          count: Setting[:password_count_former_banned].to_i,
                          scope: %i[activerecord
                                    errors
                                    models
                                    user
                                    attributes
                                    password]))
      end
    end
  end

  private

  def self.mail_regexp(mail)
    separators = Regexp.escape(Setting.mail_suffix_separators)
    recipient, domain = mail.split('@').map { |part| Regexp.escape(part) }
    skip_suffix_check = recipient.nil? || Setting.mail_suffix_separators.empty? || recipient.match?(/.+[#{separators}].+/)
    regexp = "#{recipient}([#{separators}][^@]+)*@#{domain}"

    [skip_suffix_check, regexp]
  end

  def authorization_service
    @authorization_service ||= ::Authorization::UserAllowedService.new(self, role_cache: project_role_cache)
  end

  def project_role_cache
    @project_role_cache ||= ::Users::ProjectRoleCache.new(self)
  end

  def former_passwords_include?(password)
    return false if Setting[:password_count_former_banned].to_i == 0

    ban_count = Setting[:password_count_former_banned].to_i
    # make reducing the number of banned former passwords immediately effective
    # by only checking this number of former passwords
    passwords[0, ban_count].any? { |f| f.matches_plaintext?(password) }
  end

  def clean_up_former_passwords
    # minimum 1 to keep the actual user password
    keep_count = [1, Setting[:password_count_former_banned].to_i].max
    (passwords[keep_count..-1] || []).each(&:destroy)
  end

  def clean_up_password_attribute
    self.password = self.password_confirmation = nil
  end

  ##
  # Brute force prevention - class methods
  #
  def self.prevent_brute_force_attack(user, login)
    if user.nil?
      register_failed_login_attempt_if_user_exists_for(login)
    else
      block_user_if_too_many_recent_attempts_failed(user)
    end
  end

  def self.register_failed_login_attempt_if_user_exists_for(login)
    user = User.find_by_login(login)
    user.log_failed_login if user.present?
    nil
  end

  def self.reset_failed_login_count_for(user)
    user.update_attribute(:failed_login_count, 0) unless user.new_record?
  end

  def self.block_user_if_too_many_recent_attempts_failed(user)
    if user.failed_too_many_recent_login_attempts?
      user = nil
    else
      reset_failed_login_count_for user
    end

    user
  end

  ##
  # Brute force prevention - instance methods
  #
  def last_failed_login_within_block_time?
    block_duration = Setting.brute_force_block_minutes.to_i.minutes
    last_failed_login_on and
      Time.now - last_failed_login_on < block_duration
  end

  def log_failed_login_count
    if last_failed_login_within_block_time?
      self.failed_login_count += 1
    else
      self.failed_login_count = 1
    end
  end

  def log_failed_login_timestamp
    self.last_failed_login_on = Time.now
  end

  def self.default_admin_account_changed?
    !User.active.find_by_login('admin').try(:current_password).try(:matches_plaintext?, 'admin')
  end
end
