# frozen_string_literal: true

class PostSearchData < ActiveRecord::Base
  include HasSearchData
end

# == Schema Information
#
# Table name: post_search_data
#
#  post_id         :integer          not null, primary key
#  search_data     :tsvector
#  raw_data        :text
#  locale          :string
#  version         :integer          default(0)
#  private_message :boolean          not null
#
# Indexes
#
#  idx_recent_regular_post_search_data                       (search_data) WHERE ((NOT private_message) AND (post_id >= 0)) USING gin
#  idx_search_post                                           (search_data) USING gin
#  index_post_search_data_on_post_id_and_version_and_locale  (post_id,version,locale)
#
