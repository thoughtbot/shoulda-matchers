require File.join(File.dirname(__FILE__), '..', '..', 'test_helper')

class ValidateNumericalityOfMatcherTest < ActiveSupport::TestCase # :nodoc:

  context "a numeric attribute" do
    setup do
      define_model :example, :attr => :string do
        validates_numericality_of :attr
      end
      @model = Example.new
    end

    should "only allow numeric values for that attribute" do
      assert_accepts validate_numericality_of(:attr), @model
    end

    should "not override the default message with a blank" do
      assert_accepts validate_numericality_of(:attr).with_message(nil),
                     @model
    end
  end

  context "a numeric attribute with a custom validation message" do
    setup do
      define_model :example, :attr => :string do
        validates_numericality_of :attr, :message => 'custom'
      end
      @model = Example.new
    end

    should "only allow numeric values for that attribute with that message" do
      assert_accepts validate_numericality_of(:attr).
                       with_message(/custom/),
                     @model
    end

    should "not allow numeric values for that attribute with another message" do
      assert_rejects validate_numericality_of(:attr), @model
    end
  end

  context "a non-numeric attribute" do
    setup do
      @model = define_model(:example, :attr => :string).new
    end

    should "not only allow numeric values for that attribute" do
      assert_rejects validate_numericality_of(:attr), @model
    end
  end

end
