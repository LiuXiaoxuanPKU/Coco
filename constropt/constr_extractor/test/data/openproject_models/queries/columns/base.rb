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

class Queries::Columns::Base
  attr_reader :groupable,
              :sortable

  attr_accessor :name,
                :sortable_join,
                :summable,
                :default_order,
                :association

  attr_writer :null_handling,
              :summable_select,
              :summable_work_packages_select

  def initialize(name, options = {})
    self.name = name

    %i(sortable
       sortable_join
       groupable
       summable
       summable_select
       summable_work_packages_select
       association
       null_handling
       default_order).each do |attribute|
      send("#{attribute}=", options[attribute])
    end
  end

  def sortable_join_statement(_query)
    sortable_join
  end

  def caption
    raise NotImplementedError
  end

  def null_handling(_asc)
    @null_handling
  end

  def groupable=(value)
    @groupable = name_or_value_or_false(value)
  end

  def sortable=(value)
    @sortable =  name_or_value_or_false(value)
  end

  # Returns true if the column is sortable, otherwise false
  def sortable?
    !!sortable
  end

  # Returns true if the column is groupable, otherwise false
  def groupable?
    !!groupable
  end

  def summable?
    summable || @summable_select || @summable_work_packages_select
  end

  def summable_select
    @summable_select || name
  end

  def summable_work_packages_select
    if @summable_work_packages_select == false
      nil
    elsif @summable_work_packages_select
      @summable_work_packages_select
    elsif summable&.respond_to?(:call)
      nil
    else
      name
    end
  end

  def value(model)
    model.send name
  end

  def self.instances(_context = nil)
    new
  end

  protected

  def name_or_value_or_false(value)
    # This is different from specifying value = nil in the signature
    # in that it will also set the value to false if nil is provided.
    value ||= false

    # Explicitly checking for true because apparently, we do not want
    # truish values to count here.
    if value == true
      name.to_s
    else
      value
    end
  end
end
