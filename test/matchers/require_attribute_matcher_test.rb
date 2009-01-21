require File.join(File.dirname(__FILE__), '..', 'test_helper')

class RequireAttributeMatcherTest < Test::Unit::TestCase # :nodoc:

  context "a required attribute" do
    setup do
      build_model_class :example, :attr => :string do
        validates_presence_of :attr
      end
      @model = Example.new
    end

    should "require a value" do
      assert_accepts require_attribute(:attr), @model
    end

    should "not override the default message with a blank" do
      assert_accepts require_attribute(:attr).with_message(nil), @model
    end
  end

  context "an optional attribute" do
    setup do
      @model = build_model_class(:example, :attr => :string).new
    end

    should "not require a value" do
      assert_rejects require_attribute(:attr), @model
    end
  end

  context "a required has_many association" do
    setup do
      build_model_class :child
      @model = build_model_class :parent do
        has_many :children
        validates_presence_of :children
      end.new
    end

    should "require the attribute to be set" do
      assert_accepts require_attribute(:children), @model
    end
  end

  context "an optional has_many association" do
    setup do
      build_model_class :child
      @model = build_model_class :parent do
        has_many :children
      end.new
    end

    should "not require the attribute to be set" do
      assert_rejects require_attribute(:children), @model
    end
  end

  context "a required has_and_belongs_to_many association" do
    setup do
      build_model_class :child
      @model = build_model_class :parent do
        has_and_belongs_to_many :children
        validates_presence_of :children
      end.new
    end

    should "require the attribute to be set" do
      assert_accepts require_attribute(:children), @model
    end
  end

  context "an optional has_and_belongs_to_many association" do
    setup do
      build_model_class :child
      @model = build_model_class :parent do
        has_and_belongs_to_many :children
      end.new
    end

    should "not require the attribute to be set" do
      assert_rejects require_attribute(:children), @model
    end
  end

end
