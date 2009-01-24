require File.join(File.dirname(__FILE__), '..', 'test_helper')

class EnsureInclusionOfMatcherTest < Test::Unit::TestCase # :nodoc:

  context "an attribute which must be included in a range" do
    setup do
      @model = define_model(:example, :attr => :integer) do
        validates_inclusion_of :attr, :in => 2..5
      end.new
    end

    should "accept ensuring the correct range" do
      assert_accepts ensure_inclusion_of(:attr).in_range(2..5), @model
    end

    should "reject ensuring a lower minimum value" do
      assert_rejects ensure_inclusion_of(:attr).in_range(1..5), @model
    end

    should "reject ensuring a higher minimum value" do
      assert_rejects ensure_inclusion_of(:attr).in_range(3..5), @model
    end

    should "reject ensuring a lower maximum value" do
      assert_rejects ensure_inclusion_of(:attr).in_range(2..4), @model
    end

    should "reject ensuring a higher maximum value" do
      assert_rejects ensure_inclusion_of(:attr).in_range(2..6), @model
    end

    should "not override the default message with a blank" do
      assert_accepts ensure_inclusion_of(:attr).
                       in_range(2..5).
                       with_message(nil),
                     @model
    end
  end

  context "an attribute with a custom ranged value validation" do
    setup do
      @model = define_model(:example, :attr => :string) do
        validates_inclusion_of :attr, :in => 2..4, :message => 'not good'

      end.new
    end

    should "accept ensuring the correct range" do
      assert_accepts ensure_inclusion_of(:attr).
                       in_range(2..4).
                       with_message(/not good/),
                     @model
    end
  end

  context "an attribute with custom range validations" do
    setup do
      define_model :example, :attr => :integer do
        def validate
          if attr < 2
            errors.add(:attr, 'too low')
          elsif attr > 5
            errors.add(:attr, 'too high')
          end
        end
      end
      @model = Example.new
    end

    should "accept ensuring the correct range and messages" do
      assert_accepts ensure_inclusion_of(:attr).
                       in_range(2..5).
                       with_low_message(/low/).
                       with_high_message(/high/),
                     @model
    end

  end

end
