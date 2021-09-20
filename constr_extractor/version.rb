class Version
  # app_dir: application directory
  # commit: commit hash, which version we want to extract constraints from
  # rules: types of constraints to extract
  def initialize(app_dir, commit, rules)
    @app_dir = app_dir
    @commit = commit.strip
    @files = FileReader.read(app_dir)
    @extractor = Extractor.new
    extractor.setRule(rules)
  end

  def getDBConstraints
    @constraints = extractor.extractAll(@files) # need to be changed in the future
    @db_constraints
  end

  def getModelConstraints
    @constraints = extractor.extractAll(@files) # need to be changed in the future
    @model_constraints
  end

  ########################## Private methods begin here #####################
  private
end
