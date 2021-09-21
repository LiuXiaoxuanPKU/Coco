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
end
