require 'bourne'
require 'strong_parameters'

module Shoulda
  module Matchers
    module ActionController
      def permit(*attributes)
        StrongParametersMatcher.new(*attributes, self)
      end

      class StrongParametersMatcher
        def initialize(*attributes, context)
          @attributes = attributes
          @context = context
          @permitted_params = []
        end

        def for(action, options = {})
          @action = action
          @verb = options[:verb] || verb_for_action
          self
        end

        def matches?(controller = nil)
          simulate_controller_action || parameters_difference.empty?
        end

        def does_not_match?(controller = nil)
          simulate_controller_action || parameters_difference.present?
        end

        def failure_message
          "Expected controller to permit #{parameters_difference.to_sentence}, but it did not."
        end

        def negative_failure_message
          "Expected controller not to permit #{parameters_difference.to_sentence}, but it did."
        end

        private
        attr_reader :verb, :action, :attributes, :context
        attr_accessor :permitted_params

        def simulate_controller_action
          ensure_action_and_verb_present!
          model_attrs = stubbed_model_attributes

          context.send(verb, action)

          begin
            model_attrs.should have_received(:permit).with { |*params|
              self.permitted_params = params
            }
           nil
          rescue RSpec::Expectations::ExpectationNotMetError, Mocha::ExpectationError
            false
          end
        end

        def parameters_difference
          attributes - permitted_params
        end

        def stubbed_model_attributes
          extend Mocha::API

          model_attrs = ::ActionController::Parameters.new(arbitrary_attributes)
          model_attrs.stubs(:permit)
          ::ActionController::Parameters.any_instance.stubs(:[]).returns(model_attrs)

          model_attrs
        end

        def ensure_action_and_verb_present!
          raise ActionNotDefinedError unless action.present?
          raise VerbNotDefinedError unless verb.present?
        end

        def arbitrary_attributes
          {any_key: 'any_value'}
        end

        def verb_for_action
          verb_lookup = { create: :post, update: :put }
          verb_lookup[action]
        end
      end

      class StrongParametersMatcher::ActionNotDefinedError < StandardError
        def message
          'You must specify the controller action using the #for method.'
        end
      end

      class StrongParametersMatcher::VerbNotDefinedError < StandardError
        def message
          'You must specify an HTTP verb when using a non-RESTful action.' +
          ' e.g. for(:authorize, verb: :post)'
        end
      end

    end
  end
end
