#-- encoding: UTF-8

#-- copyright
# OpenProject is an open source project management software.
# Copyright (C) 2012-2021 the OpenProject GmbH
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See docs/COPYRIGHT.rdoc for more details.
#++

module Projects::Scopes
  module ActivatedTimeActivity
    extend ActiveSupport::Concern

    class_methods do
      def activated_time_activity(time_entry_activity)
        join_condition = <<-SQL
          LEFT OUTER JOIN time_entry_activities_projects
            ON projects.id = time_entry_activities_projects.project_id
            AND time_entry_activities_projects.activity_id = #{time_entry_activity.id}
        SQL

        join_scope = joins(join_condition)

        result_scope = join_scope.where(time_entry_activities_projects: { active: true })

        if time_entry_activity.active?
          result_scope
            .or(join_scope.where(time_entry_activities_projects: { project_id: nil }))
        else
          result_scope
        end
      end
    end
  end
end
