
    require_relative "./version.rb"
    commit = "master"
    v = Version.new('spec/test_data/', 'master', [:builtin, :inheritance])
    constraints = v.getModelConstraints()
    File.open('/home/ubuntu/ConstrOpt/constraints/redmine', "w") do |f|
      JSON.dump(constraints, f)
    end
    puts "===========Extract #{constraints.length} constraints==========="
    