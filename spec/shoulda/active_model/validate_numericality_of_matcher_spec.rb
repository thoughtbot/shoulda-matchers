require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::ValidateNumericalityOfMatcher do

  context "a numeric attribute" do
    before do
      define_model :example, :attr => :string do
        validates_numericality_of :attr
      end
      @model = Example.new
    end

    it "should only allow numeric values for that attribute" do
      @model.should validate_numericality_of(:attr)
    end

    it "should not override the default message with a blank" do
      @model.should validate_numericality_of(:attr).with_message(nil)
    end
  end

  context "a numeric attribute which must be integer" do
    before do
      define_model :example, :attr => :string do
          validates_numericality_of :attr, { :only_integer => true }
      end
      @model = Example.new
    end

    it "should only allow integer values for that attribute" do
      @model.should validate_numericality_of(:attr).only_integer
    end
  end

  context "a numeric attribute with a custom validation message" do
    before do
      define_model :example, :attr => :string do
        validates_numericality_of :attr, :message => 'custom'
      end
      @model = Example.new
    end

    it "should only allow numeric values for that attribute with that message" do
      @model.should validate_numericality_of(:attr).with_message(/custom/)
    end

    it "should not allow numeric values for that attribute with another message" do
      @model.should_not validate_numericality_of(:attr)
    end
  end

  all_possible_validate_numericality_of_methods.each do |parameter|
    context "a numeric attribute with a '#{parameter.to_s}' parameter" do
      before do
        define_model(:example, :attr => :integer) do
          validates_numericality_of :attr, parameter => 0
        end
        @model = Example.new
      end

      it "should only allow numeric values #{parameter} indicated value for that attribute" do
        @model.should validate_numericality_of(:attr).send(parameter, 0)
      end
    end

    context "a numeric attribute without a '#{parameter.to_s}' parameter" do
      before do
        define_model(:example, :attr => :integer) do
          validates_numericality_of :attr
        end
        @model = Example.new
      end

      it "should not allow numeric values without #{parameter} indicated value for that attribute" do
        @model.should_not validate_numericality_of(:attr).send(parameter, 0)
      end
    end

    context "a numeric attribute with a '#{parameter.to_s}' parameter and a custom message" do
      before do
        define_model(:example, :attr => :integer) do
          validates_numericality_of :attr
          validates_numericality_of :attr, parameter => 0, :message => "#{parameter} custom message"
        end
        @model = Example.new
      end

      it "should only allow numeric values #{parameter} indicated value for that attribute with message '#{parameter} custom message'" do
        @model.should validate_numericality_of(:attr).send(parameter, 0).send("with_#{parameter}_message", "#{parameter} custom message")
      end
    end
  end

  context "description tests" do
    all_possible_validate_numericality_of_methods.each do |parameter|
      it "should return the correct description when the #{parameter} validation fails" do
        validate_numericality_of(:attr).send(parameter, 0).description.should == "only allow numeric values #{parameter} 0 for attr"
      end
    end

    all_possible_combinations_of_greater_than_or_less_than_methods.each do |parameter_with_greater, parameter_with_less|
      it "should return the correct description when the #{parameter_with_greater}, #{parameter_with_less} validations fails" do
        validate_numericality_of(:attr).send(parameter_with_greater, 0).send(parameter_with_less, 10).description.should == "only allow numeric values #{parameter_with_greater} 0, #{parameter_with_less} 10 for attr"
      end
    end
  end

  context "a non-numeric attribute" do
    before do
      @model = define_model(:example, :attr => :string).new
    end

    it "should not only allow numeric values for that attribute" do
      @model.should_not validate_numericality_of(:attr)
    end
  end

end
