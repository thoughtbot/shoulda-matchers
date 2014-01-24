require 'spec_helper'

describe Shoulda::Matchers::ActionController do
  describe ".permit" do
    it "is true when the sent parameter is allowed" do
      controller_class = controller_for_resource_with_strong_parameters do
        params.require(:user).permit(:name)
      end

      controller_class.should permit(:name).for(:create)
    end

    it "is false when the sent parameter is not allowed" do
      controller_class = controller_for_resource_with_strong_parameters do
        params.require(:user).permit(:name)
      end

      controller_class.should_not permit(:admin).for(:create)
    end

    it "allows multiple attributes" do
      controller_class = controller_for_resource_with_strong_parameters do
        params.require(:user).permit(:name, :age)
      end

      controller_class.should permit(:name, :age).for(:create)
    end
  end
end

describe Shoulda::Matchers::ActionController::StrongParametersMatcher do
  before do
    controller_for_resource_with_strong_parameters do
      params.require(:user).permit(:name, :age)
    end
  end

  describe "#matches?" do
    it "is true for a subset of the allowable attributes" do
      matcher = Shoulda::Matchers::ActionController::StrongParametersMatcher.new(:name, self).for(:create)
      matcher.matches?.should be_true
    end

    it "is true for all the allowable attributes" do
      matcher = Shoulda::Matchers::ActionController::StrongParametersMatcher.new(:name, :age, self).for(:create)
      matcher.matches?.should be_true
    end

    it "is false when any attributes are not allowed" do
      matcher = Shoulda::Matchers::ActionController::StrongParametersMatcher.new(:name, :admin, self).for(:create)
      matcher.matches?.should be_false
    end

    it "is false when permit is not called" do
      matcher = Shoulda::Matchers::ActionController::StrongParametersMatcher.new(:name, self).for(:new, :verb => :get)
      matcher.matches?.should be_false
    end

    it "requires an action" do
      matcher = Shoulda::Matchers::ActionController::StrongParametersMatcher.new(:name, self)
      expect{ matcher.matches? }.to raise_error(Shoulda::Matchers::ActionController::StrongParametersMatcher::ActionNotDefinedError)
    end

    it "requires a verb for non-restful action" do
      matcher = Shoulda::Matchers::ActionController::StrongParametersMatcher.new(:name, self).for(:authorize)
      expect{ matcher.matches? }.to raise_error(Shoulda::Matchers::ActionController::StrongParametersMatcher::VerbNotDefinedError)
    end
  end

  describe "#does_not_match?" do
    it "it is true if any of the given attributes are allowed" do
      matcher = Shoulda::Matchers::ActionController::StrongParametersMatcher.new(:name, :admin, self).for(:create)
      matcher.does_not_match?.should be_true
    end

    it "it is false if all of the given attribtues are allowed" do
      matcher = Shoulda::Matchers::ActionController::StrongParametersMatcher.new(:name, :age, self).for(:create)
      matcher.does_not_match?.should be_false
    end
  end

  describe "#failure_message" do
    it "includes all missing attributes" do
      matcher = Shoulda::Matchers::ActionController::StrongParametersMatcher.new(:name, :age, :city, :country, self).for(:create)
      matcher.matches?

      matcher.failure_message.should eq("Expected controller to permit city and country, but it did not.")
    end
  end

  describe "#negative_failure_message" do
    it "includes all attributes that should not have been allowed but were" do
      matcher = Shoulda::Matchers::ActionController::StrongParametersMatcher.new(:name, :age, :city, :country, self).for(:create)
      matcher.does_not_match?.should be_true

      matcher.negative_failure_message.should eq("Expected controller not to permit city and country, but it did.")
    end
  end

  describe "#for" do
    context "when given :create" do
      it "posts to the controller" do
        context = stub('context', :post => nil)
        matcher = Shoulda::Matchers::ActionController::StrongParametersMatcher.new(:name, context).for(:create)

        matcher.matches?
        context.should have_received(:post).with(:create)
      end
    end

    context "when given :update" do
      it "puts to the controller" do
        context = stub('context', :put => nil)
        matcher = Shoulda::Matchers::ActionController::StrongParametersMatcher.new(:name, context).for(:update)

        matcher.matches?
        context.should have_received(:put).with(:update)
      end
    end

    context "when given a custom action and verb" do
      it "puts to the controller" do
        context = stub('context', :delete => nil)
        matcher = Shoulda::Matchers::ActionController::StrongParametersMatcher.new(:name, context).for(:hide, :verb => :delete)

        matcher.matches?
        context.should have_received(:delete).with(:hide)
      end
    end
  end

  describe "#in_context" do
    it 'sets the object the controller action is sent to' do
      context = stub('context', :post => nil)
      matcher = Shoulda::Matchers::ActionController::StrongParametersMatcher.new(:name, nil).for(:create).in_context(context)

      matcher.matches?

      context.should have_received(:post).with(:create)
    end
  end
end
