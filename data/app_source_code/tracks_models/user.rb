require 'digest/sha1'
require 'bcrypt'

class User < ApplicationRecord
  # Virtual attribute for the unencrypted password
  attr_accessor :password

  cattr_accessor :per_page
  @@per_page = 25

  has_many(:contexts, -> { order 'position ASC' }, dependent: :delete_all) do
             def find_by_params(params)
               find(params['id'] || params['context_id']) || nil
             end

             def update_positions(context_ids)
               context_ids.each_with_index do |id, position|
                 context = detect { |c| c.id == id.to_i }
                 raise I18n.t('models.user.error_context_not_associated', :context => id, :user => @user.id) if context.nil?
                 context.update_attribute(:position, position + 1)
               end
             end
           end

  has_many(:projects, -> { order 'projects.position ASC' }, dependent: :delete_all) do
              def find_by_params(params)
                find(params['id'] || params['project_id'])
              end

              def update_positions(project_ids)
                project_ids.each_with_index do |id, position|
                  project = find_by(id: id.to_i)
                  raise I18n.t('models.user.error_project_not_associated', :project => id, :user => @user.id) if project.nil?
                  project.update_attribute(:position, position + 1)
                end
              end

              def projects_in_state_by_position(state)
                select { |p| p.state == state }.sort_by { |p| p.position }
              end

              def next_from(project)
                offset_from(project, 1)
              end

              def previous_from(project)
                offset_from(project, -1)
              end

              def offset_from(project, offset)
                projects = projects_in_state_by_position(project.state)
                position = projects.index(project)
                return nil if position == 0 && offset < 0
                projects.at(position + offset)
              end

              def cache_note_counts
                project_note_counts = Note.group(:project_id).count
                each do |project|
                  project.cached_note_count = project_note_counts[project.id] || 0
                end
              end

              def alphabetize(scope_conditions = {})
                projects = where(scope_conditions)
                projects = projects.sort_by { |project| project.name.downcase }
                update_positions(projects.map(&:id))
                return projects
              end

              def actionize(scope_conditions = {})
                todos_in_project = where(scope_conditions).includes(:todos)
                todos_in_project = todos_in_project.sort_by { |x| [-x.todos.active.count, -x.id] }
                todos_in_project.reject { |p| p.todos.active.count > 0 }
                sorted_project_ids = todos_in_project.map(&:id)

                all_project_ids = map(&:id)
                other_project_ids = all_project_ids - sorted_project_ids

                update_positions(sorted_project_ids + other_project_ids)

                return where(scope_conditions)
              end
            end

  has_many(:todos, -> { order 'todos.completed_at DESC, todos.created_at DESC' }, dependent: :delete_all) do
             def count_by_group(g)
               except(:order).group(g).count
             end
           end

  has_many :recurring_todos,
           -> { order 'recurring_todos.completed_at DESC, recurring_todos.created_at DESC' },
           dependent: :delete_all

  has_many(:deferred_todos,
           -> { where('state = ?', 'deferred')
                .order('show_from ASC, todos.created_at DESC') },
           :class_name => 'Todo') do
             def find_and_activate_ready
               where('show_from <= ?', Time.current).collect { |t| t.activate! }
             end
           end

  has_many :tags, dependent: :delete_all
  has_many :notes, -> { order "created_at DESC" }, dependent: :delete_all
  has_one :preference, dependent: :destroy
  has_many :attachments, through: :todos

  validates :login, presence: true, length: { within: 3..80 }
  validates_uniqueness_of :login, on: :create, :case_sensitive => false
  validates :password, presence: true, length: { within: 5..72 }, if: :password_required?
  validates :password_confirmation, presence: true, if: :password_required?
  validates :password, confirmation: true
  validates :email, allow_blank: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  validate :validate_auth_type

  before_create :crypt_password, :generate_token
  before_update :crypt_password
  # Run before deleting todos, projects, contexts, etc.
  before_destroy :destroy_dependencies, :delete_taggings, prepend: true

  def validate_auth_type
    unless Tracks::Config.auth_schemes.include?(auth_type)
      errors.add("auth_type", "not a valid authentication type (#{auth_type})")
    end
  end

  alias_method :prefs, :preference

  def self.authenticate(login, pass)
    return nil if login.blank?
    candidate = where("login = ?", login).first
    return nil if candidate.nil?

    if Tracks::Config.auth_schemes.include?('database')

      return candidate if (candidate.auth_type == 'database' && candidate.password_matches?(pass))
    end

    return nil
  end

  def self.no_users_yet?
    count == 0
  end

  def self.find_admin
    where(:is_admin => true).first
  end

  def to_param
    login
  end

  def display_name
    if first_name.blank? && last_name.blank?
      return login
    elsif first_name.blank?
      return last_name
    elsif last_name.blank?
      return first_name
    end
    "#{first_name} #{last_name}"
  end

  def change_password(pass, pass_confirm)
    self.password = pass
    self.password_confirmation = pass_confirm
    save!
  end

  def date
    Date.current
  end

  def generate_token
    self.token = Digest::SHA1.hexdigest "#{Time.zone.now.to_i}#{rand}"
  end

  def remember_token?
    remember_token_expires_at && Time.zone.now.utc < remember_token_expires_at
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    self.remember_token_expires_at = 2.weeks.from_now.utc
    self.remember_token ||= Digest::SHA1.hexdigest("#{login}--#{remember_token_expires_at}")
    save
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save
  end

  def password_matches?(pass)
    BCrypt::Password.new(crypted_password) == pass
  end

  def create_hash(s)
    BCrypt::Password.create(s)
  end

  protected

  def crypt_password
    return if password.blank?
    write_attribute("crypted_password", create_hash(password)) if password == password_confirmation
  end

  def password_required?
    auth_type == 'database' && crypted_password.blank? || password.present?
  end

  def destroy_dependencies
    ids = todos.pluck(:id)
    pred_deps = Dependency.where(predecessor_id: ids).destroy_all
    succ_deps = Dependency.where(predecessor_id: ids).destroy_all
  end

  def delete_taggings
    ids = todos.pluck(:id)
    taggings = Tagging.where(taggable_id: ids).pluck(:id)
    Tagging.where(id: taggings).delete_all
  end
end
