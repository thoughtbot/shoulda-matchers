require 'spec_helper'

describe Shoulda::Matchers::ActionController do
  describe "#permit" do
    it 'matches when the sent parameter is allowed' do
      controller_class = controller_for_resource_with_strong_parameters(action: :create) do
        params.require(:user).permit(:name)
      end

      expect(controller_class).to permit(:name).for(:create)
    end

    it 'does not match when the sent parameter is not allowed' do
      controller_class = controller_for_resource_with_strong_parameters(action: :create) do
        params.require(:user).permit(:name)
      end

      expect(controller_class).not_to permit(:admin).for(:create)
    end

    it 'matches against multiple attributes' do
      controller_class = controller_for_resource_with_strong_parameters(action: :create) do
        params.require(:user).permit(:name, :age)
      end

      expect(controller_class).to permit(:name, :age).for(:create)
    end
  end
end

describe Shoulda::Matchers::ActionController::StrongParametersMatcher do
  describe "#matches?" do
    it "is true for a subset of the allowable attributes" do
      controller_for_resource_with_strong_parameters(action: :create) do
        params.require(:user).permit(:name)
      end

      matcher = described_class.new([:name]).in_context(self).for(:create)
      expect(matcher.matches?).to be_true
    end

    it "is true for all the allowable attributes" do
      controller_for_resource_with_strong_parameters(action: :create) do
        params.require(:user).permit(:name, :age)
      end

      matcher = described_class.new([:name, :age]).in_context(self).for(:create)
      expect(matcher.matches?).to be_true
    end

    it "is false when any attributes are not allowed" do
      controller_for_resource_with_strong_parameters(action: :create) do
        params.require(:user).permit(:name)
      end

      matcher = described_class.new([:name, :admin]).in_context(self).for(:create)
      expect(matcher.matches?).to be_false
    end

    it "is false when permit is not called" do
      controller_for_resource_with_strong_parameters(action: :create) {}

      matcher = described_class.new([:name]).in_context(self).for(:create)
      expect(matcher.matches?).to be_false
    end

    it "requires an action" do
      matcher = described_class.new([:name])
      expect { matcher.matches? }
        .to raise_error(Shoulda::Matchers::ActionController::StrongParametersMatcher::ActionNotDefinedError)
    end

    it "requires a verb for non-restful action" do
      matcher = described_class.new([:name]).for(:authorize)
      expect { matcher.matches? }
        .to raise_error(Shoulda::Matchers::ActionController::StrongParametersMatcher::VerbNotDefinedError)
    end
  end

  describe "failure message" do
    it "includes all missing attributes" do
      controller_class = controller_for_resource_with_strong_parameters(action: :create) do
        params.require(:user).permit(:name, :age)
      end

      expect {
        expect(controller_class).to permit(:name, :age, :city, :country).for(:create)
      }.to fail_with_message("Expected controller to permit city and country, but it did not.")
    end

    it "includes all attributes that should not have been allowed but were" do
      controller_class = controller_for_resource_with_strong_parameters(action: :create) do
        params.require(:user).permit(:name, :age)
      end

      expect {
        expect(controller_class).not_to permit(:name, :age).for(:create)
      }.to fail_with_message("Expected controller not to permit name and age, but it did.")
    end
  end

  describe "#for" do
    context "when given :create" do
      it "posts to the controller" do
        context = stub('context', post: nil)
        matcher = described_class.new([:name]).in_context(context).for(:create)

        matcher.matches?
        expect(context).to have_received(:post).with(:create)
      end
    end

    context "when given :update" do
      it "puts to the controller" do
        context = stub('context', put: nil)
        matcher = described_class.new([:name]).in_context(context).for(:update)

        matcher.matches?
        expect(context).to have_received(:put).with(:update)
      end
    end

    context "when given a custom action and verb" do
      it "deletes to the controller" do
        context = stub('context', delete: nil)
        matcher = described_class.new([:name]).in_context(context).for(:hide, verb: :delete)

        matcher.matches?
        expect(context).to have_received(:delete).with(:hide)
      end
    end
  end
end
