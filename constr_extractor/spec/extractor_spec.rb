# rspec doc: http://rspec.info/documentation/
require_relative "../extractor"
require_relative "../constraint"
require_relative "../file"
require_relative "./util"

RSpec.configure do |c|
  c.extend SpecUtil
end

RSpec.describe Extractor do
  describe "extractUser" do
    builtin_constraints = getUserBuiltinConstraints()
    user_constraints = builtin_constraints.select { |c| c.class_name == "User" }
    it { expect(user_constraints.length).to eql 10 }

    user_length_constraints = user_constraints.select { |c| c.is_a? LengthConstraint }
    it { expect(user_length_constraints.length).to eql 4 }

    user_presence_constraints = user_constraints.select { |c| c.is_a? PresenceConstraint }
    it { expect(user_presence_constraints.length).to eql 3 }

    user_format_constraints = user_constraints.select { |c| c.is_a? FormatConstraint }
    it { expect(user_format_constraints.length).to eql 1 }

    user_unique_constraints = user_constraints.select { |c| c.is_a? UniqueConstraint }
    it { expect(user_unique_constraints.length).to eql 1 }

    anonymous_user_constraints = builtin_constraints.select { |c| c.class_name == "AnonymousUser" }
    it { expect(anonymous_user_constraints.length).to eql 0 }
  end

  describe "extractVersion" do
    builtin_constraints = getVersionBuiltinConstraints()
    version_constraints = builtin_constraints.select { |c| c.class_name == "Version" }
    it { expect(version_constraints.length).to eql 10 }

    version_length_constraints = version_constraints.select { |c| c.is_a? LengthConstraint }
    it { expect(version_length_constraints.length).to eql 3 }

    version_presence_constraints = version_constraints.select { |c| c.is_a? PresenceConstraint }
    it { expect(version_presence_constraints.length).to eql 1 }

    version_format_constraints = version_constraints.select { |c| c.is_a? FormatConstraint }
    it { expect(version_format_constraints.length).to eql 0 }

    version_unique_constraints = version_constraints.select { |c| c.is_a? UniqueConstraint }
    it { expect(version_unique_constraints.length).to eql 1 }
  end

  describe "extractLength" do
    user_constraints = getUserBuiltinConstraints().select { |c| c.class_name == "User" }
    user_firstname_len_constraint = user_constraints.select { |c| c.is_a?(LengthConstraint) && c.field_name == "firstname" }[0]
    it { expect(user_firstname_len_constraint.max).to eql 30 }
    it { expect(user_firstname_len_constraint.min).to eql nil }

    user_lastname_len_constraint = user_constraints.select { |c| c.is_a?(LengthConstraint) && c.field_name == "lastname" }[0]
    it { expect(user_lastname_len_constraint.max).to eql 30 }
    it { expect(user_firstname_len_constraint.min).to eql nil }

    user_identity_len_constraint = user_constraints.select { |c| c.is_a?(LengthConstraint) && c.field_name == "identity_url" }[0]
    it { expect(user_identity_len_constraint.max).to eql 255 }
    it { expect(user_identity_len_constraint.min).to eql nil }

    version_constraints = getVersionBuiltinConstraints().select { |c| c.class_name == "Version" }
    version_name_len_constraint = version_constraints.select { |c| c.is_a?(LengthConstraint) && c.field_name == "name" }[0]
    it { expect(version_name_len_constraint.max).to eql 60 }
    it { expect(version_name_len_constraint.min).to eql nil }
  end

  describe "extractUnique" do
    user_unqie_constraints = getUserBuiltinConstraints().select { |c| c.class_name == "User" && c.is_a?(UniqueConstraint) }
    it { expect(user_unqie_constraints.length).to eql 1 }
    user_login_unqie_constraints = user_unqie_constraints[0]
    it { expect(user_login_unqie_constraints.field_name).to eql "login" }
    it { expect(user_login_unqie_constraints.case_sensitive).to eql false }
    it { expect(user_login_unqie_constraints.cond).not_to be nil }

    version_unique_constraints = getVersionBuiltinConstraints().select { |c| c.class_name == "Version" && c.is_a?(UniqueConstraint) }
    it { expect(version_unique_constraints.length).to eql 1 }
    version_name_unique_constraint = version_unique_constraints[0]
    it { expect(version_name_unique_constraint.field_name).to eql "name" }
    it { expect(version_name_unique_constraint.scope.length).to eql 1 }
    it { expect(version_name_unique_constraint.scope[0]).to eql "project_id" }
  end

  describe "extractInclusion" do
  end

  describe "extractPresence" do
    user_presence_constraints = getUserBuiltinConstraints().select { |c| c.class_name == "User" && c.is_a?(PresenceConstraint) }
    it { expect(user_presence_constraints.length).to eql 3 }
    user_login_presence_constraint = user_presence_constraints.select { |c| c.field_name == "login" }[0]
    it { expect(user_login_presence_constraint.cond).not_to be nil }
  end

  describe "only extract from ActiveRecord" do
    filename = "spec/test_data/redmine_models/custom_field_value.rb"
    constraints = getFileBultinConstraints(filename)
    it { expect(constraints.length).to eql 0 }
  end

  describe "extract Class Inheritance" do
    f0 = ConstraintFile.new("spec/test_data/redmine_models/user.rb")
    f1 = ConstraintFile.new("spec/test_data/redmine_models/principal.rb")
    f2 = ConstraintFile.new("spec/test_data/redmine_models/group.rb")
    f3 = ConstraintFile.new("spec/test_data/redmine_models/group_builtin.rb")
    f4 = ConstraintFile.new("spec/test_data/redmine_models/group_anonymous.rb")
    f5 = ConstraintFile.new("spec/test_data/redmine_models/group_non_member.rb")
    constraint_files = [f0, f1, f2, f3, f4, f5]
    extractor = Extractor.new([:inheritance])
    constraints = extractor.extractClassInheritance(constraint_files)
    constraints.each { |c| puts c.to_string }
    it { expect(constraints.length).to eql 1 }
  end
end
