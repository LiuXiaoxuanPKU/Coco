# frozen_string_literal: true

# A class we can use to serialize the site data
class Site
  include ActiveModel::Serialization

  cattr_accessor :preloaded_category_custom_fields
  self.preloaded_category_custom_fields = Set.new

  def self.add_categories_callbacks(&block)
    categories_callbacks << block
  end

  def self.categories_callbacks
    @categories_callbacks ||= []
  end

  def initialize(guardian)
    @guardian = guardian
  end

  def site_setting
    SiteSetting
  end

  def notification_types
    Notification.types
  end

  def trust_levels
    TrustLevel.levels
  end

  def user_fields
    UserField.order(:position).all
  end

  def self.categories_cache_key
    "site_categories_#{Discourse.git_version}"
  end

  def self.clear_cache
    Discourse.cache.delete(categories_cache_key)
  end

  def self.all_categories_cache
    # Categories do not change often so there is no need for us to run the
    # same query and spend time creating ActiveRecord objects for every requests.
    #
    # Do note that any new association added to the eager loading needs a
    # corresponding ActiveRecord callback to clear the categories cache.
    Discourse.cache.fetch(categories_cache_key, expires_in: 30.minutes) do
      categories = Category
        .includes(:uploaded_logo, :uploaded_background, :tags, :tag_groups, :required_tag_group)
        .joins('LEFT JOIN topics t on t.id = categories.topic_id')
        .select('categories.*, t.slug topic_slug')
        .order(:position)
        .to_a

      if preloaded_category_custom_fields.present?
        Category.preload_custom_fields(
          categories,
          preloaded_category_custom_fields
        )
      end

      ActiveModel::ArraySerializer.new(
        categories,
        each_serializer: SiteCategorySerializer
      ).as_json
    end
  end

  def categories
    @categories ||= begin
      categories = []

      self.class.all_categories_cache.each do |category|
        if @guardian.can_see_serialized_category?(category_id: category[:id], read_restricted: category[:read_restricted])
          categories << category
        end
      end

      with_children = Set.new
      categories.each do |c|
        if c[:parent_category_id]
          with_children << c[:parent_category_id]
        end
      end

      allowed_topic_create = nil
      unless @guardian.is_admin?
        allowed_topic_create_ids =
          @guardian.anonymous? ? [] : Category.topic_create_allowed(@guardian).pluck(:id)
        allowed_topic_create = Set.new(allowed_topic_create_ids)
      end

      by_id = {}

      notification_levels = CategoryUser.notification_levels_for(@guardian.user)
      default_notification_level = CategoryUser.default_notification_level

      categories.each do |category|
        category[:notification_level] = notification_levels[category[:id]] || default_notification_level
        category[:permission] = CategoryGroup.permission_types[:full] if allowed_topic_create&.include?(category[:id]) || @guardian.is_admin?
        category[:has_children] = with_children.include?(category[:id])

        category[:can_edit] = @guardian.can_edit_serialized_category?(
          category_id: category[:id],
          read_restricted: category[:read_restricted]
        )

        by_id[category[:id]] = category
      end

      categories.reject! { |c| c[:parent_category_id] && !by_id[c[:parent_category_id]] }

      self.class.categories_callbacks.each do |callback|
        callback.call(categories)
      end

      categories
    end
  end

  def groups
    Group.visible_groups(@guardian.user, "name ASC", include_everyone: true)
  end

  def archetypes
    Archetype.list.reject { |t| t.id == Archetype.private_message }
  end

  def auth_providers
    Discourse.enabled_auth_providers
  end

  def self.json_for(guardian)

    if guardian.anonymous? && SiteSetting.login_required
      return {
        periods: TopTopic.periods.map(&:to_s),
        filters: Discourse.filters.map(&:to_s),
        user_fields: UserField.all.map do |userfield|
          UserFieldSerializer.new(userfield, root: false, scope: guardian)
        end,
        auth_providers: Discourse.enabled_auth_providers.map do |provider|
          AuthProviderSerializer.new(provider, root: false, scope: guardian)
        end
      }.to_json
    end

    seq = nil

    if guardian.anonymous?
      seq = MessageBus.last_id('/site_json')

      cached_json, cached_seq, cached_version = Discourse.redis.mget('site_json', 'site_json_seq', 'site_json_version')

      if cached_json && seq == cached_seq.to_i && Discourse.git_version == cached_version
        return cached_json
      end

    end

    site = Site.new(guardian)
    json = MultiJson.dump(SiteSerializer.new(site, root: false, scope: guardian))

    if guardian.anonymous?
      Discourse.redis.multi do
        Discourse.redis.setex 'site_json', 1800, json
        Discourse.redis.set 'site_json_seq', seq
        Discourse.redis.set 'site_json_version', Discourse.git_version
      end
    end

    json
  end

  SITE_JSON_CHANNEL = '/site_json'

  def self.clear_anon_cache!
    # publishing forces the sequence up
    # the cache is validated based on the sequence
    MessageBus.publish(SITE_JSON_CHANNEL, '')
  end

end
