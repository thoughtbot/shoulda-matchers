require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::DisallowValueMatcher do
  let(:matcher_class) { Shoulda::Matchers::ActiveModel::DisallowValueMatcher }

  context "an attribute with a format validation" do
    let(:model) do
      define_model :example, :attr => :string do
        validates_format_of :attr, :with => /abc/
      end.new
    end

    it "does not allow a good value" do
      matcher_class.new("abcde").for(:attr).matches?(model).should be_false
    end

    it "allows a bad value" do
      matcher_class.new("xyz").for(:attr).matches?(model).should be_true
    end
  end

  context 'description' do
    let(:model) do
      define_model :example, :attr => :string do
        validates_presence_of :attr
      end.new
    end

    it 'is correct' do
      matcher_class.new(nil).for(:attr).description.should == 'not allow attr to be set to nil'
    end
  end

  context 'failure_message' do
    let(:model) do
      define_model :example, :attr => :string do
        validates_presence_of :attr
      end.new
    end

    it 'is correct' do
      expected_failure_message = 'Expected errors when attr is set to "present", got no errors'
      matcher = matcher_class.new('present').for(:attr)
      matcher.matches?(model).should be_false
      matcher.failure_message.should == expected_failure_message
    end
  end

  context 'negative_failure_message' do
    let(:model) do
      define_model :example, :attr => :string do
        validates_presence_of :attr
      end.new
    end

    it 'is correct' do
      expected_negative_failure_message = %{Did not expect errors when attr is set to nil, got error: ["attr can't be blank (nil)"]}
      matcher = matcher_class.new(nil).for(:attr)
      matcher.matches?(model).should be_true
      matcher.negative_failure_message.should == expected_negative_failure_message
    end
  end
end
