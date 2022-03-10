# frozen_string_literal: true

module Ci
  class BuildNeed < Ci::ApplicationRecord
    include BulkInsertSafe

    belongs_to :build, class_name: "Ci::Processable", foreign_key: :build_id, inverse_of: :needs

    validates :build, presence: true
    validates :name, presence: true, length: { maximum: 128 }
    validates :optional, inclusion: { in: [true, false] }

    scope :scoped_build, -> { where('ci_builds.id=ci_build_needs.build_id') }
    scope :artifacts, -> { where(artifacts: true) }
  end
end
