require "spec_helper"

describe Shoulda::Matchers::ActiveModel::AllowValueMatcher do
  context "an attribute with a validation" do
    it "allows a good value" do
      validating_format(:with => /abc/).should allow_value("abcde").for(:attr)
    end

    it "rejects a bad value" do
      validating_format(:with => /abc/).should_not allow_value("xyz").for(:attr)
    end

    it "allows several good values" do
      validating_format(:with => /abc/).should
        allow_value("abcde", "deabc").for(:attr)
    end

    it "rejects several bad values" do
      validating_format(:with => /abc/).should_not
        allow_value("xyz", "zyx", nil, []).for(:attr)
    end
  end

  context "an attribute with a validation and a custom message" do
    it "allows a good value" do
      validating_format(:with => /abc/, :message => "bad value").should
        allow_value("abcde").for(:attr).with_message(/bad/)
    end

    it "rejects a bad value" do
      validating_format(:with => /abc/, :message => "bad value").should_not
        allow_value("xyz").for(:attr).with_message(/bad/)
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

    it "rejects several bad values (#{bad_values.map(&:inspect).join(", ")})" do
      model.should_not allow_value(*bad_values).for(:attr)
    end
  end

  context "with multiple values" do
    it "describes itself" do
      matcher = allow_value("foo", "bar").for(:baz)
      matcher.description.should == 'allow baz to be set to any of ["foo", "bar"]'
    end
  end

  context "with a single value" do
    it "describes itself" do
      matcher = allow_value("foo").for(:baz)
      matcher.description.should == 'allow baz to be set to "foo"'
    end

    it "allows you to call description before calling matches?" do
      model = define_model(:example, :attr => :string).new
      matcher = described_class.new("foo").for(:attr)
      matcher.description

      expect { matcher.matches?(model) }.not_to raise_error
    end
  end

  context "with no values" do
    it "raises an error" do
      expect { allow_value.for(:baz) }.to
        raise_error(ArgumentError, /at least one argument/)
    end
  end

  if active_model_3_2?
    context "an attribute with a strict format validation" do
      let(:model) do
        define_model :example, :attr => :string do
          validates_format_of :attr, :with => /abc/, :strict => true
        end.new
      end

      it "strictly rejects a bad value" do
        validating_format(:with => /abc/, :strict => true).should_not 
          allow_value("xyz").for(:attr).strict
      end

      it "strictly allows a bad value with a different message" do
        validating_format(:with => /abc/, :strict => true).should
          allow_value("xyz").for(:attr).with_message(/abc/).strict
      end

      it "describes itself" do
        allow_value("xyz").for(:attr).strict.description.
          should == %{doesn't raise when attr is set to "xyz"}
      end

      it "provides a useful negative failure message" do
        matcher = allow_value("xyz").for(:attr).strict.with_message(/abc/)
        matcher.matches?(validating_format(:with => /abc/, :strict => true))
        matcher.negative_failure_message.should == "Expected exception to include /abc/ " +
          'when attr is set to "xyz", got Attr is invalid'
      end
    end
  end

  def validating_format(options)
    define_model :example, :attr => :string do
      validates_format_of :attr, options
    end.new
  end
end
