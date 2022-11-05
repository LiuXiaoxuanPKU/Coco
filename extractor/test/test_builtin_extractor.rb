require 'yard'
require 'test/unit'

require_relative '../builtin_extractor'
require_relative '../class_node'

class TestBulitin < Test::Unit::TestCase
  def test_naive
    class_def = <<-FOO
      class Test
          validates_presence_of :login, :firstname, :lastname
      end
    FOO
    node = ClassNode.new('Test')
    node.ast = YARD::Parser::Ruby::RubyParser.parse(class_def).root[0]
    builtin_extractor = BuiltinExtractor.new
    builtin_extractor.visit(node, {})
    answer = 3
    unless node.constraints.length == answer
      raise "Get #{node.constraints.length} extracted constraints, expect #{answer}"
    end
    # puts "# of extracted constraints: #{node.constraints.length}"
  end

  def test_validates
    class_def = <<-FOO
      class Test
          validates :name,
              uniqueness: { scope: [:project_id], case_sensitive: false },
              length: { maximum: 255 }
          validates :badge_id, uniqueness: { scope: :user_id }
          validates :badge_image, presence: true
          validates :title, presence: true, uniqueness: true
          validates :type_of, inclusion: {in: %w[Announcement Welcome]}
          validates :body_markdonw, length: { in: 256 }
          validates :commentable_id, presence: true, if: :commentable_type
      end
    FOO
    node = ClassNode.new('Test')
    node.ast = YARD::Parser::Ruby::RubyParser.parse(class_def).root[0]
    builtin_extractor = BuiltinExtractor.new
    builtin_extractor.visit(node, {})
    answer = 12
    unless node.constraints.length == answer
      raise "Get #{node.constraints.length} extracted constraints, expect #{answer}"
    end
    # puts "extracted constraints: #{node.constraints}"
  end

  def test_multiple_validate
    class_def = <<-FOO
      class Test
        validates :estimated_hours, :numericality => {:greater_than_or_equal_to => 2, :allow_nil => true, :message => :invalid}
        validates :example1, :example2, :example3, :numericality => {:greater_than_or_equal_to => 2, :allow_nil => true, :message => :invalid}
      end
    FOO
    node = ClassNode.new('Test')
    node.ast = YARD::Parser::Ruby::RubyParser.parse(class_def).root[0]
    builtin_extractor = BuiltinExtractor.new
    builtin_extractor.visit(node, {})
    answer = 4
    unless node.constraints.length == answer
      raise "Get #{node.constraints.length} extracted constraints, expect #{answer}"
    end
    # puts "extracted constraints: #{node.constraints}"
  end

  def test_numerical
    class_def = <<-FOO
      class Test
        validates_inclusion_of :default_done_ratio, in: 0..100, allow_nil: true
        validates :estimated_hours, :numericality => {:greater_than_or_equal_to => 2, :allow_nil => true, :message => :invalid}
        validates_numericality_of :port, :only_integer => true, :allow_nil => true
        validates :min_length, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
        validates :experience_level, numericality: { less_than_or_equal_to: 10 }, allow_blank: true
        validates_numericality_of :timeout, :only_integer => true, :allow_blank => true
      end
    FOO
    node = ClassNode.new('Test')
    node.ast = YARD::Parser::Ruby::RubyParser.parse(class_def).root[0]
    builtin_extractor = BuiltinExtractor.new
    builtin_extractor.visit(node, {})
    answer = 7
    unless node.constraints.length == answer
      raise "Get #{node.constraints.length} extracted constraints, expect #{answer}"
    end
    # puts "extracted constraints: #{node.constraints}"
  end

  # validates :amount, numericality: true
  # only define numericality should not extract any numerical constraint since
  # it does not have a range
  def test_numerical_bool
    class_def = <<-FOO
      class Test
        validates :amount, numericality: true
      end
    FOO
    node = ClassNode.new('Test')
    node.ast = YARD::Parser::Ruby::RubyParser.parse(class_def).root[0]
    builtin_extractor = BuiltinExtractor.new
    builtin_extractor.visit(node, {})
    raise "Get #{node.constraints.length} extracted constraints, expect 1" unless node.constraints.length == 1
    raise "Get #{node.constraints.length} extracted constraints, expect 0" \
        unless node.constraints.filter { |c| c.is_a?(NumericalConstraint) }.empty?
    # puts "extracted constraints: #{node.constraints}"
  end

  def test_redmine
    class_def = <<-FOO
      class Test
        MAIL_NOTIFICATION_OPTIONS = [
          ['all', :label_user_mail_option_all],
          ['selected', :label_user_mail_option_selected],
          ['only_my_events', :label_user_mail_option_only_my_events],
          ['only_assigned', :label_user_mail_option_only_assigned],
          ['only_owner', :label_user_mail_option_only_owner],
          ['none', :label_user_mail_option_none]
        ]
        validates_presence_of :login, :firstname, :lastname, :if => Proc.new {|user| !user.is_a?(AnonymousUser)}
        validates_uniqueness_of :login, :if => Proc.new {|user| user.login_changed? && user.login.present?}, :case_sensitive => false
        validates_length_of :login, :maximum => LOGIN_LENGTH_LIMIT
        validates_length_of :firstname, :lastname, :maximum => 30
        validates_length_of :identity_url, maximum: 255
        validates_inclusion_of :mail_notification, :in => MAIL_NOTIFICATION_OPTIONS.collect(&:first), :allow_blank => true
      end
    FOO
    node = ClassNode.new('Test')
    node.ast = YARD::Parser::Ruby::RubyParser.parse(class_def).root[0]
    builtin_extractor = BuiltinExtractor.new
    builtin_extractor.visit(node, {})
    answer = 10
    unless node.constraints.length == answer
      raise "Get #{node.constraints.length} extracted constraints, expect #{answer}"
    end
  end
end
