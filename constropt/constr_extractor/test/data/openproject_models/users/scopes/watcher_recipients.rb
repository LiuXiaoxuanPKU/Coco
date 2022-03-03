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
# See COPYRIGHT and LICENSE files for more details.
#++

# Returns a scope of users watching the instance that should be notified via whatever channel upon updates to the instance.
# The users need to have the necessary permissions to see the instance as defined by the watchable_permission.
# Additionally, the users need to have their mail notification setting set to watched: true.
module Users::Scopes
  module WatcherRecipients
    extend ActiveSupport::Concern

    class_methods do
      def watcher_recipients(model)
        model
          .possible_watcher_users
          .where(id: NotificationSetting
                       .applicable(model.project)
                       .where(watched: true, user_id: model.watcher_users)
                       .select(:user_id))
      end
    end
  end
end
