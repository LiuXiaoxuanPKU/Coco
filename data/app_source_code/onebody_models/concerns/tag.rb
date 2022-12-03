require 'active_support/concern'

module Concerns
  module Tag
    extend ActiveSupport::Concern

    included do
      belongs_to :site

      has_many :verses, -> { where('taggings.taggable_type' => 'Verse').order(:book, :chapter, :verse) }, through: :taggings

      validates_presence_of :name
      validates_uniqueness_of :name, scope: :site_id

      scope_by_site_id
    end

    def to_param
      name
    end
  end
end
