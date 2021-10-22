
    require_relative "./version.rb"
    commit = "master"
    v = Version.new('spec/test_data/', 'master', [:builtin, :inheritance])
    constraints = v.getModelConstraints()
    File.open('/Users/xiaoxuanliu/Documents/UCB/fall2021/ConstrOpt/experiment/constraints/redmine', "w") do |f|
      JSON.dump(constraints, f)
    end
    puts "===========Extract #{constraints.length} constraints==========="
    