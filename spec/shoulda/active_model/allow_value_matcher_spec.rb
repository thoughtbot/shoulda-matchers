require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::AllowValueMatcher do
  context "an attribute with a format validation" do
    let(:model) do
      define_model :example, :attr => :string do
        validates_format_of :attr, :with => /abc/
      end.new
    end

    it "allows a good value" do
      model.should allow_value("abcde").for(:attr)
    end

    it "rejects a bad value" do
      model.should_not allow_value("xyz").for(:attr)
    end

    it "allows several good values" do
      model.should allow_value("abcde", "deabc").for(:attr)
    end

    it "rejects several bad values" do
      model.should_not allow_value("xyz", "zyx", nil, []).for(:attr)
    end
  end

  context "an attribute with a format validation and a custom message" do
    let(:model) do
      define_model :example, :attr => :string do
        validates_format_of :attr, :with => /abc/, :message => 'bad value'
      end.new
    end

    it "allows a good value" do
      model.should allow_value('abcde').for(:attr).with_message(/bad/)
    end

    it "rejects a bad value" do
      model.should_not allow_value('xyz').for(:attr).with_message(/bad/)
    end
  end

  context "an attribute with several validations" do
    let(:model) do
      define_model :example, :attr => :string do
        validates_presence_of     :attr
        validates_length_of       :attr, :within => 1..5
        validates_numericality_of :attr, :greater_than_or_equal_to => 1,
          :less_than_or_equal_to    => 50000
      end.new
    end
    bad_values = [nil, "", "abc", "0", "50001", "123456", []]

    it "allows a good value" do
      model.should allow_value("12345").for(:attr)
    end

    bad_values.each do |bad_value|
      it "rejects a bad value (#{bad_value.inspect})" do
        model.should_not allow_value(bad_value).for(:attr)
      end
    end

    it "rejects bad values (#{bad_values.map(&:inspect).join(', ')})" do
      model.should_not allow_value(*bad_values).for(:attr)
    end
  end

  context "an AllowValueMatcher with multiple values" do
    it "should describe itself" do
      matcher = allow_value("foo", "bar").for(:baz)
      matcher.description.should == 'allow baz to be set to any of ["foo", "bar"]'
    end
  end

  context "an AllowValueMatcher with a single value" do
    it "should describe itself" do
      matcher = allow_value("foo").for(:baz)
      matcher.description.should eq('allow baz to be set to "foo"')
    end

    it "allows you to call description before calling matches?" do
      model = define_model(:example, :attr => :string).new
      matcher = Shoulda::Matchers::ActiveModel::AllowValueMatcher.new("foo").for(:attr)
      matcher.description

      expect { matcher.matches?(model) }.not_to raise_error
    end
  end

  context "an AllowValueMatcher with no values" do
    it "raises an error" do
      lambda do
        allow_value.for(:baz)
      end.should raise_error(ArgumentError, /at least one argument/)
    end
  end

  if Rails::VERSION::STRING.to_f >= 3.2
    context "an attribute with a strict format validation" do
      let(:model) do
        define_model :example, :attr => :string do
          validates_format_of :attr, :with => /abc/, :strict => true
        end.new
      end

      it "strictly rejects a bad value" do
        model.should_not allow_value("xyz").for(:attr).strict
      end

      it "strictly allows a bad value with a different message" do
        model.should allow_value("xyz").for(:attr).with_message(/abc/).strict
      end

      it "describes itself" do
        allow_value("xyz").for(:attr).strict.description.
          should == %{doesn't raise when attr is set to "xyz"}
      end

      it "provides a useful negative failure message" do
        matcher = allow_value("xyz").for(:attr).strict.with_message(/abc/)
        matcher.matches?(model)
        matcher.negative_failure_message.
          should == 'Expected exception to include /abc/ ' +
            'when attr is set to "xyz", got Attr is invalid'
      end
    end
  end

end
