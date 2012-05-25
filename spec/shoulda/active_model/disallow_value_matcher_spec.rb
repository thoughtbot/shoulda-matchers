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
      matcher_class.new("abcde").for(:attr).matches?(model).should be_true
    end

    it "allows a bad value" do
      matcher_class.new("xyz").for(:attr).matches?(model).should be_false
    end
  end
end
