# frozen_string_literal: true

class CategoryAndTopicLists
  include ActiveModel::Serialization

  attr_accessor :category_list, :topic_list
end
