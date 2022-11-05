require 'test/unit'

require_relative '../constraint'
require_relative '../engine'
require_relative '../traversor'
require_relative '../db_extractor'

class TestBulitin < Test::Unit::TestCase
  def test_app
    app_unique_stats = {}
    app_unique_stats['forem'] = 83

    appname = 'forem'
    engine = Engine.new("#{__dir__}/../../data/app_source_code/#{appname}_models")
    root = engine.run
    db_extractor = DBExtractor.new("#{__dir__}/../../data/app_source_code/#{appname}_db/schema.rb")
    t = Traversor.new(db_extractor)
    t.traverse(root)

    constraints = db_extractor.table_dbconstraint_map.values.flatten(1)
    unique_c = constraints.select { |c| c.is_a? UniqueConstraint }
    unless unique_c.length == app_unique_stats[appname]
      raise "Expect #{app_unique_stats[appname]} unique constraints defined in DB,\
          get #{unique_c.length}"
    end
  end
end
