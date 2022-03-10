# frozen_string_literal: true

class ProjectAuthorization < ApplicationRecord
  extend SuppressCompositePrimaryKeyWarning
  include FromUnion

  belongs_to :user
  belongs_to :project

  validates :project, presence: true
  validates :access_level, inclusion: { in: Gitlab::Access.all_values }, presence: true
  validates :user, uniqueness: { scope: [:project, :access_level] }, presence: true

  def self.select_from_union(relations)
    from_union(relations)
      .select(['project_id', 'MAX(access_level) AS access_level'])
      .group(:project_id)
  end

  # This method overrides its ActiveRecord's version in order to work correctly
  # with composite primary keys and fix the tests for Rails 6.1
  #
  # Consider using BulkInsertSafe module instead since we plan to refactor it in
  # https://gitlab.com/gitlab-org/gitlab/-/issues/331264
  def self.insert_all(attributes)
    super(attributes, unique_by: connection.schema_cache.primary_keys(table_name))
  end

  def self.insert_all_in_batches(attributes, per_batch = 1000)
    attributes.each_slice(per_batch) do |attributes_batch|
      insert_all(attributes_batch)
    end
  end
end

ProjectAuthorization.prepend_mod_with('ProjectAuthorization')
