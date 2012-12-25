require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::ValidateAcceptanceOfMatcher do

  context "an attribute which must be accepted" do
    before do
      @model = define_model(:example, :attr => :string) do
        validates_acceptance_of :attr
      end.new
    end

    it "should require that attribute to be accepted" do
      @model.should validate_acceptance_of(:attr)
    end

    it "should not overwrite the default message with nil" do
      @model.should validate_acceptance_of(:attr).with_message(nil)
    end
  end

  context "an attribute that does not need to be accepted" do
    before do
      @model = define_model(:example, :attr => :string).new
    end

    it "should not require that attribute to be accepted" do
      @model.should_not validate_acceptance_of(:attr)
    end
  end

  context "an attribute which must be accepted with a custom message" do
    before do
      @model = define_model(:example, :attr => :string) do
        validates_acceptance_of :attr, :message => 'custom'
      end.new
    end

    it "should require that attribute to be accepted with that message" do
      @model.should validate_acceptance_of(:attr).with_message(/custom/)
    end
  end

end
