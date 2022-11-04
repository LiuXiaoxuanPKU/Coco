class Spree::Preference < Spree::Base
  serialize :value

  validates :key, presence: true,
                  uniqueness: { case_sensitive: false, allow_blank: true, scope: spree_base_uniqueness_scope }
end
