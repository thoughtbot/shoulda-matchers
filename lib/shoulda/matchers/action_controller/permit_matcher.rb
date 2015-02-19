require 'delegate'

begin
  require 'strong_parameters'
rescue LoadError
end

require 'active_support/hash_with_indifferent_access'

module Shoulda
  module Matchers
    module ActionController
      # The `permit` matcher tests that an action in your controller receives a
      # whitelist of parameters using Rails' Strong Parameters feature
      # (specifically that `permit` was called with the correct arguments).
      #
      # Here's an example:
      #
      #     class UsersController < ApplicationController
      #       def create
      #         user = User.create(user_params)
      #         # ...
      #       end
      #
      #       private
      #
      #       def user_params
      #         params.require(:user).permit(
      #           :first_name,
      #           :last_name,
      #           :email,
      #           :password
      #         )
      #       end
      #     end
      #
      #     # RSpec
      #     describe UsersController do
      #       it do
      #         should permit(:first_name, :last_name, :email, :password).
      #           for(:create).
      #           on(:user)
      #       end
      #     end
      #
      #     # Test::Unit
      #     class UsersControllerTest < ActionController::TestCase
      #       should permit(:first_name, :last_name, :email, :password).
      #         for(:create).
      #         on(:user)
      #     end
      #
      # If your action requires query parameters in order to work, then you'll
      # need to supply them:
      #
      #     class UsersController < ApplicationController
      #       def update
      #         user = User.find(params[:id])
      #
      #         if user.update_attributes(user_params)
      #           # ...
      #         else
      #           # ...
      #         end
      #       end
      #
      #       private
      #
      #       def user_params
      #         params.require(:user).permit(
      #           :first_name,
      #           :last_name,
      #           :email,
      #           :password
      #         )
      #       end
      #     end
      #
      #     # RSpec
      #     describe UsersController do
      #       before do
      #         create(:user, id: 1)
      #       end
      #
      #       it do
      #         should permit(:first_name, :last_name, :email, :password).
      #           for(:update, params: { id: 1 }).
      #           on(:user)
      #       end
      #     end
      #
      #     # Test::Unit
      #     class UsersControllerTest < ActionController::TestCase
      #       setup do
      #         create(:user, id: 1)
      #       end
      #
      #       should permit(:first_name, :last_name, :email, :password).
      #         for(:update, params: { id: 1 }).
      #         on(:user)
      #     end
      #
      # Finally, if you have an action that isn't one of the seven resourceful
      # actions, then you'll need to provide the HTTP verb that it responds to:
      #
      #     Rails.application.routes.draw do
      #       resources :users do
      #         member do
      #           put :toggle
      #         end
      #       end
      #     end
      #
      #     class UsersController < ApplicationController
      #       def toggle
      #         user = User.find(params[:id])
      #
      #         if user.update_attributes(user_params)
      #           # ...
      #         else
      #           # ...
      #         end
      #       end
      #
      #       private
      #
      #       def user_params
      #         params.require(:user).permit(:activated)
      #       end
      #     end
      #
      #     # RSpec
      #     describe UsersController do
      #       before do
      #         create(:user, id: 1)
      #       end
      #
      #       it do
      #         should permit(:activated).
      #           for(:toggle, params: { id: 1 }, verb: :put).
      #           on(:user)
      #       end
      #     end
      #
      #     # Test::Unit
      #     class UsersControllerTest < ActionController::TestCase
      #       setup do
      #         create(:user, id: 1)
      #       end
      #
      #       should permit(:activated).
      #         for(:toggle, params: { id: 1 }, verb: :put).
      #         on(:user)
      #     end
      #
      # @return [PermitMatcher]
      #
      def permit(*params)
        PermitMatcher.new(params).in_context(self)
      end

      # @private
      class PermitMatcher
        attr_writer :stubbed_params

        def initialize(expected_permitted_params)
          @expected_permitted_params = expected_permitted_params
          @action = nil
          @verb = nil
          @request_params = {}
          @subparameter = nil
          @parameters_doubles = ParametersDoubles.new
        end

        def for(action, options = {})
          @action = action
          @verb = options.fetch(:verb, default_verb)
          @request_params = options.fetch(:params, {})
          self
        end

        def add_params(params)
          request_params.merge!(params)
          self
        end

        def on(subparameter)
          @subparameter = subparameter
          @parameters_doubles = SliceOfParametersDoubles.new(subparameter)
          self
        end

        def in_context(context)
          @context = context
          self
        end

        def description
          "(on #{verb.upcase} ##{action}) " + expectation
        end

        def matches?(controller)
          @controller = controller
          ensure_action_and_verb_present!

          parameters_doubles.register

          Doublespeak.with_doubles_activated do
            context.__send__(verb, action, request_params)
          end

          unpermitted_params.empty?
        end

        def failure_message
          "Expected #{verb.upcase} ##{action} to #{expectation},\nbut #{reality}."
        end
        alias failure_message_for_should failure_message

        def failure_message_when_negated
          "Expected #{verb.upcase} ##{action} not to #{expectation},\nbut it did."
        end
        alias failure_message_for_should_not failure_message_when_negated

        protected

        attr_reader :controller, :double_collections_by_param, :action, :verb,
          :request_params, :expected_permitted_params, :context, :subparameter,
          :parameters_doubles

        def expectation
          message = 'restrict parameters '

          if subparameter
            message << " for #{subparameter.inspect}"
          end

          message << 'to ' + format_param_names(expected_permitted_params)

          message
        end

        def reality
          if actual_permitted_params.empty?
            'it did not restrict any parameters'
          else
            'the restricted parameters were ' +
              format_param_names(actual_permitted_params) +
              ' instead'
          end
        end

        def format_param_names(param_names)
          param_names.map(&:inspect).to_sentence
        end

        def actual_permitted_params
          parameters_doubles.permitted_params
        end

        def permit_called?
          actual_permitted_params.any?
        end

        def unpermitted_params
          expected_permitted_params - actual_permitted_params
        end

        def verified_permitted_params
          expected_permitted_params & actual_permitted_params
        end

        def ensure_action_and_verb_present!
          if action.blank?
            raise ActionNotDefinedError
          end

          if verb.blank?
            raise VerbNotDefinedError
          end
        end

        def default_verb
          case action
            when :create then :post
            when :update then RailsShim.verb_for_update
          end
        end

        def param_names_as_sentence
          expected_permitted_params.map(&:inspect).to_sentence
        end

        # @private
        class ParametersDoubles
          def self.permitted_params_within(double_collection)
            double_collection.calls_to(:permit).map(&:args).flatten
          end

          def initialize
            klass = ::ActionController::Parameters
            @double_collection = Doublespeak.double_collection_for(klass)
          end

          def register
            double_collection.register_proxy(:permit)
          end

          def permitted_params
            ParametersDoubles.permitted_params_within(double_collection)
          end

          protected

          attr_reader :double_collection
        end

        # @private
        class SliceOfParametersDoubles
          TOP_LEVEL = Object.new

          def initialize(subparameter)
            klass = ::ActionController::Parameters

            @subparameter = subparameter
            @double_collections_by_param = {
              TOP_LEVEL => Doublespeak.double_collection_for(klass)
            }
          end

          def register
            top_level_collection = double_collections_by_param[TOP_LEVEL]
            double_permit_on(top_level_collection)
            double_require_on(top_level_collection)
          end

          def permitted_params
            if double_collections_by_param.key?(subparameter)
              ParametersDoubles.permitted_params_within(
                double_collections_by_param[subparameter]
              )
            else
              []
            end
          end

          protected

          attr_reader :subparameter, :double_collections_by_param

          private

          def double_permit_on(double_collection)
            double_collection.register_proxy(:permit)
          end

          def double_require_on(double_collection)
            double_collections_by_param = @double_collections_by_param
            require_double = double_collection.register_proxy(:require)

            require_double.to_return do |call|
              param_name = call.args.first
              params = call.return_value
              double_collections_by_param[param_name] ||=
                double_permit_against(params)
            end
          end

          def double_permit_against(params)
            klass = params.singleton_class

            Doublespeak.double_collection_for(klass).tap do |double_collection|
              double_permit_on(double_collection)
            end
          end
        end

        # @private
        class ActionNotDefinedError < StandardError
          def message
            'You must specify the controller action using the #for method.'
          end
        end

        # @private
        class VerbNotDefinedError < StandardError
          def message
            'You must specify an HTTP verb when using a non-RESTful action. For example: for(:authorize, verb: :post)'
          end
        end
      end
    end
  end
end
