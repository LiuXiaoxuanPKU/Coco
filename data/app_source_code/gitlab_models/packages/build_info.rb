# frozen_string_literal: true

class Packages::BuildInfo < ApplicationRecord
  belongs_to :package, inverse_of: :build_infos
  belongs_to :pipeline, class_name: 'Ci::Pipeline'
end
