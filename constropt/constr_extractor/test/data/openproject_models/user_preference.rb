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

class UserPreference < ApplicationRecord
  belongs_to :user
  serialize :others

  delegate :notification_settings, to: :user

  validates_presence_of :user
  validate :time_zone_correctness, if: -> { time_zone.present? }

  after_initialize :init_other_preferences

  def [](attr_name)
    attribute?(attr_name) ? super : others[attr_name]
  end

  def []=(attr_name, value)
    attribute?(attr_name) ? super : others[attr_name] = value
  end

  def comments_sorting
    others.fetch(:comments_sorting, OpenProject::Configuration.default_comment_sort_order)
  end

  def comments_sorting=(order)
    others[:comments_sorting] = order
  end

  def comments_in_reverse_order?
    comments_sorting == 'desc'
  end

  def self_notified?
    !others[:no_self_notified]
  end

  def self_notified=(value)
    others[:no_self_notified] = !value
  end

  def auto_hide_popups=(value)
    others[:auto_hide_popups] = to_boolean(value)
  end

  def auto_hide_popups?
    others.fetch(:auto_hide_popups) { Setting.default_auto_hide_popups? }
  end

  def warn_on_leaving_unsaved?
    # Need to cast here as previous values were '0' / '1'
    to_boolean(others.fetch(:warn_on_leaving_unsaved) { true })
  end

  def warn_on_leaving_unsaved=(value)
    others[:warn_on_leaving_unsaved] = to_boolean(value)
  end

  # Provide an alias to form builders
  alias :comments_in_reverse_order :comments_in_reverse_order?
  alias :warn_on_leaving_unsaved :warn_on_leaving_unsaved?
  alias :auto_hide_popups :auto_hide_popups?

  def comments_in_reverse_order=(value)
    others[:comments_sorting] = to_boolean(value) ? 'desc' : 'asc'
  end

  def time_zone
    self[:time_zone].presence || Setting.user_default_timezone.presence
  end

  def canonical_time_zone
    return if time_zone.nil?

    zone = ActiveSupport::TimeZone.new(time_zone)
    zone&.tzinfo&.canonical_identifier
  end

  private

  def attribute?(name)
    attr = name.to_sym
    has_attribute?(attr) || attr == :user || attr == :user_id
  end

  def to_boolean(value)
    ActiveRecord::Type::Boolean.new.cast(value)
  end

  def init_other_preferences
    self.others ||= { no_self_notified: true }
  end

  def time_zone_correctness
    errors.add(:time_zone, :inclusion) if time_zone.present? && canonical_time_zone.nil?
  end
end
