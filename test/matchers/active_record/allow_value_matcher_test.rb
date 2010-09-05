require 'test_helper'

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

    should "allow several good values" do
      assert_accepts allow_value("abcde", "deabc").for(:attr), @model
    end

    should "not allow a bad value" do
      assert_rejects allow_value("xyz").for(:attr), @model
    end

    should "not allow several bad values" do
      assert_rejects allow_value("xyz", "zyx", nil, []).for(:attr), @model
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

    bad_values = [nil, "", "abc", "0", "50001", "123456", []]

    bad_values.each do |value|
      should "not allow a bad value (#{value.inspect})" do
        assert_rejects allow_value(value).for(:attr), @model
      end
    end

    should "not allow bad values (#{bad_values.map {|v| v.inspect}.join(', ')})" do
      assert_rejects allow_value(*bad_values).for(:attr), @model
    end
  end

  context "an AllowValueMatcher with multiple values" do
    setup { @matcher = allow_value("foo", "bar").for(:baz) }

    should "describe itself" do
      expected = 'allow baz to be set to any of ["foo", "bar"]'
      assert_equal expected, @matcher.description
    end
  end

  context "an AllowValueMatcher with a single value" do
    setup { @matcher = allow_value("foo").for(:baz) }

    should "describe itself" do
      expected = 'allow baz to be set to "foo"'
      assert_equal expected, @matcher.description
    end
  end
end
