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
  class QueryExporter < Exports::Exporter
    self.model = WorkPackage

    alias :query :object

    attr_reader :column_objects, :columns, :work_packages

    def initialize(object, options = {})
      super

      @column_objects = get_columns
      @columns = column_objects.map { |c| { name: c.name, caption: c.caption } }
      @work_packages = get_work_packages
    end

    def get_columns
      query
        .columns
        .reject { |c| c.is_a?(Queries::WorkPackages::Columns::RelationColumn) }
    end

    def page
      options[:page] || 1
    end

    def get_work_packages
      query
        .results
        .work_packages
        .page(page)
        .per_page(Setting.work_packages_export_limit.to_i)
    end
  end
end
