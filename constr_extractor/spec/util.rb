module SpecUtil
  def getFileBultinConstraints(filename)
    file = FileReader.readFile(filename)
    extractor = Extractor.new([:builtin])
    builtin_constraints = extractor.extractAll([file])
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

  def findVisitOrder(order, name)
    order.each_with_index { |o, i|
      if o == name
        return i
      end
    }
    puts "[Error] #{name} does not exist in order #{order}"
    raise
  end
end
