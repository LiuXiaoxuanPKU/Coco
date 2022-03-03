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

class Setting
  module CallbacksHelper
    # register a callback for a setting named #name
    def register_callback(name, &callback)
      # register the block with the underlying notifications system
      notifier.subscribe(notification_event_for(name), &callback)
    end
    # register_callback is not used anymore in our code
    # it can be removed along with fire_callbacks in next major version
    OpenProject::Deprecation.deprecate_method(self, :register_callback)

    # instructs the underlying notifications system to publish all setting events for setting #name
    # based on the new and old setting objects different events can be triggered
    # currently, that's whenever a setting is set regardless whether the value changed
    def fire_callbacks(name, new_value, old_value)
      notifier.send(notification_event_for(name), value: new_value, old_value: old_value)
    end

    private

    # encapsulates the event name broadcast to all subscribers
    def notification_event_for(name)
      "setting.#{name}.changed"
    end

    # the notifier to delegate to
    def notifier
      OpenProject::Notifications
    end
  end
end
