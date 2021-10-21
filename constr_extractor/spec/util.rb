module SpecUtil
  def getFileBultinConstraints(filename)
    file = FileReader.readFile(filename)
    extractor = Extractor.new([])
    builtin_constraints = extractor.extractBuiltin([file])
    return builtin_constraints
  end

  def getUserBuiltinConstraints
    filename = "spec/test_data/redmine_models/user.rb"
    return getFileBultinConstraints(filename)
  end

  def getVersionBuiltinConstraints
    filename = "spec/test_data/redmine_models/version.rb"
    return getFileBultinConstraints(filename)
  end
end
