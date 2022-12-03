# frozen_string_literal: true

require_dependency 'global_path'
require 'csv'
require 'json_schemer'

class Theme < ActiveRecord::Base
  include GlobalPath

  attr_accessor :child_components

  @cache = DistributedCache.new('theme')

  belongs_to :user
  belongs_to :color_scheme
  has_many :theme_fields, dependent: :destroy
  has_many :theme_settings, dependent: :destroy
  has_many :theme_translation_overrides, dependent: :destroy
  has_many :child_theme_relation, class_name: 'ChildTheme', foreign_key: 'parent_theme_id', dependent: :destroy
  has_many :parent_theme_relation, class_name: 'ChildTheme', foreign_key: 'child_theme_id', dependent: :destroy
  has_many :child_themes, -> { order(:name) }, through: :child_theme_relation, source: :child_theme
  has_many :parent_themes, -> { order(:name) }, through: :parent_theme_relation, source: :parent_theme
  has_many :color_schemes
  belongs_to :remote_theme, dependent: :destroy
  has_one :theme_modifier_set, dependent: :destroy

  has_one :settings_field, -> { where(target_id: Theme.targets[:settings], name: "yaml") }, class_name: 'ThemeField'
  has_one :javascript_cache, dependent: :destroy
  has_many :locale_fields, -> { filter_locale_fields(I18n.fallbacks[I18n.locale]) }, class_name: 'ThemeField'
  has_many :upload_fields, -> { where(type_id: ThemeField.types[:theme_upload_var]).preload(:upload) }, class_name: 'ThemeField'
  has_many :extra_scss_fields, -> { where(target_id: Theme.targets[:extra_scss]) }, class_name: 'ThemeField'
  has_many :yaml_theme_fields, -> { where("name = 'yaml' AND type_id = ?", ThemeField.types[:yaml]) }, class_name: 'ThemeField'
  has_many :var_theme_fields, -> { where("type_id IN (?)", ThemeField.theme_var_type_ids) }, class_name: 'ThemeField'
  has_many :builder_theme_fields, -> { where("name IN (?)", ThemeField.scss_fields) }, class_name: 'ThemeField'

  validate :component_validations

  after_create :update_child_components

  scope :user_selectable, ->() {
    where('user_selectable OR id = ?', SiteSetting.default_theme_id)
  }

  scope :include_relations, -> {
    includes(:child_themes,
      :parent_themes,
      :remote_theme,
      :theme_settings,
      :settings_field,
      :locale_fields,
      :user,
      :color_scheme,
      theme_fields: :upload
    )
  }

  def notify_color_change(color, scheme: nil)
    scheme ||= color.color_scheme
    changed_colors << color if color
    changed_schemes << scheme if scheme
  end

  def theme_modifier_set
    super || build_theme_modifier_set
  end

  after_save do
    changed_colors.each(&:save!)
    changed_schemes.each(&:save!)

    changed_colors.clear
    changed_schemes.clear

    changed_fields.each(&:save!)
    changed_fields.clear

    theme_modifier_set.save!

    if saved_change_to_name?
      theme_fields.select(&:basic_html_field?).each(&:invalidate_baked!)
    end

    Theme.expire_site_cache! if saved_change_to_color_scheme_id? || saved_change_to_user_selectable? || saved_change_to_name?
    notify_with_scheme = saved_change_to_color_scheme_id?

    reload
    settings_field&.ensure_baked! # Other fields require setting to be **baked**
    theme_fields.each(&:ensure_baked!)

    update_javascript_cache!

    remove_from_cache!
    clear_cached_settings!
    DB.after_commit { ColorScheme.hex_cache.clear }
    notify_theme_change(with_scheme: notify_with_scheme)
  end

  def update_child_components
    if !component? && child_components.present?
      child_components.each do |url|
        url = ThemeStore::GitImporter.new(url.strip).url
        theme = RemoteTheme.find_by(remote_url: url)&.theme
        theme ||= RemoteTheme.import_theme(url, user)
        child_themes << theme
      end
    end
  end

  def update_javascript_cache!
    all_extra_js = theme_fields.where(target_id: Theme.targets[:extra_js]).pluck(:value_baked).join("\n")
    if all_extra_js.present?
      js_compiler = ThemeJavascriptCompiler.new(id, name)
      js_compiler.append_raw_script(all_extra_js)
      settings_hash = build_settings_hash
      js_compiler.prepend_settings(settings_hash) if settings_hash.present?
      javascript_cache || build_javascript_cache
      javascript_cache.update!(content: js_compiler.content)
    else
      javascript_cache&.destroy!
    end
  end

  after_destroy do
    remove_from_cache!
    clear_cached_settings!
    if SiteSetting.default_theme_id == self.id
      Theme.clear_default!
    end

    if self.id
      ColorScheme
        .where(theme_id: self.id)
        .where("id NOT IN (SELECT color_scheme_id FROM themes where color_scheme_id IS NOT NULL)")
        .destroy_all

      ColorScheme
        .where(theme_id: self.id)
        .update_all(theme_id: nil)
    end

    Theme.expire_site_cache!
    ColorScheme.hex_cache.clear
    CSP::Extension.clear_theme_extensions_cache!
    SvgSprite.expire_cache
  end

  BASE_COMPILER_VERSION = 51
  def self.compiler_version
    get_set_cache "compiler_version" do
      dependencies = [
        BASE_COMPILER_VERSION,
        Ember::VERSION,
        GlobalSetting.cdn_url,
        Discourse.current_hostname
      ]
      Digest::SHA1.hexdigest(dependencies.join)
    end
  end

  def self.get_set_cache(key, &blk)
    @cache.defer_get_set(key, &blk)
  end

  def self.theme_ids
    get_set_cache "theme_ids" do
      Theme.pluck(:id)
    end
  end

  def self.parent_theme_ids
    get_set_cache "parent_theme_ids" do
      Theme.where(component: false).pluck(:id)
    end
  end

  def self.is_parent_theme?(id)
    self.parent_theme_ids.include?(id)
  end

  def self.user_theme_ids
    get_set_cache "user_theme_ids" do
      Theme.user_selectable.pluck(:id)
    end
  end

  def self.components_for(theme_id)
    get_set_cache "theme_components_for_#{theme_id}" do
      ChildTheme.where(parent_theme_id: theme_id).pluck(:child_theme_id)
    end
  end

  def self.expire_site_cache!
    Site.clear_anon_cache!
    clear_cache!
    ApplicationSerializer.expire_cache_fragment!("user_themes")
    ColorScheme.hex_cache.clear
  end

  def self.clear_default!
    SiteSetting.default_theme_id = -1
    expire_site_cache!
  end

  def self.transform_ids(id)
    return [] if id.blank?
    id = id.to_i

    get_set_cache "transformed_ids_#{id}" do
      all_ids =
        if self.is_parent_theme?(id)
          components = components_for(id).tap { |c| c.sort!.uniq! }
          [id, *components]
        else
          [id]
        end

      disabled_ids = Theme.where(id: all_ids)
        .includes(:remote_theme)
        .select { |t| !t.supported? || !t.enabled? }
        .map(&:id)

      all_ids - disabled_ids
    end
  end

  def set_default!
    if component
      raise Discourse::InvalidParameters.new(
        I18n.t("themes.errors.component_no_default")
      )
    end
    SiteSetting.default_theme_id = id
    Theme.expire_site_cache!
  end

  def default?
    SiteSetting.default_theme_id == id
  end

  def supported?
    if minimum_version = remote_theme&.minimum_discourse_version
      return false unless Discourse.has_needed_version?(Discourse::VERSION::STRING, minimum_version)
    end

    if maximum_version = remote_theme&.maximum_discourse_version
      return false unless Discourse.has_needed_version?(maximum_version, Discourse::VERSION::STRING)
    end

    true
  end

  def component_validations
    return unless component

    errors.add(:base, I18n.t("themes.errors.component_no_color_scheme")) if color_scheme_id.present?
    errors.add(:base, I18n.t("themes.errors.component_no_user_selectable")) if user_selectable
    errors.add(:base, I18n.t("themes.errors.component_no_default")) if default?
  end

  def switch_to_component!
    return if component

    Theme.transaction do
      self.component = true

      self.color_scheme_id = nil
      self.user_selectable = false
      Theme.clear_default! if default?

      ChildTheme.where("parent_theme_id = ?", id).destroy_all
      self.save!
    end
  end

  def switch_to_theme!
    return unless component

    Theme.transaction do
      self.enabled = true
      self.component = false
      ChildTheme.where("child_theme_id = ?", id).destroy_all
      self.save!
    end
  end

  def self.lookup_field(theme_id, target, field, skip_transformation: false)
    return "" if theme_id.blank?

    theme_ids = !skip_transformation ? transform_ids(theme_id) : [theme_id]
    cache_key = "#{theme_ids.join(",")}:#{target}:#{field}:#{Theme.compiler_version}"
    lookup = @cache[cache_key]
    return lookup.html_safe if lookup

    target = target.to_sym
    val = resolve_baked_field(theme_ids, target, field)

    get_set_cache(cache_key) { val || "" }.html_safe
  end

  def self.lookup_modifier(theme_ids, modifier_name)
    theme_ids = [theme_ids] unless theme_ids.is_a?(Array)

    get_set_cache("#{theme_ids.join(",")}:modifier:#{modifier_name}:#{Theme.compiler_version}") do
      ThemeModifierSet.resolve_modifier_for_themes(theme_ids, modifier_name)
    end
  end

  def self.remove_from_cache!
    clear_cache!
  end

  def self.clear_cache!
    DB.after_commit do
      @cache.clear
    end
  end

  def self.targets
    @targets ||= Enum.new(common: 0, desktop: 1, mobile: 2, settings: 3, translations: 4, extra_scss: 5, extra_js: 6, tests_js: 7)
  end

  def self.lookup_target(target_id)
    self.targets.invert[target_id]
  end

  def self.notify_theme_change(theme_ids, with_scheme: false, clear_manager_cache: true, all_themes: false)
    Stylesheet::Manager.clear_theme_cache!
    targets = [:mobile_theme, :desktop_theme]

    if with_scheme
      targets.prepend(:desktop, :mobile, :admin)
      targets.append(*Discourse.find_plugin_css_assets(mobile_view: true, desktop_view: true))
      Stylesheet::Manager.cache.clear if clear_manager_cache
    end

    if all_themes
      message = theme_ids.map { |id| refresh_message_for_targets(targets, id) }.flatten
    else
      message = refresh_message_for_targets(targets, theme_ids).flatten
    end

    MessageBus.publish('/file-change', message)
  end

  def notify_theme_change(with_scheme: false)
    DB.after_commit do
      theme_ids = Theme.transform_ids(id)
      self.class.notify_theme_change(theme_ids, with_scheme: with_scheme)
    end
  end

  def self.refresh_message_for_targets(targets, theme_ids)
    theme_ids = [theme_ids] unless theme_ids.is_a?(Array)

    targets.each_with_object([]) do |target, data|
      theme_ids.each do |theme_id|
        data << Stylesheet::Manager.new(theme_id: theme_id).stylesheet_data(target.to_sym)
      end
    end
  end

  def self.resolve_baked_field(theme_ids, target, name)
    if target == :extra_js
      require_rebake = ThemeField.where(theme_id: theme_ids, target_id: Theme.targets[:extra_js]).
        where("compiler_version <> ?", Theme.compiler_version)
      require_rebake.each { |tf| tf.ensure_baked! }
      require_rebake.map(&:theme_id).uniq.each do |theme_id|
        Theme.find(theme_id).update_javascript_cache!
      end
      caches = JavascriptCache.where(theme_id: theme_ids)
      caches = caches.sort_by { |cache| theme_ids.index(cache.theme_id) }
      return caches.map { |c| "<script src='#{c.url}'></script>" }.join("\n")
    end
    list_baked_fields(theme_ids, target, name).map { |f| f.value_baked || f.value }.join("\n")
  end

  def self.list_baked_fields(theme_ids, target, name)
    target = target.to_sym
    name = name&.to_sym

    if target == :translations
      fields = ThemeField.find_first_locale_fields(theme_ids, I18n.fallbacks[name])
    else
      target = :mobile if target == :mobile_theme
      target = :desktop if target == :desktop_theme
      fields = ThemeField.find_by_theme_ids(theme_ids)
        .where(target_id: [Theme.targets[target], Theme.targets[:common]])
      fields = fields.where(name: name.to_s) unless name.nil?
      fields = fields.order(:target_id)
    end

    fields.each(&:ensure_baked!)
    fields
  end

  def resolve_baked_field(target, name)
    list_baked_fields(target, name).map { |f| f.value_baked || f.value }.join("\n")
  end

  def list_baked_fields(target, name)
    theme_ids = Theme.transform_ids(id)
    theme_ids = [theme_ids.first] if name != :color_definitions
    self.class.list_baked_fields(theme_ids, target, name)
  end

  def remove_from_cache!
    self.class.remove_from_cache!
  end

  def changed_fields
    @changed_fields ||= []
  end

  def changed_colors
    @changed_colors ||= []
  end

  def changed_schemes
    @changed_schemes ||= Set.new
  end

  def set_field(target:, name:, value: nil, type: nil, type_id: nil, upload_id: nil)
    name = name.to_s

    target_id = Theme.targets[target.to_sym]
    raise "Unknown target #{target} passed to set field" unless target_id

    type_id ||= type ? ThemeField.types[type.to_sym] : ThemeField.guess_type(name: name, target: target)
    raise "Unknown type #{type} passed to set field" unless type_id

    value ||= ""

    field = theme_fields.find { |f| f.name == name && f.target_id == target_id && f.type_id == type_id }
    if field
      if value.blank? && !upload_id
        theme_fields.delete field.destroy
      else
        if field.value != value || field.upload_id != upload_id
          field.value = value
          field.upload_id = upload_id
          changed_fields << field
        end
      end
      field
    else
      theme_fields.build(target_id: target_id, value: value, name: name, type_id: type_id, upload_id: upload_id) if value.present? || upload_id.present?
    end
  end

  def all_theme_variables
    fields = {}
    ids = Theme.transform_ids(id)
    ThemeField.find_by_theme_ids(ids).where(type_id: ThemeField.theme_var_type_ids).each do |field|
      next if fields.key?(field.name)
      fields[field.name] = field
    end
    fields.values
  end

  def add_relative_theme!(kind, theme)
    new_relation = if kind == :child
      child_theme_relation.new(child_theme_id: theme.id)
    else
      parent_theme_relation.new(parent_theme_id: theme.id)
    end
    if new_relation.save
      child_themes.reload
      parent_themes.reload
      save!
      Theme.clear_cache!
    else
      raise Discourse::InvalidParameters.new(new_relation.errors.full_messages.join(", "))
    end
  end

  def internal_translations
    @internal_translations ||= translations(internal: true)
  end

  def translations(internal: false)
    fallbacks = I18n.fallbacks[I18n.locale]
    begin
      data = locale_fields.first&.translation_data(with_overrides: false, internal: internal, fallback_fields: locale_fields)
      return {} if data.nil?
      best_translations = {}
      fallbacks.reverse.each do |locale|
        best_translations.deep_merge! data[locale] if data[locale]
      end
      ThemeTranslationManager.list_from_hash(theme: self, hash: best_translations, locale: I18n.locale)
    rescue ThemeTranslationParser::InvalidYaml
      {}
    end
  end

  def settings
    field = settings_field
    return [] unless field && field.error.nil?

    settings = []
    ThemeSettingsParser.new(field).load do |name, default, type, opts|
      settings << ThemeSettingsManager.create(name, default, type, self, opts)
    end
    settings
  end

  def cached_settings
    Discourse.cache.fetch("settings_for_theme_#{self.id}", expires_in: 30.minutes) do
      build_settings_hash
    end
  end

  def cached_default_settings
    Discourse.cache.fetch("default_settings_for_theme_#{self.id}", expires_in: 30.minutes) do
      settings_hash = {}
      self.settings.each do |setting|
        settings_hash[setting.name] = setting.default
      end
      settings_hash
    end
  end

  def build_settings_hash
    hash = {}
    self.settings.each do |setting|
      hash[setting.name] = setting.value
    end

    theme_uploads = {}
    upload_fields.each do |field|
      if field.upload&.url
        theme_uploads[field.name] = Discourse.store.cdn_url(field.upload.url)
      end
    end
    hash['theme_uploads'] = theme_uploads if theme_uploads.present?

    hash
  end

  def clear_cached_settings!
    DB.after_commit do
      Discourse.cache.delete("settings_for_theme_#{self.id}")
      Discourse.cache.delete("default_settings_for_theme_#{self.id}")
    end
  end

  def included_settings
    hash = {}

    Theme.where(id: Theme.transform_ids(id)).each do |theme|
      hash.merge!(theme.cached_settings)
    end

    hash.merge!(self.cached_settings)
    hash
  end

  def update_setting(setting_name, new_value)
    target_setting = settings.find { |setting| setting.name == setting_name }
    raise Discourse::NotFound unless target_setting

    target_setting.value = new_value
  end

  def update_translation(translation_key, new_value)
    target_translation = translations.find { |translation| translation.key == translation_key }
    raise Discourse::NotFound unless target_translation
    target_translation.value = new_value
  end

  def translation_override_hash
    hash = {}
    theme_translation_overrides.each do |override|
      cursor = hash
      path = [override.locale] + override.translation_key.split(".")
      path[0..-2].each do |key|
        cursor = (cursor[key] ||= {})
      end
      cursor[path[-1]] = override.value
    end
    hash
  end

  def generate_metadata_hash
    {}.tap do |meta|
      meta[:name] = name
      meta[:component] = component

      RemoteTheme::METADATA_PROPERTIES.each do |property|
        meta[property] = remote_theme&.public_send(property)
        meta[property] = nil if meta[property] == "URL" # Clean up old discourse_theme CLI placeholders
      end

      meta[:assets] = {}.tap do |hash|
        theme_fields.where(type_id: ThemeField.types[:theme_upload_var]).each do |field|
          hash[field.name] = field.file_path
        end
      end

      meta[:color_schemes] = {}.tap do |hash|
        schemes = self.color_schemes
        # The selected color scheme may not belong to the theme, so include it anyway
        schemes = [self.color_scheme] + schemes if self.color_scheme
        schemes.uniq.each do |scheme|
          hash[scheme.name] = {}.tap { |colors| scheme.colors.each { |color| colors[color.name] = color.hex } }
        end
      end

      meta[:modifiers] = {}.tap do |hash|
        ThemeModifierSet.modifiers.keys.each do |modifier|
          value = self.theme_modifier_set.public_send(modifier)
          hash[modifier] = value if !value.nil?
        end
      end

      meta[:learn_more] = "https://meta.discourse.org/t/beginners-guide-to-using-discourse-themes/91966"

    end
  end

  def disabled_by
    find_disable_action_log&.acting_user
  end

  def disabled_at
    find_disable_action_log&.created_at
  end

  def with_scss_load_paths
    return yield([]) if self.extra_scss_fields.empty?

    ThemeStore::ZipExporter.new(self).with_export_dir(extra_scss_only: true) do |dir|
      yield ["#{dir}/stylesheets"]
    end
  end

  def scss_variables
    return if all_theme_variables.empty? && included_settings.empty?

    contents = +""

    all_theme_variables&.each do |field|
      if field.type_id == ThemeField.types[:theme_upload_var]
        if upload = field.upload
          url = upload_cdn_path(upload.url)
          contents << "$#{field.name}: unquote(\"#{url}\");"
        end
      else
        contents << to_scss_variable(field.name, field.value)
      end
    end

    included_settings&.each do |name, value|
      next if name == "theme_uploads"
      contents << to_scss_variable(name, value)
    end

    contents
  end

  def convert_settings
    settings.each do |setting|
      setting_row = ThemeSetting.where(theme_id: self.id, name: setting.name.to_s).first

      if setting_row && setting_row.data_type != setting.type
        if (setting_row.data_type == ThemeSetting.types[:list] &&
          setting.type == ThemeSetting.types[:string] &&
          setting.json_schema.present?)
          convert_list_to_json_schema(setting_row, setting)
        else
          Rails.logger.warn("Theme setting type has changed but cannot be converted. \n\n #{setting.inspect}")
        end
      end
    end
  end

  def convert_list_to_json_schema(setting_row, setting)
    schema = setting.json_schema
    return if !schema
    keys = schema["items"]["properties"].keys
    return if !keys

    current_values = CSV.parse(setting_row.value, { col_sep: '|' }).flatten
    new_values = []
    current_values.each do |item|
      parts = CSV.parse(item, { col_sep: ',' }).flatten
      props = parts.map.with_index { |p, idx| [keys[idx], p] }.to_h
      new_values << props
    end

    schemer = JSONSchemer.schema(schema)
    raise "Schema validation failed" if !schemer.valid?(new_values)

    setting_row.value = new_values.to_json
    setting_row.data_type = setting.type
    setting_row.save!
  end

  def baked_js_tests_with_digest
    content = theme_fields
      .where(target_id: Theme.targets[:tests_js])
      .each(&:ensure_baked!)
      .map(&:value_baked)
      .join("\n")

    return [nil, nil] if content.blank?

    content = <<~JS + content
      (function() {
        require("discourse/lib/theme-settings-store").registerSettings(#{self.id}, #{cached_default_settings.to_json}, { force: true });
      })();
    JS
    [content, Digest::SHA1.hexdigest(content)]
  end

  private

  def to_scss_variable(name, value)
    escaped = SassC::Script::Value::String.quote(value, sass: true)
    "$#{name}: unquote(#{escaped});"
  end

  def find_disable_action_log
    if component? && !enabled?
      @disable_log ||= UserHistory.where(context: id.to_s, action: UserHistory.actions[:disable_theme_component]).order("created_at DESC").first
    end
  end
end

# == Schema Information
#
# Table name: themes
#
#  id               :integer          not null, primary key
#  name             :string           not null
#  user_id          :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  compiler_version :integer          default(0), not null
#  user_selectable  :boolean          default(FALSE), not null
#  hidden           :boolean          default(FALSE), not null
#  color_scheme_id  :integer
#  remote_theme_id  :integer
#  component        :boolean          default(FALSE), not null
#  enabled          :boolean          default(TRUE), not null
#  auto_update      :boolean          default(TRUE), not null
#
# Indexes
#
#  index_themes_on_remote_theme_id  (remote_theme_id) UNIQUE
#
