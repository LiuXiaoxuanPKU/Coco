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

class WorkPackage::Exporter::CSV < WorkPackage::Exporter::Base
  include Redmine::I18n
  include CustomFieldsHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::NumberHelper

  def list
    serialized = CSV.generate(col_sep: I18n.t(:general_csv_separator)) do |csv|
      headers = csv_headers
      csv << self.class.encode_csv_columns(headers)

      work_packages.each do |work_package|
        row = csv_row(work_package)
        csv << self.class.encode_csv_columns(row)
      end
    end

    yield success(serialized)
  end

  def self.encode_csv_columns(columns, encoding = I18n.t(:general_csv_encoding))
    columns.map do |cell|
      Redmine::CodesetUtil.from_utf8(cell.to_s, encoding)
    end
  end

  private

  def success(serialized)
    WorkPackage::Exporter::Result::Success
      .new format: :csv,
           title: title,
           content: serialized,
           mime_type: 'text/csv'
  end

  def title
    title = query.new_record? ? I18n.t(:label_work_package_plural) : query.name

    "#{title}.csv"
  end

  # fetch all headers
  def csv_headers
    headers = []

    valid_export_columns.each_with_index do |column, _|
      headers << column.caption
    end

    headers << CustomField.human_attribute_name(:description)

    # because of
    # https://support.microsoft.com/en-us/help/323626/-sylk-file-format-is-not-valid-error-message-when-you-open-file
    if headers[0].start_with?('ID')
      headers[0] = headers[0].downcase
    end

    headers
  end

  # fetch all row values
  def csv_row(work_package)
    row = valid_export_columns.collect do |column|
      csv_format_value(work_package, column)
    end

    if row.any?
      row << if work_package.description
               work_package.description.squish
             else
               ''
             end
    end

    row
  end

  def csv_format_value(work_package, column)
    formatter = ::WorkPackage::Exporter::Formatters.for_column(column)
    formatter.format(work_package, column, array_separator: '; ')
  end
end
