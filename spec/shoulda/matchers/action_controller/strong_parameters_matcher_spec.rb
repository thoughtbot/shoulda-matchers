require 'spec_helper'

describe Shoulda::Matchers::ActionController do
  describe '#permit' do
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

  describe '#matches?' do
    it 'is true for a subset of the allowable attributes' do
      controller_for_resource_with_strong_parameters(action: :create) do
        params.require(:user).permit(:name)
      end

      matcher = described_class.new([:name]).in_context(self).for(:create)
      expect(matcher.matches?(@controller)).to be_true
    end

    it 'is true for all the allowable attributes' do
      controller_for_resource_with_strong_parameters(action: :create) do
        params.require(:user).permit(:name, :age)
      end

      matcher = described_class.new([:name, :age]).in_context(self).for(:create)
      expect(matcher.matches?(@controller)).to be_true
    end

    it 'is false when any attributes are not allowed' do
      controller_for_resource_with_strong_parameters(action: :create) do
        params.require(:user).permit(:name)
      end

      matcher = described_class.new([:name, :admin]).in_context(self).for(:create)
      expect(matcher.matches?(@controller)).to be_false
    end

    it 'is false when permit is not called' do
      controller_for_resource_with_strong_parameters(action: :create)

      matcher = described_class.new([:name]).in_context(self).for(:create)
      expect(matcher.matches?(@controller)).to be_false
    end

    it 'requires an action' do
      controller_for_resource_with_strong_parameters
      matcher = described_class.new([:name])
      expect { matcher.matches?(@controller) }.
        to raise_error(described_class::ActionNotDefinedError)
    end

    it 'requires a verb for non-restful action' do
      controller_for_resource_with_strong_parameters
      matcher = described_class.new([:name]).for(:authorize)
      expect { matcher.matches?(@controller) }.
        to raise_error(described_class::VerbNotDefinedError)
    end

    it 'works with routes that require extra params' do
      options = {
        controller_name: 'Posts',
        action: :show,
        routes: -> {
          get '/posts/:slug', to: 'posts#show'
        }
      }
      controller_for_resource_with_strong_parameters(options) do
        params.require(:user).permit(:name)
      end

      matcher = described_class.new([:name]).
        in_context(self).
        for(:show, verb: :get, params: { slug: 'foo' })
      expect(matcher.matches?(@controller)).to be_true
    end

    it 'works with #update specifically' do
      controller_for_resource_with_strong_parameters(action: :update) do
        params.require(:user).permit(:name)
      end

      matcher = described_class.new([:name]).
        in_context(self).
        for(:update, params: { id: 1 })
      expect(matcher.matches?(@controller)).to be_true
    end

    it 'does not raise an error when #fetch was used instead of #require (issue #495)' do
      controller_for_resource_with_strong_parameters(action: :create) do
        params.fetch(:order, {}).permit(:eta, :diner_id)
      end

      matcher = described_class.new([:eta, :diner_id]).
        in_context(self).
        for(:create)
      expect(matcher.matches?(@controller)).to be_true
    end

    it 'tracks multiple calls to #permit' do
      sets_of_attributes = [
        [:eta, :diner_id],
        [:phone_number, :address_1, :address_2, :city, :state, :zip]
      ]
      controller_for_resource_with_strong_parameters(action: :create) do
        params.require(:order).permit(sets_of_attributes[0])
        params.require(:diner).permit(sets_of_attributes[1])
      end

      matcher = described_class.new(sets_of_attributes[0]).
        in_context(self).
        for(:create)
      expect(matcher.matches?(@controller)).to be_true

      matcher = described_class.new(sets_of_attributes[1]).
        in_context(self).
        for(:create)
      expect(matcher.matches?(@controller)).to be_true
    end

    context 'stubbing params on the controller' do
      it 'still allows the original params to be set and accessed' do
        actual_user_params = nil
        actual_foo_param = nil

        controller_for_resource_with_strong_parameters(action: :create) do
          params[:foo] = 'bar'
          actual_foo_param = params[:foo]

          actual_user_params = params[:user]

          params.require(:user).permit(:name)
        end

        matcher = described_class.new([:name]).
          in_context(self).
          for(:create, params: { user: { some: 'params' } })
        matcher.matches?(@controller)

        expect(actual_user_params).to eq('some' => 'params')
        expect(actual_foo_param).to eq 'bar'
      end

      it 'stubs the params during the controller action' do
        controller_for_resource_with_strong_parameters(action: :create) do
          params.require(:user)
        end

        matcher = described_class.new([:name]).in_context(self).for(:create)

        expect { matcher.matches?(@controller) }.not_to raise_error
      end

      it 'does not permanently stub params' do
        controller_for_resource_with_strong_parameters(action: :create)

        matcher = described_class.new([:name]).in_context(self).for(:create)
        matcher.matches?(@controller)

        expect {
          @controller.params.require(:user)
        }.to raise_error(::ActionController::ParameterMissing)
      end

      it 'prevents permanently stubbing params on error' do
        stub_controller_with_exception

        begin
          matcher = described_class.new([:name]).in_context(self).for(:create)
          matcher.matches?(@controller)
        rescue SimulatedError
        end

        expect {
          @controller.params.require(:user)
        }.to raise_error(::ActionController::ParameterMissing)
      end
    end
  end

  describe 'failure message' do
    it 'includes all missing attributes' do
      controller_for_resource_with_strong_parameters(action: :create) do
        params.require(:user).permit(:name, :age)
      end

      expect {
        expect(@controller).to permit(:name, :age, :city, :country).for(:create)
      }.to fail_with_message('Expected controller to permit city and country, but it did not.')
    end

    it 'includes all attributes that should not have been allowed but were' do
      controller_for_resource_with_strong_parameters(action: :create) do
        params.require(:user).permit(:name, :age)
      end

      expect {
        expect(@controller).not_to permit(:name, :age).for(:create)
      }.to fail_with_message('Expected controller not to permit name and age, but it did.')
    end
  end

  describe '#for' do
    context 'when given :create' do
      it 'POSTs to the controller' do
        controller = ActionController::Base.new
        context = mock()
        context.expects(:post).with(:create, {})
        matcher = described_class.new([:name]).in_context(context).for(:create)

        matcher.matches?(controller)
      end
    end

    context 'when given :update' do
      if rails_gte_4_1?
        it 'PATCHes to the controller' do
          controller = ActionController::Base.new
          context = mock()
          context.expects(:patch).with(:update, {})
          matcher = described_class.new([:name]).in_context(context).for(:update)

          matcher.matches?(controller)
        end
      else
        it 'PUTs to the controller' do
          controller = ActionController::Base.new
          context = mock()
          context.expects(:put).with(:update, {})
          matcher = described_class.new([:name]).in_context(context).for(:update)

          matcher.matches?(controller)
        end
      end
    end

    context 'when given a custom action and verb' do
      it 'calls the action with the verb' do
        controller = ActionController::Base.new
        context = mock()
        context.expects(:delete).with(:hide, {})
        matcher = described_class.new([:name]).
          in_context(context).
          for(:hide, verb: :delete)

        matcher.matches?(controller)
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
