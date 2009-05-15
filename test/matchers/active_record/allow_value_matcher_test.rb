require File.join(File.dirname(__FILE__), '..', '..', 'test_helper')

class AllowValueMatcherTest < ActiveSupport::TestCase # :nodoc:

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

  context "an attribute with several validations" do
    setup do
      define_model :example, :attr => :string do
        validates_presence_of     :attr
        validates_length_of       :attr, :within => 1..5
        validates_numericality_of :attr, :greater_than_or_equal_to => 1,
                                         :less_than_or_equal_to    => 50000
      end
      @model = Example.new
    end

    should "allow a good value" do
      assert_accepts allow_value("12345").for(:attr), @model
    end
    
    bad_values = [nil, "", "abc", "0", "50001", "123456"]
    bad_values.each do |value|
      should "not allow a bad value (#{value.inspect})" do
        assert_rejects allow_value(value).for(:attr), @model
      end
    end
  end

end
