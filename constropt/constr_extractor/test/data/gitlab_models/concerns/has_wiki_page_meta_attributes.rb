# frozen_string_literal: true

module HasWikiPageMetaAttributes
  extend ActiveSupport::Concern
  include Gitlab::Utils::StrongMemoize

  CanonicalSlugConflictError = Class.new(ActiveRecord::RecordInvalid)
  WikiPageInvalid = Class.new(ArgumentError)

  included do
    has_many :events, as: :target, dependent: :delete_all # rubocop:disable Cop/ActiveRecordDependent

    validates :title, length: { maximum: 255 }, allow_nil: false
    validate :no_two_metarecords_in_same_container_can_have_same_canonical_slug

    scope :with_canonical_slug, ->(slug) do
      slug_table_name = klass.reflect_on_association(:slugs).table_name

      joins(:slugs).where(slug_table_name => { canonical: true, slug: slug })
    end
  end

  class_methods do
    # Return the (updated) WikiPage::Meta record for a given wiki page
    #
    # If none is found, then a new record is created, and its fields are set
    # to reflect the wiki_page passed.
    #
    # @param [String] last_known_slug
    # @param [WikiPage] wiki_page
    #
    # This method raises errors on validation issues.
    def find_or_create(last_known_slug, wiki_page)
      raise WikiPageInvalid unless wiki_page.valid?

      container = wiki_page.wiki.container
      known_slugs = [last_known_slug, wiki_page.slug].compact.uniq
      raise 'No slugs found! This should not be possible.' if known_slugs.empty?

      transaction do
        updates = wiki_page_updates(wiki_page)
        found = find_by_canonical_slug(known_slugs, container)
        meta = found || create!(updates.merge(container_attrs(container)))

        meta.update_state(found.nil?, known_slugs, wiki_page, updates)

        # We don't need to run validations here, since find_by_canonical_slug
        # guarantees that there is no conflict in canonical_slug, and DB
        # constraints on title and project_id/group_id enforce our other invariants
        # This saves us a query.
        meta
      end
    end

    def find_by_canonical_slug(canonical_slug, container)
      meta, conflict = with_canonical_slug(canonical_slug)
        .where(container_attrs(container))
        .limit(2)

      if conflict.present?
        meta.errors.add(:canonical_slug, 'Duplicate value found')
        raise CanonicalSlugConflictError, meta
      end

      meta
    end

    private

    def wiki_page_updates(wiki_page)
      last_commit_date = wiki_page.version_commit_timestamp || Time.now.utc

      {
        title: wiki_page.title,
        created_at: last_commit_date,
        updated_at: last_commit_date
      }
    end

    def container_key
      raise NotImplementedError
    end

    def container_attrs(container)
      { container_key => container.id }
    end
  end

  def canonical_slug
    strong_memoize(:canonical_slug) { slugs.canonical.take&.slug }
  end

  # rubocop:disable Gitlab/ModuleWithInstanceVariables
  def canonical_slug=(slug)
    return if @canonical_slug == slug

    if persisted?
      transaction do
        slugs.canonical.update_all(canonical: false)
        page_slug = slugs.create_with(canonical: true).find_or_create_by(slug: slug)
        page_slug.update_columns(canonical: true) unless page_slug.canonical?
      end
    else
      slugs.new(slug: slug, canonical: true)
    end

    @canonical_slug = slug
  end
  # rubocop:enable Gitlab/ModuleWithInstanceVariables

  def update_state(created, known_slugs, wiki_page, updates)
    update_wiki_page_attributes(updates)
    insert_slugs(known_slugs, created, wiki_page.slug)
    self.canonical_slug = wiki_page.slug
  end

  private

  def update_wiki_page_attributes(updates)
    # Remove all unnecessary updates:
    updates.delete(:updated_at) if updated_at == updates[:updated_at]
    updates.delete(:created_at) if created_at <= updates[:created_at]
    updates.delete(:title) if title == updates[:title]

    update_columns(updates) unless updates.empty?
  end

  def insert_slugs(strings, is_new, canonical_slug)
    creation = Time.current.utc

    slug_attrs = strings.map do |slug|
      slug_attributes(slug, canonical_slug, is_new, creation)
    end
    slugs.insert_all(slug_attrs) unless !is_new && slug_attrs.size == 1

    @canonical_slug = canonical_slug if is_new || strings.size == 1 # rubocop:disable Gitlab/ModuleWithInstanceVariables
  end

  def slug_attributes(slug, canonical_slug, is_new, creation)
    {
      slug: slug,
      canonical: (is_new && slug == canonical_slug),
      created_at: creation,
      updated_at: creation
    }.merge(slug_meta_attributes)
  end

  def slug_meta_attributes
    { self.association(:slugs).reflection.foreign_key => id }
  end

  def no_two_metarecords_in_same_container_can_have_same_canonical_slug
    container_id = attributes[self.class.container_key.to_s]

    return unless container_id.present? && canonical_slug.present?

    offending = self.class.with_canonical_slug(canonical_slug).where(self.class.container_key => container_id)
    offending = offending.where.not(id: id) if persisted?

    if offending.exists?
      errors.add(:canonical_slug, 'each page in a wiki must have a distinct canonical slug')
    end
  end
end
