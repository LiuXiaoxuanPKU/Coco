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

class WorkPackage::PDFExport::WorkPackageToPdf < ::Exports::Exporter
  include WorkPackage::PDFExport::Common
  include WorkPackage::PDFExport::Formattable
  include WorkPackage::PDFExport::Attachments

  attr_accessor :pdf, :columns

  self.model = WorkPackage

  alias :work_package :object

  def self.key
    :pdf
  end

  def initialize(work_package, _options = {})
    super

    self.pdf = get_pdf(current_language)
    self.columns = ::Query.available_columns(work_package.project)

    configure_markup
  end

  def export!
    write_attributes!
    write_changesets!
    write_history!
    write_attachments!
    write_footers!

    success(pdf.render)
  end

  def make_attribute_row(first_attribute, second_attribute)
    [
      make_attribute_cells(
        first_attribute,
        label_options: {
          borders: [:left], font_style: :bold, padding: cell_padding
        },
        value_options: {
          borders: [], padding: cell_padding
        }
      ),
      make_attribute_cells(
        second_attribute,
        label_options: {
          borders: [:left], font_style: :bold, padding: cell_padding
        },
        value_options: {
          borders: [:right], padding: cell_padding
        }
      )
    ]
      .flatten
  end

  def make_attribute_cells(attribute, label_options: {}, value_options: {})
    label = pdf.make_cell(
      WorkPackage.human_attribute_name(attribute) + ':',
      label_options
    )

    column = columns.find { |col| col.name == attribute.to_sym }
    formatter = formatter_for(column.name)
    value_content = formatter.format(work_package)
    value = pdf.make_cell(value_content.to_s, value_options)

    [label, value]
  end

  def make_attributes
    attrs = [
      %i[status priority],
      %i[author category],
      %i[created_at assigned_to],
      %i[updated_at due_date]
    ]

    attrs.map do |first, second|
      make_attribute_row first, second
    end
  end

  def make_plain_custom_fields
    work_package.custom_field_values.each do |custom_value|
      next if custom_value.custom_field.formattable?

      cf = custom_value.custom_field
      name = cf.name || Array(cf.name_translations.first).last || '?'

      label = pdf.make_cell "#{name}:",
                            borders: [:left], font_style: :bold,
                            padding: cell_padding
      value = pdf.make_cell show_value(custom_value),
                            colspan: 3,
                            borders: [:right],
                            padding: cell_padding
      yield [label, value]
    end
  end

  def show_changesets?
    work_package.changesets.any? &&
      User.current.allowed_to?(:view_changesets, work_package.project)
  end

  def newline!
    pdf.move_down 4
  end

  def max_width
    pdf.bounds.width
  end

  def column_widths
    [0.2, 0.3, 0.2, 0.3].map do |factor|
      max_width * factor
    end
  end

  def formattable_colspan
    3
  end

  def write_footers!
    pdf.number_pages format_date(Date.today),
                     at: [pdf.bounds.left, 0],
                     style: :italic

    pdf.number_pages "<page>/<total>",
                     at: [pdf.bounds.right - 25, 0],
                     style: :italic
  end

  def write_title!
    pdf.title = heading
    pdf.font style: :bold, size: 11
    pdf.text "#{heading}: #{work_package.subject}"
    pdf.move_down 20
  end

  def heading
    "#{work_package.project} - ##{work_package.type} #{work_package.id}"
  end

  def title
    "#{heading}.pdf"
  end

  def write_attributes!
    write_title!

    data = make_attributes

    data.first.each { |cell| cell.borders << :top } # top horizontal line
    data.last.each { |cell| cell.borders << :bottom } # horizontal line after main attrs

    # Render plain custom values
    make_plain_custom_fields { |row| data << row }

    pdf.font style: :normal, size: 9
    pdf.table(data, column_widths: column_widths)

    # Render formattable custom values
    work_package.custom_field_values
                .select { |cv| cv.custom_field.formattable? }
                .each do |custom_value|

      write_formattable! work_package,
                         markdown: custom_value.value,
                         label: custom_value.custom_field.name
    end

    write_formattable! work_package,
                       markdown: work_package.description,
                       label: WorkPackage.human_attribute_name(:description)
  end

  def write_changesets!
    if show_changesets?
      newline!

      pdf.font style: :bold, size: 9
      pdf.text I18n.t(:label_associated_revisions)
      pdf.stroke do
        pdf.horizontal_rule
      end
      newline!

      work_package.changesets.each do |changeset|
        pdf.font style: :bold, size: 8
        pdf.text(format_time(changeset.committed_on) + ' - ' + changeset.author.to_s)
        newline!

        if changeset.comments.present?
          pdf.font style: :normal, size: 8
          pdf.text changeset.comments.to_s
        end

        newline!
      end
    end
  end

  def write_history!
    pdf.move_down(pdf.font_size * 2)

    pdf.font style: :bold, size: 9
    pdf.text I18n.t(:label_history)
    pdf.stroke do
      pdf.horizontal_rule
    end

    newline!

    work_package.journals.includes(:user).order("#{Journal.table_name}.created_at ASC").each do |journal|
      next if journal.initial?

      pdf.font style: :bold, size: 8
      pdf.text(format_time(journal.created_at) + ' - ' + journal.user.name)
      newline!

      pdf.font style: :italic, size: 8
      journal.details.each do |detail|
        text = journal
          .render_detail(detail, no_html: true, only_path: false)
          .gsub(/\((https?[^)]+)\)$/, "(<link href='\\1'>\\1</link>)")

        pdf.text('- ' + text, inline_format: true)
        newline!
      end

      if journal.notes?
        newline! unless journal.details.empty?

        pdf.font style: :normal, size: 8

        pdf.markup(format_text(journal.notes.to_s, object: work_package, format: :html))
      end

      newline!
    end
  end

  def write_attachments!
    if work_package.attachments.any?
      pdf.move_down(pdf.font_size * 2)

      pdf.font style: :bold, size: 9
      pdf.text I18n.t(:label_attachment_plural)
      pdf.stroke do
        pdf.horizontal_rule
      end
      newline!

      pdf.font style: :normal, size: 8

      data = work_package.attachments.map do |attachment|
        [
          attachment.filename,
          number_to_human_size(attachment.filesize, precision: 3),
          format_date(attachment.created_at),
          attachment.author.name
        ]
      end

      table_width = max_width
      pdf.table(data, width: table_width - 1) do
        cells.padding = [2, 5, 2, 5]
        cells.borders = []

        column(0).width = (table_width * 0.5).to_i
        column(1).align = :right
        column(3).align = :right
      end
    end
  end
end
