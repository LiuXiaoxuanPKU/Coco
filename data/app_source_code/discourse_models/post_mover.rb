# frozen_string_literal: true

class PostMover
  attr_reader :original_topic, :destination_topic, :user, :post_ids

  def self.move_types
    @move_types ||= Enum.new(:new_topic, :existing_topic)
  end

  def initialize(original_topic, user, post_ids, move_to_pm: false)
    @original_topic = original_topic
    @user = user
    @post_ids = post_ids
    @move_to_pm = move_to_pm
  end

  def to_topic(id, participants: nil)
    @move_type = PostMover.move_types[:existing_topic]

    topic = Topic.find_by_id(id)
    if topic.archetype != @original_topic.archetype &&
       [@original_topic.archetype, topic.archetype].include?(Archetype.private_message)
      raise Discourse::InvalidParameters
    end

    Topic.transaction do
      move_posts_to topic
    end
    add_allowed_users(participants) if participants.present? && @move_to_pm
    enqueue_jobs(topic)
    topic
  end

  def to_new_topic(title, category_id = nil, tags = nil)
    @move_type = PostMover.move_types[:new_topic]

    post = Post.find_by(id: post_ids.first)
    raise Discourse::InvalidParameters unless post
    archetype = @move_to_pm ? Archetype.private_message : Archetype.default

    topic = Topic.transaction do
      new_topic = Topic.create!(
        user: post.user,
        title: title,
        category_id: category_id,
        created_at: post.created_at,
        archetype: archetype
      )
      DiscourseTagging.tag_topic_by_names(new_topic, Guardian.new(user), tags)
      move_posts_to new_topic
      watch_new_topic
      update_topic_excerpt new_topic
      new_topic
    end
    enqueue_jobs(topic)
    topic
  end

  private

  def update_topic_excerpt(topic)
    topic.update_excerpt(topic.first_post.excerpt_for_topic)
  end

  def move_posts_to(topic)
    Guardian.new(user).ensure_can_see! topic
    @destination_topic = topic

    # when a topic contains some posts after moving posts to another topic we shouldn't close it
    # two types of posts should prevent a topic from closing:
    #   1. regular posts
    #   2. almost all whispers
    # we should only exclude whispers with action_code: 'split_topic'
    # because we use such whispers as a small-action posts when moving posts to the secret message
    # (in this case we don't want everyone to see that posts were moved, that's why we use whispers)
    original_topic_posts_count = @original_topic.posts
      .where("post_type = ? or (post_type = ? and action_code != 'split_topic')", Post.types[:regular], Post.types[:whisper])
      .count
    moving_all_posts = original_topic_posts_count == posts.length

    create_temp_table
    move_each_post
    create_moderator_post_in_original_topic
    update_statistics
    update_user_actions
    update_last_post_stats
    update_upload_security_status
    update_bookmarks

    if moving_all_posts
      close_topic_and_schedule_deletion
    end

    destination_topic.reload
    destination_topic
  end

  def create_temp_table
    DB.exec("DROP TABLE IF EXISTS moved_posts") if Rails.env.test?

    DB.exec <<~SQL
      CREATE TEMPORARY TABLE moved_posts (
        old_topic_id INTEGER,
        old_post_id INTEGER,
        old_post_number INTEGER,
        new_topic_id INTEGER,
        new_topic_title VARCHAR,
        new_post_id INTEGER,
        new_post_number INTEGER
      ) ON COMMIT DROP;

      CREATE INDEX moved_posts_old_post_number ON moved_posts(old_post_number);
      CREATE INDEX moved_posts_old_post_id ON moved_posts(old_post_id);
    SQL
  end

  def move_each_post
    max_post_number = destination_topic.max_post_number + 1

    @post_creator = nil
    @move_map = {}
    @reply_count = {}
    posts.each_with_index do |post, offset|
      @move_map[post.post_number] = offset + max_post_number

      if post.reply_to_post_number.present?
        @reply_count[post.reply_to_post_number] = (@reply_count[post.reply_to_post_number] || 0) + 1
      end
    end

    posts.each do |post|
      metadata = movement_metadata(post)
      new_post = post.is_first_post? ? create_first_post(post) : move(post)

      store_movement(metadata, new_post)

      if @move_to_pm && !destination_topic.topic_allowed_users.exists?(user_id: post.user_id)
        destination_topic.topic_allowed_users.create!(user_id: post.user_id)
      end
    end

    move_incoming_emails
    move_notifications
    update_reply_counts
    update_quotes
    move_first_post_replies
    delete_post_replies
    delete_invalid_post_timings
    copy_first_post_timings
    move_post_timings
    copy_topic_users
  end

  def create_first_post(post)
    @post_creator = PostCreator.new(
      post.user,
      raw: post.raw,
      topic_id: destination_topic.id,
      acting_user: user,
      cook_method: post.cook_method,
      via_email: post.via_email,
      raw_email: post.raw_email,
      skip_validations: true,
      created_at: post.created_at,
      guardian: Guardian.new(user),
      skip_jobs: true
    )
    new_post = @post_creator.create

    move_email_logs(post, new_post)

    PostAction.copy(post, new_post)
    new_post.update_column(:reply_count, @reply_count[1] || 0)
    new_post.custom_fields = post.custom_fields
    new_post.save_custom_fields

    DiscourseEvent.trigger(:post_moved, new_post, original_topic.id)

    new_post
  end

  def move(post)
    @first_post_number_moved ||= post.post_number

    update = {
      reply_count: @reply_count[post.post_number] || 0,
      post_number: @move_map[post.post_number],
      reply_to_post_number: @move_map[post.reply_to_post_number],
      topic_id: destination_topic.id,
      sort_order: @move_map[post.post_number]
    }

    unless @move_map[post.reply_to_post_number]
      update[:reply_to_user_id] = nil
    end

    post.attributes = update
    post.save(validate: false)

    DiscourseEvent.trigger(:post_moved, post, original_topic.id)

    # Move any links from the post to the new topic
    post.topic_links.update_all(topic_id: destination_topic.id)

    post
  end

  def movement_metadata(post)
    {
      old_topic_id: post.topic_id,
      old_post_id: post.id,
      old_post_number: post.post_number,
      new_topic_id: destination_topic.id,
      new_post_number: @move_map[post.post_number],
      new_topic_title: destination_topic.title
    }
  end

  def store_movement(metadata, new_post)
    metadata[:new_post_id] = new_post.id

    DB.exec(<<~SQL, metadata)
      INSERT INTO moved_posts(old_topic_id, old_post_id, old_post_number, new_topic_id, new_topic_title, new_post_id, new_post_number)
      VALUES (:old_topic_id, :old_post_id, :old_post_number, :new_topic_id, :new_topic_title, :new_post_id, :new_post_number)
    SQL
  end

  def move_incoming_emails
    DB.exec <<~SQL
      UPDATE incoming_emails ie
      SET topic_id = mp.new_topic_id,
          post_id = mp.new_post_id
      FROM moved_posts mp
      WHERE ie.topic_id = mp.old_topic_id AND ie.post_id = mp.old_post_id
    SQL
  end

  def move_email_logs(old_post, new_post)
    EmailLog
      .where(post_id: old_post.id)
      .update_all(post_id: new_post.id)
  end

  def move_notifications
    DB.exec <<~SQL
      UPDATE notifications n
      SET topic_id  = mp.new_topic_id,
        post_number = mp.new_post_number,
        data        = (data :: JSONB ||
          jsonb_strip_nulls(
              jsonb_build_object(
                  'topic_title', CASE WHEN data :: JSONB ->> 'topic_title' IS NULL
                                        THEN NULL
                                      ELSE mp.new_topic_title END
                )
            )) :: JSON
      FROM moved_posts mp
      WHERE n.topic_id = mp.old_topic_id AND n.post_number = mp.old_post_number
        AND n.notification_type <> #{Notification.types[:watching_first_post]}
    SQL
  end

  def update_reply_counts
    DB.exec <<~SQL
      UPDATE posts p
      SET reply_count = GREATEST(0, reply_count - x.moved_reply_count)
      FROM (
        SELECT r.post_id, mp.new_topic_id, COUNT(1) AS moved_reply_count
        FROM moved_posts mp
               JOIN post_replies r ON (mp.old_post_id = r.reply_post_id)
        GROUP BY r.post_id, mp.new_topic_id
      ) x
      WHERE x.post_id = p.id AND x.new_topic_id <> p.topic_id
    SQL
  end

  def update_quotes
    DB.exec <<~SQL
      UPDATE posts p
      SET raw = REPLACE(p.raw,
                        ', post:' || mp.old_post_number || ', topic:' || mp.old_topic_id,
                        ', post:' || mp.new_post_number || ', topic:' || mp.new_topic_id),
          baked_version = NULL
      FROM moved_posts mp, quoted_posts qp
      WHERE p.id = qp.post_id AND mp.old_post_id = qp.quoted_post_id
    SQL
  end

  def move_first_post_replies
    DB.exec <<~SQL
      UPDATE post_replies pr
      SET post_id = mp.new_post_id
      FROM moved_posts mp
      WHERE mp.old_post_id <> mp.new_post_id AND pr.post_id = mp.old_post_id AND
        EXISTS (SELECT 1 FROM moved_posts mr WHERE mr.new_post_id = pr.reply_post_id)
    SQL
  end

  def delete_post_replies
    DB.exec <<~SQL
      DELETE FROM post_replies pr USING moved_posts mp
      WHERE (SELECT topic_id FROM posts WHERE id = pr.post_id) <>
            (SELECT topic_id FROM posts WHERE id = pr.reply_post_id)
        AND (pr.reply_post_id = mp.old_post_id OR pr.post_id = mp.old_post_id)
    SQL
  end

  def copy_first_post_timings
    DB.exec <<~SQL
      INSERT INTO post_timings (topic_id, user_id, post_number, msecs)
      SELECT mp.new_topic_id, pt.user_id, mp.new_post_number, pt.msecs
      FROM post_timings pt
           JOIN moved_posts mp ON (pt.topic_id = mp.old_topic_id AND pt.post_number = mp.old_post_number)
      WHERE mp.old_post_id <> mp.new_post_id
      ON CONFLICT (topic_id, post_number, user_id) DO UPDATE
        SET msecs = GREATEST(post_timings.msecs, excluded.msecs)
    SQL
  end

  def delete_invalid_post_timings
    DB.exec <<~SQL
      DELETE
      FROM post_timings pt
      USING moved_posts mp
      WHERE pt.topic_id = mp.new_topic_id
        AND pt.post_number = mp.new_post_number
    SQL
  end

  def move_post_timings
    DB.exec <<~SQL
      UPDATE post_timings pt
      SET topic_id    = mp.new_topic_id,
          post_number = mp.new_post_number
      FROM moved_posts mp
      WHERE pt.topic_id = mp.old_topic_id
        AND pt.post_number = mp.old_post_number
        AND mp.old_post_id = mp.new_post_id
    SQL
  end

  def copy_topic_users
    params = {
      old_topic_id: original_topic.id,
      new_topic_id: destination_topic.id,
      old_highest_post_number: destination_topic.highest_post_number,
      old_highest_staff_post_number: destination_topic.highest_staff_post_number
    }

    DB.exec(<<~SQL, params)
      INSERT INTO topic_users(user_id, topic_id, posted, last_read_post_number,
                              last_emailed_post_number, first_visited_at, last_visited_at, notification_level,
                              notifications_changed_at, notifications_reason_id)
      SELECT tu.user_id,
             :new_topic_id                               AS topic_id,
               EXISTS(
                 SELECT 1
                 FROM posts p
                 WHERE p.topic_id = :new_topic_id
                   AND p.user_id = tu.user_id
                 LIMIT 1
               )                                         AS posted,
             (
               SELECT MAX(lr.new_post_number)
               FROM moved_posts lr
               WHERE lr.old_topic_id = tu.topic_id
                 AND lr.old_post_number <= tu.last_read_post_number
             )                                           AS last_read_post_number,
             (
               SELECT MAX(le.new_post_number)
               FROM moved_posts le
               WHERE le.old_topic_id = tu.topic_id
                 AND le.old_post_number <= tu.last_emailed_post_number
             )                                           AS last_emailed_post_number,
             GREATEST(tu.first_visited_at, t.created_at) AS first_visited_at,
             GREATEST(tu.last_visited_at, t.created_at)  AS last_visited_at,
             tu.notification_level,
             tu.notifications_changed_at,
             tu.notifications_reason_id
      FROM topic_users tu
           JOIN topics t ON (t.id = :new_topic_id)
      WHERE tu.topic_id = :old_topic_id
        AND GREATEST(
                tu.last_read_post_number,
                tu.last_emailed_post_number
              ) >= (SELECT MIN(old_post_number) FROM moved_posts)
      ON CONFLICT (topic_id, user_id) DO UPDATE
        SET posted                   = excluded.posted,
            last_read_post_number    = CASE
                                         WHEN topic_users.last_read_post_number = :old_highest_staff_post_number OR (
                                             :old_highest_post_number < :old_highest_staff_post_number
                                             AND topic_users.last_read_post_number = :old_highest_post_number
                                             AND NOT EXISTS(SELECT 1
                                                            FROM users u
                                                            WHERE u.id = topic_users.user_id
                                                              AND (admin OR moderator))
                                           ) THEN
                                           GREATEST(topic_users.last_read_post_number,
                                                    excluded.last_read_post_number)
                                         ELSE topic_users.last_read_post_number END,
            last_emailed_post_number = CASE
                                         WHEN topic_users.last_emailed_post_number = :old_highest_staff_post_number OR (
                                             :old_highest_post_number < :old_highest_staff_post_number
                                             AND topic_users.last_emailed_post_number = :old_highest_post_number
                                             AND NOT EXISTS(SELECT 1
                                                            FROM users u
                                                            WHERE u.id = topic_users.user_id
                                                              AND (admin OR moderator))
                                           ) THEN
                                           GREATEST(topic_users.last_emailed_post_number,
                                                    excluded.last_emailed_post_number)
                                         ELSE topic_users.last_emailed_post_number END,
            first_visited_at         = LEAST(topic_users.first_visited_at, excluded.first_visited_at),
            last_visited_at          = GREATEST(topic_users.last_visited_at, excluded.last_visited_at)
    SQL
  end

  def update_statistics
    destination_topic.update_statistics
    original_topic.update_statistics
    TopicUser.update_post_action_cache(topic_id: [original_topic.id, destination_topic.id], post_id: @post_ids)
  end

  def update_user_actions
    UserAction.synchronize_target_topic_ids(posts.map(&:id))
  end

  def create_moderator_post_in_original_topic
    move_type_str = PostMover.move_types[@move_type].to_s
    move_type_str.sub!("topic", "message") if @move_to_pm

    message = I18n.with_locale(SiteSetting.default_locale) do
      I18n.t(
        "move_posts.#{move_type_str}_moderator_post",
        count: posts.length,
        topic_link: posts.first.is_first_post? ?
          "[#{destination_topic.title}](#{destination_topic.relative_url})" :
          "[#{destination_topic.title}](#{posts.first.url})"
      )
    end

    post_type = @move_to_pm ? Post.types[:whisper] : Post.types[:small_action]
    original_topic.add_moderator_post(
      user, message,
      post_type: post_type,
      action_code: "split_topic",
      post_number: @first_post_number_moved
    )
  end

  def posts
    @posts ||= begin
      Post.where(topic: @original_topic, id: post_ids)
        .where.not(post_type: Post.types[:small_action])
        .where.not(raw: '')
        .order(:created_at).tap do |posts|

        raise Discourse::InvalidParameters.new(:post_ids) if posts.empty?
      end
    end
  end

  def update_last_post_stats
    post = destination_topic.ordered_posts.where.not(post_type: Post.types[:whisper]).last
    if post && post_ids.include?(post.id)
      attrs = {}
      attrs[:last_posted_at] = post.created_at
      attrs[:last_post_user_id] = post.user_id
      attrs[:bumped_at] = Time.now
      attrs[:updated_at] = Time.now
      destination_topic.update_columns(attrs)
    end
  end

  def update_upload_security_status
    DB.after_commit do
      Jobs.enqueue(:update_topic_upload_security, topic_id: @destination_topic.id)
    end
  end

  def update_bookmarks
    Bookmark.where(post_id: post_ids).update_all(topic_id: @destination_topic.id)

    DB.after_commit do
      Jobs.enqueue(:sync_topic_user_bookmarked, topic_id: @original_topic.id)
      Jobs.enqueue(:sync_topic_user_bookmarked, topic_id: @destination_topic.id)
    end
  end

  def watch_new_topic
    if @destination_topic.archetype == Archetype.private_message
      if @original_topic.archetype == Archetype.private_message
        notification_levels = TopicUser.where(topic_id: @original_topic.id, user_id: posts.pluck(:user_id)).pluck(:user_id, :notification_level).to_h
      else
        notification_levels = posts.pluck(:user_id).uniq.map { |user_id| [user_id, TopicUser.notification_levels[:watching]] }.to_h
      end
    else
      notification_levels = [[@destination_topic.user_id, TopicUser.notification_levels[:watching]]]
    end

    notification_levels.each do |user_id, notification_level|
      TopicUser.change(
        user_id,
        @destination_topic.id,
        notification_level: notification_level,
        notifications_reason_id: TopicUser.notification_reasons[destination_topic.user_id == user_id ? :created_topic : :created_post]
      )
    end
  end

  def add_allowed_users(usernames)
    return unless usernames.present?

    names = usernames.split(',').flatten
    User.where(username: names).find_each do |user|
      destination_topic.topic_allowed_users.build(user_id: user.id) unless destination_topic.topic_allowed_users.where(user_id: user.id).exists?
    end
    destination_topic.save!
  end

  def enqueue_jobs(topic)
    @post_creator.enqueue_jobs if @post_creator

    Jobs.enqueue(
      :notify_moved_posts,
      post_ids: post_ids,
      moved_by_id: user.id
    )

    Jobs.enqueue(
      :delete_inaccessible_notifications,
      topic_id: topic.id
    )
  end

  def close_topic_and_schedule_deletion
    @original_topic.update_status('closed', true, @user)

    days_to_deleting = SiteSetting.delete_merged_stub_topics_after_days
    if days_to_deleting > 0
      @original_topic.set_or_create_timer(
        TopicTimer.types[:delete],
        days_to_deleting * 24,
        by_user: @user
      )
    end
  end
end
