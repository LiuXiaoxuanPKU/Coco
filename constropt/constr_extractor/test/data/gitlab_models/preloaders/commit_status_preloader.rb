# frozen_string_literal: true

module Preloaders
  class CommitStatusPreloader
    CLASSES = [::Ci::Build, ::Ci::Bridge, ::GenericCommitStatus].freeze

    def initialize(statuses)
      @statuses = statuses
    end

    def execute(relations)
      preloader = ActiveRecord::Associations::Preloader.new

      CLASSES.each do |klass|
        preloader.preload(objects(klass), associations(klass, relations))
      end
    end

    private

    def objects(klass)
      @statuses.select { |job| job.is_a?(klass) }
    end

    def associations(klass, relations)
      klass.reflections.keys.map(&:to_sym) & relations.map(&:to_sym)
    end
  end
end
