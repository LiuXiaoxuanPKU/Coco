require 'test/unit'
require_relative '../constraint'

class TestBulitin < Test::Unit::TestCase
    def test_inclusion
        in_c1 = InclusionConstraint.new('t1', [1, 2, 3], 'builtin', false)
        in_c2 = InclusionConstraint.new('t1', [1, 2], 'builtin', false)
        in_c3 = InclusionConstraint.new('t1', [1, 2, 3], 'polymorphic', false)
        in_c4 = InclusionConstraint.new('t1', [1, 2, 3], 'builtin', false)
        constraints = [in_c1, in_c2, in_c3, in_c4].uniq
        exp = 3 
        raise "Expect get #{exp} inclusion constraints, get #{constraints.length}" unless constraints.length == exp
    end

    def test_unique
        uniq_c1 = UniqueConstraint.new(["t1"], nil, false, "builtin", false)
        uniq_c2 = UniqueConstraint.new(["t1"], "class=A", false, "builtin", false)
        uniq_c3 = UniqueConstraint.new(["t1"], nil, true, "builtin", false)
        uniq_c4 = UniqueConstraint.new(["t1"], nil, false, "builtin", true)
        uniq_c5 = UniqueConstraint.new(["t1"], nil, false, "builtin", false)
        constraints = [uniq_c1, uniq_c2, uniq_c3, uniq_c4, uniq_c5].uniq
        exp = 4 
        raise "Expect get #{exp} inclusion constraints, get #{constraints.length}" unless constraints.length == exp
    end

    def test_presence
        p1 = PresenceConstraint.new("t1", nil, true)
        p2 = PresenceConstraint.new("t1", nil, false)
        p3 = PresenceConstraint.new("t1", "class=A", true)
        p4 = PresenceConstraint.new("t1", nil, false)
        constraints = [p1, p2, p3, p4].uniq
        exp = 3
        raise "Expect get #{exp} inclusion constraints, get #{constraints.length}" unless constraints.length == exp
    end

    def test_length
        l1 = LengthConstraint.new("t1", 1, 10, false)
        l2 = LengthConstraint.new("t1", 1, 5, false)
        l3 = LengthConstraint.new("t1", 1, nil, false)
        l4 = LengthConstraint.new("t1", 1, 10, false)
        constraints = [l1, l2, l3, l4].uniq
        exp = 3
        raise "Expect get #{exp} inclusion constraints, get #{constraints.length}" unless constraints.length == exp
    end

    def test_mix1
        c1 = InclusionConstraint.new('t1', [1, 2, 3], 'builtin', false)
        c2 = LengthConstraint.new("t1", 1, 10, false)
        c3 = PresenceConstraint.new("t1", nil, true)
        constraints = [c1, c2, c3].uniq
        exp = 3
        raise "Expect get #{exp} inclusion constraints, get #{constraints.length}" unless constraints.length == exp
    end

    def test_mix2
        c1 = InclusionConstraint.new('t1', [1, 2, 3], 'builtin', false)
        c2 = LengthConstraint.new("t1", 1, 10, false)
        c3 = PresenceConstraint.new("t1", nil, true)
        c4 = InclusionConstraint.new('t1', [1, 2, 3], 'builtin', false)
        constraints = [c1, c2, c3, c4].uniq
        exp = 3
        raise "Expect get #{exp} inclusion constraints, get #{constraints.length}" unless constraints.length == exp
    end
end