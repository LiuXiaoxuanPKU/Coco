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

class CustomActions::Actions::Serializer
  def self.load(value)
    return [] unless value

    YAML
      .safe_load(value, permitted_classes: [Symbol])
      .map do |key, values|
      klass = nil

      CustomActions::Register
        .actions
        .detect do |a|
        klass = a.for(key)
      end

      klass ||= CustomActions::Actions::Inexistent

      klass.new(values)
    end.compact
  end

  def self.dump(actions)
    YAML::dump(actions.map { |a| [a.key, a.values.map(&:to_s)] })
  end
end
