# rspec doc: http://rspec.info/documentation/
require_relative "../extractor"
require_relative "../constraint"
require_relative "../file"

RSpec.describe Extractor do
  context "#readFile" do
    filename = "spec/test_data/redmine_models/user.rb"
    file = FileReader.readFile(filename)
    extractor = Extractor.new([])
    builtin_constraints = extractor.extractBuiltin([file])
    user_constraints = builtin_constraints.select { |c| c.class_name == "User" }
    it { expect(user_constraints.length).to eql 7 }

    user_length_constraints = user_constraints.select { |c| c.is_a? LengthConstraint }
    user_unique_constraints = user_constraints.select { |c| c.is_a? UniqueConstraint }
    it { expect(user_length_constraints.length).to eql 4 }
    it { expect(user_unique_constraints.length).to eql 1 }

    anonymous_user_constraints = builtin_constraints.select { |c| c.class_name == "AnonymousUser" }
    it { expect(anonymous_user_constraints.length).to eql 0 }
  end
end
