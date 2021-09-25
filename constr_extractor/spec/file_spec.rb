# rspec doc: http://rspec.info/documentation/
require_relative "../file"

RSpec.describe FileReader do
  context "#readDir" do
    # dirname = "spec/test_data/redmine_models/"
    # constraint_files = FileReader.readDir(dirname)
    # cmd = "find #{dirname} -type f | wc -l"
    # re = %x(#{cmd})
    # it { expect(constraint_files.length).to eql re.to_i }
  end

  context "#readFile" do
    filename = "spec/test_data/redmine_models/user.rb"
    it { expect(FileReader.readFile(filename)).not_to be nil }
  end
end
