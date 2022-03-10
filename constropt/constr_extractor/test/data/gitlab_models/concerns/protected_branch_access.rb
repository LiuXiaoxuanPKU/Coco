# frozen_string_literal: true

module ProtectedBranchAccess
  extend ActiveSupport::Concern
  include ProtectedRefAccess

  included do
    belongs_to :protected_branch

    delegate :project, to: :protected_branch
  end

  def check_access(user)
    return false if access_level == Gitlab::Access::NO_ACCESS

    super
  end
end
