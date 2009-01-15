require File.join(File.dirname(__FILE__), '..', 'test_helper')

class AllowValueMatcherTest < Test::Unit::TestCase # :nodoc:

  context "an attribute with a format validation" do
    setup do
      build_model_class :example, :attr => :string do
        validates_format_of :attr, :with => /abc/
      end
      @model = Example.new
    end

    should "allow a good value" do
      assert_accepts allow_value("abcde").for(:attr), @model
    end
    
    should "not allow a bad value" do
      assert_rejects allow_value("xyz").for(:attr), @model
    end
  end

  context "an attribute with a format validation and a custom message" do
    setup do
      build_model_class :example, :attr => :string do
        validates_format_of :attr, :with => /abc/, :message => 'bad value'
      end
      @model = Example.new
    end

    should "allow a good value" do
      assert_accepts allow_value('abcde').for(:attr).with_message(/bad/),
                     @model
    end
    
    should "not allow a bad value" do
      assert_rejects allow_value('xyz').for(:attr).with_message(/bad/),
                     @model
    end
  end

  context "a required attribute" do
    setup do
      build_model_class :example, :attr => :string do
        validates_presence_of :attr
      end
      @model = Example.new
    end

    should "not allow a blank value" do
      assert_rejects allow_blank_for(:attr), @model
    end

    should "not override the default message with a blank" do
      assert_rejects allow_blank_for(:attr).with_message(nil), @model
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

    should "not allow a blank value" do
      assert_rejects allow_blank_for(:children), @model
    end
  end

  context "an optional has_many association" do
    setup do
      build_model_class :child
      @model = build_model_class :parent do
        has_many :children
      end.new
    end

    should "allow a blank value" do
      assert_accepts allow_blank_for(:children), @model
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

    should "not allow a blank value" do
      assert_rejects allow_blank_for(:children), @model
    end
  end

  context "an optional has_and_belongs_to_many association" do
    setup do
      build_model_class :child
      @model = build_model_class :parent do
        has_and_belongs_to_many :children
      end.new
    end

    should "allow a blank value" do
      assert_accepts allow_blank_for(:children), @model
    end
  end

  context "an optional attribute" do
    setup do
      @model = build_model_class(:example, :attr => :string).new
    end

    should "allow a blank value" do
      assert_accepts allow_blank_for(:attr), @model
    end
  end

end
