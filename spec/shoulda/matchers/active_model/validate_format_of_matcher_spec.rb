require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::ValidateFormatOfMatcher do
  context "a postal code" do
    before do
      define_model :example, :attr => :string do
        validates_format_of :attr, :with => /^\d{5}$/
      end
      @model = Example.new
    end

    it "is valid" do
      @model.should validate_format_of(:attr).with('12345')
    end

    it "is not valid with blank" do
      @model.should_not validate_format_of(:attr).with(' ')
      @model.should validate_format_of(:attr).not_with(' ')
    end

    it "is not valid with nil" do
      @model.should_not validate_format_of(:attr).with(nil)
    end

    it "is not valid with alpha in zip" do
      @model.should_not validate_format_of(:attr).with('1234a')
      @model.should validate_format_of(:attr).not_with('1234a')
    end

    it "is not valid with too few digits" do
      @model.should_not validate_format_of(:attr).with('1234')
      @model.should validate_format_of(:attr).not_with('1234')
    end

    it "is not valid with too many digits" do
      @model.should_not validate_format_of(:attr).with('123456')
      @model.should validate_format_of(:attr).not_with('123456')
    end

    it "raises error if you try to call both with and not_with" do
      expect { validate_format_of(:attr).not_with('123456').with('12345') }.
        to raise_error(RuntimeError)
    end
  end

  context "when allow_blank and allow_nil are set" do
    before do
      define_model :example, :attr => :string do
        validates_format_of :attr, :with => /^\d{5}$/, :allow_blank => true, :allow_nil => true
      end
      @model = Example.new
    end

    it "is valid when attr is nil" do
      @model.should validate_format_of(:attr).with(nil)
    end

    it "is valid when attr is blank" do
      @model.should validate_format_of(:attr).with(' ')
    end

    describe "#allow_blank" do
      it "allows allow_blank" do
        @model.should validate_format_of(:attr).allow_blank
        @model.should validate_format_of(:attr).allow_blank(true)
        @model.should_not validate_format_of(:attr).allow_blank(false)
      end
    end

    describe "#allow_nil" do
      it "allows allow_nil" do
        @model.should validate_format_of(:attr).allow_nil
        @model.should validate_format_of(:attr).allow_nil(true)
        @model.should_not validate_format_of(:attr).allow_nil(false)
      end
    end
  end

end
