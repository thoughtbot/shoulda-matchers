require 'spec_helper'

describe Shoulda::Matchers::ActionController do
  describe "#permit" do
    it 'matches when the sent parameter is allowed' do
      controller_for_resource_with_strong_parameters(action: :create) do
        params.require(:user).permit(:name)
      end

      expect(@controller).to permit(:name).for(:create)
    end

    it 'does not match when the sent parameter is not allowed' do
      controller_for_resource_with_strong_parameters(action: :create) do
        params.require(:user).permit(:name)
      end

      expect(@controller).not_to permit(:admin).for(:create)
    end

    it 'matches against multiple attributes' do
      controller_for_resource_with_strong_parameters(action: :create) do
        params.require(:user).permit(:name, :age)
      end

      expect(@controller).to permit(:name, :age).for(:create)
    end
  end
end

describe Shoulda::Matchers::ActionController::StrongParametersMatcher do
  describe '#description' do
    it 'returns the correct string' do
      options = { action: :create, method: :post }
      controller_for_resource_with_strong_parameters(options) do
        params.permit(:name, :age)
      end

      matcher = described_class.new([:name, :age, :height]).for(:create)
      expect(matcher.description).
        to eq 'permit POST #create to receive parameters :name, :age, and :height'
    end

    context 'when a verb is specified' do
      it 'returns the correct string' do
        options = { action: :some_action }
        controller_for_resource_with_strong_parameters(options) do
          params.permit(:name, :age)
        end

        matcher = described_class.new([:name]).
          for(:some_action, verb: :put)
        expect(matcher.description).
          to eq 'permit PUT #some_action to receive parameters :name'
      end
    end
  end

  describe "#matches?" do
    it "is true for a subset of the allowable attributes" do
      controller_for_resource_with_strong_parameters(action: :create) do
        params.require(:user).permit(:name)
      end

      matcher = described_class.new([:name]).in_context(self).for(:create)
      expect(matcher.matches?(@controller)).to be_true
    end

    it "is true for all the allowable attributes" do
      controller_for_resource_with_strong_parameters(action: :create) do
        params.require(:user).permit(:name, :age)
      end

      matcher = described_class.new([:name, :age]).in_context(self).for(:create)
      expect(matcher.matches?(@controller)).to be_true
    end

    it "is false when any attributes are not allowed" do
      controller_for_resource_with_strong_parameters(action: :create) do
        params.require(:user).permit(:name)
      end

      matcher = described_class.new([:name, :admin]).in_context(self).for(:create)
      expect(matcher.matches?(@controller)).to be_false
    end

    it "is false when permit is not called" do
      controller_for_resource_with_strong_parameters(action: :create)

      matcher = described_class.new([:name]).in_context(self).for(:create)
      expect(matcher.matches?(@controller)).to be_false
    end

    it "requires an action" do
      controller_for_resource_with_strong_parameters
      matcher = described_class.new([:name])
      expect { matcher.matches?(@controller) }
        .to raise_error(Shoulda::Matchers::ActionController::StrongParametersMatcher::ActionNotDefinedError)
    end

    it "requires a verb for non-restful action" do
      controller_for_resource_with_strong_parameters
      matcher = described_class.new([:name]).for(:authorize)
      expect { matcher.matches?(@controller) }
        .to raise_error(Shoulda::Matchers::ActionController::StrongParametersMatcher::VerbNotDefinedError)
    end

    context 'stubbing params on the controller' do
      it 'still allows the original params to be set and accessed' do
        actual_value = nil

        controller_for_resource_with_strong_parameters(action: :create) do
          params[:foo] = 'bar'
          actual_value = params[:foo]

          params.require(:user).permit(:name)
        end

        matcher = described_class.new([:name]).in_context(self).for(:create)
        matcher.matches?(@controller)

        expect(actual_value).to eq 'bar'
      end

      it 'stubs the params while the controller action is being run' do
        params_class = nil

        controller_for_resource_with_strong_parameters(action: :create) do
          params_class = params.class
          params.require(:user).permit(:name)
        end

        matcher = described_class.new([:name]).in_context(self).for(:create)
        matcher.matches?(@controller)

        expect(params_class).to be described_class::StubbedParameters
      end

      it 'does not permanently stub params' do
        controller_for_resource_with_strong_parameters(action: :create) do
          params.require(:user).permit(:name)
        end

        matcher = described_class.new([:name]).in_context(self).for(:create)
        matcher.matches?(@controller)

        expect(@controller.params).to be_a(ActionController::Parameters)
      end

      it 'prevents permanently stubbing params on error' do
        stub_controller_with_exception

        begin
          matcher = described_class.new([:name]).in_context(self).for(:create)
          matcher.matches?(@controller)
        rescue SimulatedError
        end

        expect(@controller.params).to be_a(ActionController::Parameters)
      end
    end
  end

  describe "failure message" do
    it "includes all missing attributes" do
      controller_for_resource_with_strong_parameters(action: :create) do
        params.require(:user).permit(:name, :age)
      end

      expect {
        expect(@controller).to permit(:name, :age, :city, :country).for(:create)
      }.to fail_with_message("Expected controller to permit city and country, but it did not.")
    end

    it "includes all attributes that should not have been allowed but were" do
      controller_for_resource_with_strong_parameters(action: :create) do
        params.require(:user).permit(:name, :age)
      end

      expect {
        expect(@controller).not_to permit(:name, :age).for(:create)
      }.to fail_with_message("Expected controller not to permit name and age, but it did.")
    end
  end

  describe "#for" do
    context "when given :create" do
      it "posts to the controller" do
        controller = ActionController::Base.new
        context = stub('context', post: nil)
        matcher = described_class.new([:name]).in_context(context).for(:create)

        matcher.matches?(controller)
        expect(context).to have_received(:post).with(:create)
      end
    end

    context "when given :update" do
      it "puts to the controller" do
        controller = ActionController::Base.new
        context = stub('context', put: nil)
        matcher = described_class.new([:name]).in_context(context).for(:update)

        matcher.matches?(controller)
        expect(context).to have_received(:put).with(:update)
      end
    end

    context "when given a custom action and verb" do
      it "deletes to the controller" do
        controller = ActionController::Base.new
        context = stub('context', delete: nil)
        matcher = described_class.new([:name]).in_context(context).for(:hide, verb: :delete)

        matcher.matches?(controller)
        expect(context).to have_received(:delete).with(:hide)
      end
    end
  end

  def stub_controller_with_exception
    controller_class = define_controller('Examples') do
      def create
        raise SimulatedError
      end
    end

    setup_rails_controller_test(controller_class)

    define_routes do
      get 'examples', to: 'examples#create'
    end
  end

  class SimulatedError < StandardError; end
end
