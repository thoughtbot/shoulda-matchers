require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::AllowValueMatcher do

  context "an attribute with a format validation" do
    before do
      define_model :example, :attr => :string do
        validates_format_of :attr, :with => /abc/
      end
      @model = Example.new
    end

    it "should allow a good value" do
      @model.should allow_value("abcde").for(:attr)
    end

    it "should not allow a bad value" do
      @model.should_not allow_value("xyz").for(:attr)
    end

    it "should allow several good values" do
      @model.should allow_value("abcde", "deabc").for(:attr)
    end

    it "should not allow several bad values" do
      @model.should_not allow_value("xyz", "zyx", nil, []).for(:attr)
    end
  end

  context "an attribute with a format validation and a custom message" do
    before do
      define_model :example, :attr => :string do
        validates_format_of :attr, :with => /abc/, :message => 'bad value'
      end
      @model = Example.new
    end

    it "should allow a good value" do
      @model.should allow_value('abcde').for(:attr).with_message(/bad/)
    end

    it "should not allow a bad value" do
      @model.should_not allow_value('xyz').for(:attr).with_message(/bad/)
    end
  end

  context "an attribute with several validations" do
    before do
      define_model :example, :attr => :string do
        validates_presence_of     :attr
        validates_length_of       :attr, :within => 1..5
        validates_numericality_of :attr, :greater_than_or_equal_to => 1,
          :less_than_or_equal_to    => 50000
      end
      @model = Example.new
    end

    it "should allow a good value" do
      @model.should allow_value("12345").for(:attr)
    end

    bad_values = [nil, "", "abc", "0", "50001", "123456", []]

    bad_values.each do |value|
      it "should not allow a bad value (#{value.inspect})" do
        @model.should_not allow_value(value).for(:attr)
      end
    end

    it "should not allow bad values (#{bad_values.map {|v| v.inspect}.join(', ')})" do
      @model.should_not allow_value(*bad_values).for(:attr)
    end
  end

  context "an AllowValueMatcher with multiple values" do
    before { @matcher = allow_value("foo", "bar").for(:baz) }

    it "should describe itself" do
      @matcher.description.should eq('allow baz to be set to any of ["foo", "bar"]')
    end
  end

  context "an AllowValueMatcher with a single value" do
    before { @matcher = allow_value("foo").for(:baz) }

    it "should describe itself" do
      @matcher.description.should eq('allow baz to be set to "foo"')
    end
  end

  context "an AllowValueMatcher with no values" do
    it "raises an error" do
      lambda do
        allow_value.for(:baz)
      end.should raise_error(ArgumentError, /at least one argument/)
    end
  end
end
