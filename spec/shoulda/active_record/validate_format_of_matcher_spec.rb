require 'spec_helper'

describe Shoulda::ActiveRecord::ValidateFormatOfMatcher do

  context "a postal code" do
    before do
      define_model :example, :attr => :string do
        validates_format_of :attr, :with => /^\d{5}$/
      end
      @model = Example.new
    end

    it "should be valid" do
      @model.should validate_format_of(:attr).with('12345')
    end

    it "should not be valid with alpha in zip" do
      @model.should_not validate_format_of(:attr).not_with('1234a')
    end

    it "should not be valid with to few digits" do
      @model.should_not validate_format_of(:attr).not_with('1234')
    end

    it "should not be valid with to many digits" do
      @model.should_not validate_format_of(:attr).not_with('123456')
    end

    it "should raise error if you try to call both with and not_with" do
      expect { validate_format_of(:attr).not_with('123456').with('12345') }.
        to raise_error(RuntimeError)
    end
  end

end
