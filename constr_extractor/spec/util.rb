module SpecUtil
  def getUserBuiltinConstraints
    filename = "spec/test_data/redmine_models/user.rb"
    file = FileReader.readFile(filename)
    extractor = Extractor.new([])
    builtin_constraints = extractor.extractBuiltin([file])
    return builtin_constraints
  end

  def getVersionBuiltinConstraints
    filename = "spec/test_data/redmine_models/version.rb"
    file = FileReader.readFile(filename)
    extractor = Extractor.new([])
    builtin_constraints = extractor.extractBuiltin([file])
    return builtin_constraints
  end
end
