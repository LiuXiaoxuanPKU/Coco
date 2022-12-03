# frozen_string_literal: true

class TopicList
  include ActiveModel::Serialization

  cattr_accessor :preloaded_custom_fields
  self.preloaded_custom_fields = Set.new

  def self.on_preload(&blk)
    (@preload ||= Set.new) << blk
  end

  def self.cancel_preload(&blk)
    if @preload
      @preload.delete blk
      if @preload.length == 0
        @preload = nil
      end
    end
  end

  def self.preload(topics, object)
    if @preload
      @preload.each { |preload| preload.call(topics, object) }
    end
  end

  attr_accessor(
    :more_topics_url,
    :prev_topics_url,
    :filter,
    :for_period,
    :per_page,
    :top_tags,
    :current_user,
    :tags,
    :shared_drafts,
    :category,
    :publish_read_state
  )

  def initialize(filter, current_user, topics, opts = nil)
    @filter = filter
    @current_user = current_user
    @topics_input = topics
    @opts = opts || {}

    if @opts[:category]
      @category = Category.find_by(id: @opts[:category_id])
    end

    if @opts[:tags]
      @tags = Tag.where(id: @opts[:tags]).all
    end

    @publish_read_state = !!@opts[:publish_read_state]
  end

  def top_tags
    opts = @category ? { category: @category } : {}
    opts[:guardian] = Guardian.new(@current_user)
    Tag.top_tags(**opts)
  end

  def preload_key
    if @category
      if @opts[:no_subcategories]
        "topic_list_#{@category.url.sub(/^\//, '')}/none/l/#{@filter}"
      else
        "topic_list_#{@category.url.sub(/^\//, '')}/l/#{@filter}"
      end
    elsif @tags && @tags.first.present?
      "topic_list_tag/#{@tags.first.name}/l/#{@filter}"
    else
      "topic_list_#{@filter}"
    end
  end

  # Lazy initialization
  def topics
    @topics ||= load_topics
  end

  def load_topics
    @topics = @topics_input

    # Attach some data for serialization to each topic
    @topic_lookup = TopicUser.lookup_for(@current_user, @topics) if @current_user
    @dismissed_topic_users_lookup = DismissedTopicUser.lookup_for(@current_user, @topics) if @current_user

    post_action_type =
      if @current_user
        if @opts[:filter].present?
          if @opts[:filter] == "bookmarked"
            PostActionType.types[:bookmark]
          elsif @opts[:filter] == "liked"
            PostActionType.types[:like]
          end
        end
      end

    # Include bookmarks if you have bookmarked topics
    if @current_user && !post_action_type
      post_action_type = PostActionType.types[:bookmark] if @topic_lookup.any? { |_, tu| tu && tu.bookmarked }
    end

    # Data for bookmarks or likes
    post_action_lookup = PostAction.lookup_for(@current_user, @topics, post_action_type) if post_action_type

    # Create a lookup for all the user ids we need
    user_ids = []
    @topics.each do |ft|
      user_ids << ft.user_id << ft.last_post_user_id << ft.featured_user_ids << ft.allowed_user_ids
    end

    user_lookup = UserLookup.new(user_ids)

    @topics.each do |ft|
      ft.user_data = @topic_lookup[ft.id] if @topic_lookup.present?

      if ft.regular? && category_user_lookup.present?
        ft.category_user_data = @category_user_lookup[ft.category_id]
      end

      ft.dismissed = @current_user && @dismissed_topic_users_lookup.include?(ft.id)

      if ft.user_data && post_action_lookup && actions = post_action_lookup[ft.id]
        ft.user_data.post_action_data = { post_action_type => actions }
      end

      ft.posters = ft.posters_summary(
        user_lookup: user_lookup
      )

      ft.participants = ft.participants_summary(
        user_lookup: user_lookup,
        user: @current_user
      )
      ft.topic_list = self
    end

    ActiveRecord::Associations::Preloader.new.preload(@topics, [:image_upload, topic_thumbnails: :optimized_image])

    if preloaded_custom_fields.present?
      Topic.preload_custom_fields(@topics, preloaded_custom_fields)
    end

    TopicList.preload(@topics, self)

    @topics
  end

  def attributes
    { 'more_topics_url' => page }
  end

  private

  def category_user_lookup
    @category_user_lookup ||= begin
      if @current_user
        CategoryUser.lookup_for(@current_user, @topics.map(&:category_id).uniq)
      else
        []
      end
    end
  end
end
