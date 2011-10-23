require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::ValidateConfirmationOfMatcher do

  context "an attribute which must be confirmed" do
    before do
      define_model(:example, :attr => :string) do
        validates_confirmation_of :attr
      end
    end

    context "with confirmed attribute" do
      before do
        @model = Example.new(:attr => 'value', :attr_confirmation => 'value')
      end

      it "requires confirmation value for that attribute" do
        @model.should validate_confirmation_of(:attr)
      end
    end

    context "with wrong confirmed attribute" do
      before do
        @model = Example.new(:attr => 'value', :attr_confirmation => 'wrong')
      end

      it "fails to match confirmation value for that attribute" do
        @model.should_not validate_confirmation_of(:attr)
      end
    end

    context "without confirmed attribute" do
      before do
        @model = Example.new(:attr => 'value')
      end

      it "fails to require confirmation value for that attribute" do
        @model.should_not validate_confirmation_of(:attr)
      end
    end
  end

  context "an attribute which must not be confirmed" do
    before do
      @model = define_model(:example, :attr => :string).new
    end

    it "doesn't requires confirmation value for that attribute" do
      @model.should_not validate_confirmation_of(:attr)
    end
  end
end
