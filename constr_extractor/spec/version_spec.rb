# rspec doc: http://rspec.info/documentation/
require_relative "../version"

RSpec.describe Version do
  context "#endToend" do
    rules = [:builtin]
    app_dir = "spec/test_data/redmine_models/"
    commit = "master"
    v = Version.new(app_dir, commit, rules)
    constraints = v.getModelConstraints()
    puts "===========Extract #{constraints.length} constraints==========="
    # constraints.each { |c| puts c.to_string }
  end
end
