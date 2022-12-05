# frozen_string_literal: true

module Packages
  module Debian
    module Distribution
      extend ActiveSupport::Concern

      included do
        include FileStoreMounter

        def self.container_foreign_key
          "#{container_type}_id".to_sym
        end

        alias_attribute :container, container_type
        alias_attribute :container_id, "#{container_type}_id"

        belongs_to container_type
        belongs_to :creator, class_name: 'User'

        has_one :key,
          class_name: "Packages::Debian::#{container_type.capitalize}DistributionKey",
          foreign_key: :distribution_id,
          inverse_of: :distribution
        # component_files must be destroyed by ruby code in order to properly remove carrierwave uploads
        has_many :components,
          class_name: "Packages::Debian::#{container_type.capitalize}Component",
          foreign_key: :distribution_id,
          inverse_of: :distribution,
          dependent: :destroy # rubocop:disable Cop/ActiveRecordDependent
        has_many :component_files,
          through: :components,
          source: :files,
          class_name: "Packages::Debian::#{container_type.capitalize}ComponentFile"
        has_many :architectures,
          class_name: "Packages::Debian::#{container_type.capitalize}Architecture",
          foreign_key: :distribution_id,
          inverse_of: :distribution

        validates :codename,
          presence: true,
          uniqueness: { scope: [container_foreign_key] },
          format: { with: Gitlab::Regex.debian_distribution_regex }

        validates :suite,
          allow_nil: true,
          format: { with: Gitlab::Regex.debian_distribution_regex }
        validates :suite,
          uniqueness: { scope: [container_foreign_key] },
          if: :suite

        validate :unique_codename_and_suite

        validates :origin,
          allow_nil: true,
          format: { with: Gitlab::Regex.debian_distribution_regex }

        validates :label,
          allow_nil: true,
          format: { with: Gitlab::Regex.debian_distribution_regex }

        validates :version,
          allow_nil: true,
          format: { with: Gitlab::Regex.debian_version_regex }

        # The Valid-Until field is a security measure to prevent malicious attackers to
        # serve an outdated repository, with vulnerable packages
        # (keeping in mind that most Debian repository are not using TLS but use GPG
        # signatures instead).
        # A minimum of 24 hours is simply to avoid generating indices too often
        # (which generates load).
        # Official Debian repositories are generated 4 times a day, and valid for 7 days.
        # Full ref: https://wiki.debian.org/DebianRepository/Format#Date.2C_Valid-Until
        validates :valid_time_duration_seconds,
          allow_nil: true,
          numericality: { greater_than_or_equal_to: 24.hours.to_i }

        validates container_type, presence: true
        validates :file_store, presence: true
        validates :signed_file_store, presence: true

        scope :with_container, ->(subject) { where(container_type => subject) }
        scope :with_codename, ->(codename) { where(codename: codename) }
        scope :with_suite, ->(suite) { where(suite: suite) }
        scope :with_codename_or_suite, ->(codename_or_suite) { with_codename(codename_or_suite).or(with_suite(codename_or_suite)) }

        mount_file_store_uploader Packages::Debian::DistributionReleaseFileUploader
        mount_uploader :signed_file, Packages::Debian::DistributionReleaseFileUploader
        after_save :update_signed_file_store, if: :saved_change_to_signed_file?

        def component_names
          components.pluck(:name).sort
        end

        def architecture_names
          architectures.pluck(:name).sort
        end

        def needs_update?
          !file.exists? || time_duration_expired?
        end

        private

        def time_duration_expired?
          return false unless valid_time_duration_seconds.present?

          updated_at + valid_time_duration_seconds.seconds + 6.hours < Time.current
        end

        def unique_codename_and_suite
          errors.add(:codename, _('has already been taken as Suite')) if codename_exists_as_suite?
          errors.add(:suite, _('has already been taken as Codename')) if suite_exists_as_codename?
        end

        def codename_exists_as_suite?
          return false unless codename.present?

          self.class.with_container(container).with_suite(codename).exists?
        end

        def suite_exists_as_codename?
          return false unless suite.present?

          self.class.with_container(container).with_codename(suite).exists?
        end

        def update_signed_file_store
          # The signed_file.object_store is set during `uploader.store!`
          # which happens after object is inserted/updated
          self.update_column(:signed_file_store, signed_file.object_store)
        end
      end
    end
  end
end
