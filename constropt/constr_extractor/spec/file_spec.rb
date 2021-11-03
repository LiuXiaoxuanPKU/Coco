# rspec doc: http://rspec.info/documentation/
require_relative "../file"
require_relative "./util"

RSpec.configure do |c|
  c.extend SpecUtil
end

RSpec.describe FileReader do
  context "#readDir" do
    dirname = "spec/test_data/redmine_models/"
    constraint_files = FileReader.readDir(dirname)
    cmd = "find #{dirname} -type f | wc -l"
    re = %x(#{cmd})
    it { expect(constraint_files.length).to eql re.to_i }
  end

  context "#readFile" do
    filename = "spec/test_data/redmine_models/user.rb"
    f0 = FileReader.readFile(filename)
    it { expect(f0).not_to be nil }
    user_class = f0.classes.select { |c| c.name == "User" }[0]
    constants = user_class.constants
    it { expect(constants.length).to equal 5 }
    it { expect(constants["LOGIN_LENGTH_LIMIT"].to_i).to equal 60 }
    it { expect(constants["MAIL_LENGTH_LIMIT"].to_i).to equal 60 }
  end

  context "#toposort" do
    f0 = ConstraintFile.new("spec/test_data/redmine_models/user.rb")
    f1 = ConstraintFile.new("spec/test_data/redmine_models/principal.rb")
    f2 = ConstraintFile.new("spec/test_data/redmine_models/group.rb")
    f3 = ConstraintFile.new("spec/test_data/redmine_models/group_builtin.rb")
    f4 = ConstraintFile.new("spec/test_data/redmine_models/group_anonymous.rb")
    f5 = ConstraintFile.new("spec/test_data/redmine_models/group_non_member.rb")
    order = FileReader.toposort([f0, f1, f2, f3, f4, f5])
    puts "#{order}"
    puts "==========================="
    activerecord_order_num = findVisitOrder(order, "ActiveRecord::Base")
    principal_order_num = findVisitOrder(order, "Principal")
    user_order_num = findVisitOrder(order, "User")
    group_order_num = findVisitOrder(order, "Group")
    group_anonynous_num = findVisitOrder(order, "GroupAnonymous")
    group_builtin_num = findVisitOrder(order, "GroupBuiltin")
    group_non_member_num = findVisitOrder(order, "GroupNonMember")
    it { expect(activerecord_order_num).to eq 0 }
    it { expect(principal_order_num).to eq 1 }
    it { user_order_num.should be > principal_order_num }
    it { group_order_num.should be > principal_order_num }
    it { group_non_member_num.should be > group_order_num }
    it { group_builtin_num.should be > group_order_num }
    it { group_anonynous_num.should be > group_order_num }
  end

  context "#getInheritanceDic" do
    f0 = ConstraintFile.new("spec/test_data/redmine_models/user.rb")
    f1 = ConstraintFile.new("spec/test_data/redmine_models/principal.rb")
    f2 = ConstraintFile.new("spec/test_data/redmine_models/group.rb")
    f3 = ConstraintFile.new("spec/test_data/redmine_models/group_builtin.rb")
    f4 = ConstraintFile.new("spec/test_data/redmine_models/group_anonymous.rb")
    f5 = ConstraintFile.new("spec/test_data/redmine_models/group_non_member.rb")
    constraint_files = [f0, f1, f2, f3, f4, f5]
    order = FileReader.toposort(constraint_files)
    h = FileReader.getInheritanceDic(order, constraint_files)
    expect_ret = { "ActiveRecord::Base" => [{ "Principal" => [{ "Group" => [{ "GroupBuiltin" => ["GroupNonMember", "GroupAnonymous"] }] }, { "User" => ["AnonymousUser"] }] }] }
    it { expect(h).to eq expect_ret }
  end
end
