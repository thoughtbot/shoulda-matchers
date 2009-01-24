require File.join(File.dirname(__FILE__), '..', 'test_helper')

class AllowValueMatcherTest < Test::Unit::TestCase # :nodoc:

  context "an attribute with a format validation" do
    setup do
      define_model :example, :attr => :string do
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
      define_model :example, :attr => :string do
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

end
