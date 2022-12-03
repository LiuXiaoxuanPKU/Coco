# frozen_string_literal: true

class UserFieldOption < ActiveRecord::Base
  belongs_to :user_field
end

# == Schema Information
#
# Table name: user_field_options
#
#  id            :integer          not null, primary key
#  user_field_id :integer          not null
#  value         :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
