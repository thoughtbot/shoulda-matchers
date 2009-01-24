require File.join(File.dirname(__FILE__), '..', 'test_helper')

class EnsureLengthOfMatcher < Test::Unit::TestCase # :nodoc:

  context "an attribute with a non-zero minimum length validation" do
    setup do
      @model = define_model(:example, :attr => :string) do
        validates_length_of :attr, :minimum => 4
      end.new
    end

    should "accept ensuring the correct minimum length" do
      assert_accepts ensure_length_of(:attr).is_at_least(4), @model
    end

    should "reject ensuring a lower minimum length with any message" do
      assert_rejects ensure_length_of(:attr).
                       is_at_least(3).
                       with_short_message(/.*/),
                     @model
    end

    should "reject ensuring a higher minimum length with any message" do
      assert_rejects ensure_length_of(:attr).
                       is_at_least(5).
                       with_short_message(/.*/),
                     @model
    end

    should "not override the default message with a blank" do
      assert_accepts ensure_length_of(:attr).
                       is_at_least(4).
                       with_short_message(nil),
                     @model
    end
  end

  context "an attribute with a minimum length validation of 0" do
    setup do
      @model = define_model(:example, :attr => :string) do
        validates_length_of :attr, :minimum => 0
      end.new
    end

    should "accept ensuring the correct minimum length" do
      assert_accepts ensure_length_of(:attr).is_at_least(0), @model
    end
  end

  context "an attribute with a maximum length" do
    setup do
      @model = define_model(:example, :attr => :string) do
        validates_length_of :attr, :maximum => 4
      end.new
    end

    should "accept ensuring the correct maximum length" do
      assert_accepts ensure_length_of(:attr).is_at_most(4), @model
    end

    should "reject ensuring a lower maximum length with any message" do
      assert_rejects ensure_length_of(:attr).
                       is_at_most(3).
                       with_long_message(/.*/),
                     @model
    end

    should "reject ensuring a higher maximum length with any message" do
      assert_rejects ensure_length_of(:attr).
                       is_at_most(5).
                       with_long_message(/.*/),
                     @model
    end

    should "not override the default message with a blank" do
      assert_accepts ensure_length_of(:attr).
                       is_at_most(4).
                       with_long_message(nil),
                     @model
    end
  end

  context "an attribute with a required exact length" do
    setup do
      @model = define_model(:example, :attr => :string) do
        validates_length_of :attr, :is => 4
      end.new
    end

    should "accept ensuring the correct length" do
      assert_accepts ensure_length_of(:attr).is_equal_to(4), @model
    end

    should "reject ensuring a lower maximum length with any message" do
      assert_rejects ensure_length_of(:attr).
                       is_equal_to(3).
                       with_message(/.*/),
                     @model
    end

    should "reject ensuring a higher maximum length with any message" do
      assert_rejects ensure_length_of(:attr).
                       is_equal_to(5).
                       with_message(/.*/),
                     @model
    end

    should "not override the default message with a blank" do
      assert_accepts ensure_length_of(:attr).
                       is_equal_to(4).
                       with_message(nil),
                     @model
    end
  end

  context "an attribute with a custom minimum length validation" do
    setup do
      @model = define_model(:example, :attr => :string) do
        validates_length_of :attr, :minimum => 4, :too_short => 'short'
      end.new
    end

    should "accept ensuring the correct minimum length" do
      assert_accepts ensure_length_of(:attr).
                       is_at_least(4).
                       with_short_message(/short/),
                     @model
    end

  end

  context "an attribute with a custom maximum length validation" do
    setup do
      @model = define_model(:example, :attr => :string) do
        validates_length_of :attr, :maximum => 4, :too_long => 'long'
      end.new
    end

    should "accept ensuring the correct minimum length" do
      assert_accepts ensure_length_of(:attr).
                       is_at_most(4).
                       with_long_message(/long/),
                     @model
    end

  end

  context "an attribute without a length validation" do
    setup do
      @model = define_model(:example, :attr => :string).new
    end

    should "reject ensuring a minimum length" do
      assert_rejects ensure_length_of(:attr).is_at_least(1), @model
    end
  end

end
