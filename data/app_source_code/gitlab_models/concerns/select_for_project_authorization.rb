# frozen_string_literal: true

module SelectForProjectAuthorization
  extend ActiveSupport::Concern

  class_methods do
    def select_for_project_authorization
      select("projects.id AS project_id", "members.access_level")
    end

    def select_as_maintainer_for_project_authorization
      select(["projects.id AS project_id", "#{Gitlab::Access::MAINTAINER} AS access_level"])
    end
  end
end
