require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::ValidateFormatOfMatcher do

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
      @model.should_not validate_format_of(:attr).with('1234a')
      @model.should validate_format_of(:attr).not_with('1234a')
    end

    it "should not be valid with too few digits" do
      @model.should_not validate_format_of(:attr).with('1234')
      @model.should validate_format_of(:attr).not_with('1234')
    end

    it "should not be valid with too many digits" do
      @model.should_not validate_format_of(:attr).with('123456')
      @model.should validate_format_of(:attr).not_with('123456')
    end

    it "should raise error if you try to call both with and not_with" do
      expect { validate_format_of(:attr).not_with('123456').with('12345') }.
        to raise_error(RuntimeError)
    end
  end

  context "allowed blank and allowed nil" do
    context "a postal code" do
      before do
        define_model :example, :attr => :string do
          validates_format_of :attr, :with => /^\d{5}$/, :allow_blank => true, :allow_nil => true
        end
        @model = Example.new
      end

      it "allows allow_blank" do
        @model.should validate_format_of(:attr).with('12345').allow_blank(true)
        @model.should validate_format_of(:attr).with('12345').allow_blank()
        @model.should_not validate_format_of(:attr).with('12345').allow_blank(false)

        @model.should validate_format_of(:attr).not_with('1234').allow_blank(true)
        @model.should validate_format_of(:attr).not_with('1234').allow_blank()
        @model.should_not validate_format_of(:attr).not_with('1234').allow_blank(false)
      end

      it "allows allow_nil" do
        @model.should validate_format_of(:attr).with('12345').allow_nil(true)
        @model.should validate_format_of(:attr).with('12345').allow_nil()
        @model.should_not validate_format_of(:attr).with('12345').allow_nil(false)

        @model.should validate_format_of(:attr).not_with('1234').allow_nil(true)
        @model.should validate_format_of(:attr).not_with('1234').allow_nil()
        @model.should_not validate_format_of(:attr).not_with('1234').allow_nil(false)
      end
    end
  end

end
