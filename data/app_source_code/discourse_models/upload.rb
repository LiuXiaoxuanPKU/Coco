# frozen_string_literal: true

require "digest/sha1"

class Upload < ActiveRecord::Base
  self.ignored_columns = [
    "verified" # TODO(2020-12-10): remove
  ]

  include ActionView::Helpers::NumberHelper
  include HasUrl

  SHA1_LENGTH = 40
  SEEDED_ID_THRESHOLD = 0
  URL_REGEX ||= /(\/original\/\dX[\/\.\w]*\/(\h+)[\.\w]*)/
  MAX_IDENTIFY_SECONDS = 5

  belongs_to :user
  belongs_to :access_control_post, class_name: 'Post'

  # when we access this post we don't care if the post
  # is deleted
  def access_control_post
    Post.unscoped { super }
  end

  has_many :post_uploads, dependent: :destroy
  has_many :posts, through: :post_uploads

  has_many :optimized_images, dependent: :destroy
  has_many :user_uploads, dependent: :destroy
  has_many :topic_thumbnails

  attr_accessor :for_group_message
  attr_accessor :for_theme
  attr_accessor :for_private_message
  attr_accessor :for_export
  attr_accessor :for_site_setting
  attr_accessor :for_gravatar

  validates_presence_of :filesize
  validates_presence_of :original_filename

  validates_with UploadValidator

  before_destroy do
    UserProfile.where(card_background_upload_id: self.id).update_all(card_background_upload_id: nil)
    UserProfile.where(profile_background_upload_id: self.id).update_all(profile_background_upload_id: nil)
  end

  after_destroy do
    User.where(uploaded_avatar_id: self.id).update_all(uploaded_avatar_id: nil)
    UserAvatar.where(gravatar_upload_id: self.id).update_all(gravatar_upload_id: nil)
    UserAvatar.where(custom_upload_id: self.id).update_all(custom_upload_id: nil)
  end

  scope :by_users, -> { where("uploads.id > ?", SEEDED_ID_THRESHOLD) }

  def self.verification_statuses
    @verification_statuses ||= Enum.new(
      unchecked: 1,
      verified: 2,
      invalid_etag: 3
    )
  end

  def self.with_no_non_post_relations
    scope = self
      .joins(<<~SQL)
        LEFT JOIN site_settings ss
        ON NULLIF(ss.value, '')::integer = uploads.id
        AND ss.data_type = #{SiteSettings::TypeSupervisor.types[:upload].to_i}
      SQL
      .where("ss.value IS NULL")
      .joins("LEFT JOIN users u ON u.uploaded_avatar_id = uploads.id")
      .where("u.uploaded_avatar_id IS NULL")
      .joins("LEFT JOIN user_avatars ua ON ua.gravatar_upload_id = uploads.id OR ua.custom_upload_id = uploads.id")
      .where("ua.gravatar_upload_id IS NULL AND ua.custom_upload_id IS NULL")
      .joins("LEFT JOIN user_profiles up ON up.profile_background_upload_id = uploads.id OR up.card_background_upload_id = uploads.id")
      .where("up.profile_background_upload_id IS NULL AND up.card_background_upload_id IS NULL")
      .joins("LEFT JOIN categories c ON c.uploaded_logo_id = uploads.id OR c.uploaded_background_id = uploads.id")
      .where("c.uploaded_logo_id IS NULL AND c.uploaded_background_id IS NULL")
      .joins("LEFT JOIN custom_emojis ce ON ce.upload_id = uploads.id")
      .where("ce.upload_id IS NULL")
      .joins("LEFT JOIN theme_fields tf ON tf.upload_id = uploads.id")
      .where("tf.upload_id IS NULL")
      .joins("LEFT JOIN user_exports ue ON ue.upload_id = uploads.id")
      .where("ue.upload_id IS NULL")
      .joins("LEFT JOIN groups g ON g.flair_upload_id = uploads.id")
      .where("g.flair_upload_id IS NULL")
      .joins("LEFT JOIN badges b ON b.image_upload_id = uploads.id")
      .where("b.image_upload_id IS NULL")

    if SiteSetting.selectable_avatars.present?
      scope = scope.where.not(id: SiteSetting.selectable_avatars.map(&:id))
    end

    scope
  end

  def to_s
    self.url
  end

  def thumbnail(width = self.thumbnail_width, height = self.thumbnail_height)
    optimized_images.find_by(width: width, height: height)
  end

  def has_thumbnail?(width, height)
    thumbnail(width, height).present?
  end

  def create_thumbnail!(width, height, opts = nil)
    return unless SiteSetting.create_thumbnails?
    opts ||= {}

    if get_optimized_image(width, height, opts)
      save(validate: false)
    end
  end

  # this method attempts to correct old incorrect extensions
  def get_optimized_image(width, height, opts = nil)
    opts ||= {}

    if (!extension || extension.length == 0)
      fix_image_extension
    end

    opts = opts.merge(raise_on_error: true)
    begin
      OptimizedImage.create_for(self, width, height, opts)
    rescue => ex
      Rails.logger.info ex if Rails.env.development?
      opts = opts.merge(raise_on_error: false)
      if fix_image_extension
        OptimizedImage.create_for(self, width, height, opts)
      else
        nil
      end
    end
  end

  def fix_image_extension
    return false if extension == "unknown"

    begin
      # this is relatively cheap once cached
      original_path = Discourse.store.path_for(self)
      if original_path.blank?
        external_copy = Discourse.store.download(self) rescue nil
        original_path = external_copy.try(:path)
      end

      image_info = FastImage.new(original_path) rescue nil
      new_extension = image_info&.type&.to_s || "unknown"

      if new_extension != self.extension
        self.update_columns(extension: new_extension)
        true
      end
    rescue
      self.update_columns(extension: "unknown")
      true
    end
  end

  def destroy
    Upload.transaction do
      Discourse.store.remove_upload(self)
      super
    end
  end

  def short_url
    "upload://#{short_url_basename}"
  end

  def uploaded_before_secure_media_enabled?
    original_sha1.blank?
  end

  def matching_access_control_post?(post)
    access_control_post_id == post.id
  end

  def copied_from_other_post?(post)
    return false if access_control_post_id.blank?
    !matching_access_control_post?(post)
  end

  def short_path
    self.class.short_path(sha1: self.sha1, extension: self.extension)
  end

  def self.consider_for_reuse(upload, post)
    return upload if !SiteSetting.secure_media? || upload.blank? || post.blank?
    return nil if !upload.matching_access_control_post?(post) || upload.uploaded_before_secure_media_enabled?
    upload
  end

  def self.secure_media_url?(url)
    # we do not want to exclude topic links that for whatever reason
    # have secure-media-uploads in the URL e.g. /t/secure-media-uploads-are-cool/223452
    route = UrlHelper.rails_route_from_url(url)
    return false if route.blank?
    route[:action] == "show_secure" && route[:controller] == "uploads" && FileHelper.is_supported_media?(url)
  rescue ActionController::RoutingError
    false
  end

  def self.signed_url_from_secure_media_url(url)
    route = UrlHelper.rails_route_from_url(url)
    url = Rails.application.routes.url_for(route.merge(only_path: true))
    secure_upload_s3_path = url[url.index(route[:path])..-1]
    Discourse.store.signed_url_for_path(secure_upload_s3_path)
  end

  def self.secure_media_url_from_upload_url(url)
    return url if !url.include?(SiteSetting.Upload.absolute_base_url)
    uri = URI.parse(url)
    Rails.application.routes.url_for(
      controller: "uploads",
      action: "show_secure",
      path: uri.path[1..-1],
      only_path: true
    )
  end

  def self.short_path(sha1:, extension:)
    @url_helpers ||= Rails.application.routes.url_helpers

    @url_helpers.upload_short_path(
      base62: self.base62_sha1(sha1),
      extension: extension
    )
  end

  def self.base62_sha1(sha1)
    Base62.encode(sha1.hex)
  end

  def base62_sha1
    Upload.base62_sha1(self.sha1)
  end

  def local?
    !(url =~ /^(https?:)?\/\//)
  end

  def fix_dimensions!
    return if !FileHelper.is_supported_image?("image.#{extension}")

    path =
      if local?
        Discourse.store.path_for(self)
      else
        Discourse.store.download(self).path
      end

    begin
      if extension == 'svg'
        w, h = Discourse::Utils.execute_command("identify", "-format", "%w %h", path, timeout: MAX_IDENTIFY_SECONDS).split(' ') rescue [0, 0]
      else
        w, h = FastImage.new(path, raise_on_failure: true).size
      end

      self.width = w || 0
      self.height = h || 0

      self.thumbnail_width, self.thumbnail_height = ImageSizer.resize(w, h)

      self.update_columns(
        width: width,
        height: height,
        thumbnail_width: thumbnail_width,
        thumbnail_height: thumbnail_height
      )
    rescue => e
      Discourse.warn_exception(e, message: "Error getting image dimensions")
    end
    nil
  end

  # on demand image size calculation, this allows us to null out image sizes
  # and still handle as needed
  def get_dimension(key)
    if v = read_attribute(key)
      return v
    end
    fix_dimensions!
    read_attribute(key)
  end

  def width
    get_dimension(:width)
  end

  def height
    get_dimension(:height)
  end

  def thumbnail_width
    get_dimension(:thumbnail_width)
  end

  def thumbnail_height
    get_dimension(:thumbnail_height)
  end

  def target_image_quality(local_path, test_quality)
    @file_quality ||= Discourse::Utils.execute_command("identify", "-format", "%Q", local_path, timeout: MAX_IDENTIFY_SECONDS).to_i rescue 0

    if @file_quality == 0 || @file_quality > test_quality
      test_quality
    end
  end

  def self.sha1_from_short_path(path)
    if path =~ /(\/uploads\/short-url\/)([a-zA-Z0-9]+)(\..*)?/
      self.sha1_from_base62_encoded($2)
    end
  end

  def self.sha1_from_short_url(url)
    if url =~ /(upload:\/\/)?([a-zA-Z0-9]+)(\..*)?/
      self.sha1_from_base62_encoded($2)
    end
  end

  def self.sha1_from_base62_encoded(encoded_sha1)
    sha1 = Base62.decode(encoded_sha1).to_s(16)

    if sha1.length > SHA1_LENGTH
      nil
    else
      sha1.rjust(SHA1_LENGTH, '0')
    end
  end

  def self.generate_digest(path)
    Digest::SHA1.file(path).hexdigest
  end

  def human_filesize
    number_to_human_size(self.filesize)
  end

  def rebake_posts_on_old_scheme
    self.posts.where("cooked LIKE '%/_optimized/%'").find_each(&:rebake!)
  end

  def update_secure_status(source: "unknown", override: nil)
    if override.nil?
      mark_secure, reason = UploadSecurity.new(self).should_be_secure_with_reason
    else
      mark_secure = override
      reason = "manually overridden"
    end

    secure_status_did_change = self.secure? != mark_secure
    self.update(secure_params(mark_secure, reason, source))

    if Discourse.store.external?
      begin
        Discourse.store.update_upload_ACL(self)
      rescue Aws::S3::Errors::NotImplemented => err
        Discourse.warn_exception(err, message: "The file store object storage provider does not support setting ACLs")
      end
    end

    secure_status_did_change
  end

  def secure_params(secure, reason, source = "unknown")
    {
      secure: secure,
      security_last_changed_reason: reason + " | source: #{source}",
      security_last_changed_at: Time.zone.now
    }
  end

  def self.migrate_to_new_scheme(limit: nil)
    problems = []

    DistributedMutex.synchronize("migrate_upload_to_new_scheme") do
      if SiteSetting.migrate_to_new_scheme
        max_file_size_kb = [
          SiteSetting.max_image_size_kb,
          SiteSetting.max_attachment_size_kb
        ].max.kilobytes

        local_store = FileStore::LocalStore.new
        db = RailsMultisite::ConnectionManagement.current_db

        scope = Upload.by_users
          .where("url NOT LIKE '%/original/_X/%' AND url LIKE '%/uploads/#{db}%'")
          .order(id: :desc)

        scope = scope.limit(limit) if limit

        if scope.count == 0
          SiteSetting.migrate_to_new_scheme = false
          return problems
        end

        remap_scope = nil

        scope.each do |upload|
          begin
            # keep track of the url
            previous_url = upload.url.dup
            # where is the file currently stored?
            external = previous_url =~ /^\/\//
            # download if external
            if external
              url = SiteSetting.scheme + ":" + previous_url

              begin
                retries ||= 0

                file = FileHelper.download(
                  url,
                  max_file_size: max_file_size_kb,
                  tmp_file_name: "discourse",
                  follow_redirect: true
                )
              rescue OpenURI::HTTPError
                retry if (retries += 1) < 1
                next
              end

              path = file.path
            else
              path = local_store.path_for(upload)
            end
            # compute SHA if missing
            if upload.sha1.blank?
              upload.sha1 = Upload.generate_digest(path)
            end

            # store to new location & update the filesize
            File.open(path) do |f|
              upload.url = Discourse.store.store_upload(f, upload)
              upload.filesize = f.size
              upload.save!(validate: false)
            end
            # remap the URLs
            DbHelper.remap(UrlHelper.absolute(previous_url), upload.url) unless external

            DbHelper.remap(
              previous_url,
              upload.url,
              excluded_tables: %w{
                posts
                post_search_data
                incoming_emails
                notifications
                single_sign_on_records
                stylesheet_cache
                topic_search_data
                users
                user_emails
                draft_sequences
                optimized_images
              }
            )

            remap_scope ||= begin
              Post.with_deleted
                .where("raw ~ '/uploads/#{db}/\\d+/' OR raw ~ '/uploads/#{db}/original/(\\d|[a-z])/'")
                .select(:id, :raw, :cooked)
                .all
            end

            remap_scope.each do |post|
              post.raw.gsub!(previous_url, upload.url)
              post.cooked.gsub!(previous_url, upload.url)
              Post.with_deleted.where(id: post.id).update_all(raw: post.raw, cooked: post.cooked) if post.changed?
            end

            upload.optimized_images.find_each(&:destroy!)
            upload.rebake_posts_on_old_scheme
            # remove the old file (when local)
            unless external
              FileUtils.rm(path, force: true)
            end
          rescue => e
            problems << { upload: upload, ex: e }
          ensure
            file&.unlink
            file&.close
          end
        end
      end
    end

    problems
  end

  private

  def short_url_basename
    "#{Upload.base62_sha1(sha1)}#{extension.present? ? ".#{extension}" : ""}"
  end

end

# == Schema Information
#
# Table name: uploads
#
#  id                           :integer          not null, primary key
#  user_id                      :integer          not null
#  original_filename            :string           not null
#  filesize                     :integer          not null
#  width                        :integer
#  height                       :integer
#  url                          :string           not null
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  sha1                         :string(40)
#  origin                       :string(1000)
#  retain_hours                 :integer
#  extension                    :string(10)
#  thumbnail_width              :integer
#  thumbnail_height             :integer
#  etag                         :string
#  secure                       :boolean          default(FALSE), not null
#  access_control_post_id       :bigint
#  original_sha1                :string
#  verification_status          :integer          default(1), not null
#  animated                     :boolean
#  security_last_changed_at     :datetime
#  security_last_changed_reason :string
#
# Indexes
#
#  idx_uploads_on_verification_status       (verification_status)
#  index_uploads_on_access_control_post_id  (access_control_post_id)
#  index_uploads_on_etag                    (etag)
#  index_uploads_on_extension               (lower((extension)::text))
#  index_uploads_on_id_and_url              (id,url)
#  index_uploads_on_original_sha1           (original_sha1)
#  index_uploads_on_sha1                    (sha1) UNIQUE
#  index_uploads_on_url                     (url)
#  index_uploads_on_user_id                 (user_id)
#
