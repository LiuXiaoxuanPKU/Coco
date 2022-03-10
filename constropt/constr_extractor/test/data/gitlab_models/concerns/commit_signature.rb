# frozen_string_literal: true
module CommitSignature
  extend ActiveSupport::Concern

  included do
    include ShaAttribute

    sha_attribute :commit_sha

    enum verification_status: {
      unverified: 0,
      verified: 1,
      same_user_different_email: 2,
      other_user: 3,
      unverified_key: 4,
      unknown_key: 5,
      multiple_signatures: 6
    }

    belongs_to :project, class_name: 'Project', foreign_key: 'project_id', optional: false

    validates :commit_sha, presence: true
    validates :project_id, presence: true

    scope :by_commit_sha, ->(shas) { where(commit_sha: shas) }
  end

  class_methods do
    def safe_create!(attributes)
      create_with(attributes)
        .safe_find_or_create_by!(commit_sha: attributes[:commit_sha])
    end

    # Find commits that are lacking a signature in the database at present
    def unsigned_commit_shas(commit_shas)
      return [] if commit_shas.empty?

      signed = by_commit_sha(commit_shas).pluck(:commit_sha)
      commit_shas - signed
    end
  end

  def commit
    project.commit(commit_sha)
  end

  def user
    commit.committer
  end
end
