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
module WorkPackage::Exports
  module Formatters
    class EstimatedHours < ::Exports::Formatters::Default
      def self.apply?(name)
        name == :estimated_hours
      end

      ##
      # Takes a WorkPackage and a QueryColumn and returns the value to be exported.
      def format(work_package, **)
        estimated_hours = work_package.estimated_hours
        derived_hours = formatted_derived_hours(work_package)

        if estimated_hours.nil? || derived_hours.nil?
          return estimated_hours || derived_hours
        end

        "#{estimated_hours} #{derived_hours}"
      end

      private

      def formatted_derived_hours(work_package)
        if (derived_estimated_value = work_package.derived_estimated_hours)
          "(#{derived_estimated_value})"
        end
      end
    end
  end
end
