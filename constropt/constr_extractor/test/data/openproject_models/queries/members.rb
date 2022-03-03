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

module Queries::Members
  query = Queries::Members::MemberQuery
  filter_ns = Queries::Members::Filters

  Queries::Register.filter query, filter_ns::NameFilter
  Queries::Register.filter query, filter_ns::AnyNameAttributeFilter
  Queries::Register.filter query, filter_ns::ProjectFilter
  Queries::Register.filter query, filter_ns::StatusFilter
  Queries::Register.filter query, filter_ns::BlockedFilter
  Queries::Register.filter query, filter_ns::GroupFilter
  Queries::Register.filter query, filter_ns::RoleFilter
  Queries::Register.filter query, filter_ns::PrincipalFilter
  Queries::Register.filter query, filter_ns::CreatedAtFilter
  Queries::Register.filter query, filter_ns::UpdatedAtFilter

  order_ns = Queries::Members::Orders

  Queries::Register.order query, order_ns::DefaultOrder
  Queries::Register.order query, order_ns::NameOrder
  Queries::Register.order query, order_ns::EmailOrder
  Queries::Register.order query, order_ns::StatusOrder
end
