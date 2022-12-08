# frozen_string_literal: true

module Users
  class ProjectCallout < ApplicationRecord
    include Users::Calloutable

    self.table_name = 'user_project_callouts'

    belongs_to :project

    enum feature_name: {
      awaiting_members_banner: 1, # EE-only
      web_hook_disabled: 2,
      ultimate_feature_removal_banner: 3,
      storage_enforcement_banner_first_enforcement_threshold: 4, # EE-only
      storage_enforcement_banner_second_enforcement_threshold: 5, # EE-only
      storage_enforcement_banner_third_enforcement_threshold: 6, # EE-only
      storage_enforcement_banner_fourth_enforcement_threshold: 7 # EE-only
    }

    validates :project, presence: true
    validates :feature_name,
              presence: true,
              uniqueness: { scope: [:user_id, :project_id] },
              inclusion: { in: ProjectCallout.feature_names.keys }
  end
end
