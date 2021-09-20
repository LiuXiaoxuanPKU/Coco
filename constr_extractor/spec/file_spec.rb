# rspec doc: http://rspec.info/documentation/
require_relative "../file"

RSpec.describe FileReader do
  context "#readFile" do
    filename = "spec/test_data/redmine_models/user.rb"
    it { expect(FileReader.readFile(filename)).to eql true }
  end
end
