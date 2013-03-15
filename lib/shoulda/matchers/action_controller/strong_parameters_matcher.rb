require 'bourne'
require 'active_support/deprecation'
begin
  require 'strong_parameters'
rescue LoadError
end

module Shoulda
  module Matchers
    module ActionController
      def permit(*attributes)
        attributes_and_context = attributes + [self]
        StrongParametersMatcher.new(*attributes_and_context)
      end

      class StrongParametersMatcher
        def initialize(*attributes_and_context)
          ActiveSupport::Deprecation.warn 'The strong_parameters matcher is deprecated and will be removed in 2.0'
          @attributes = attributes_and_context[0...-1]
          @context = attributes_and_context.last
          @permitted_params = []
        end

        def for(action, options = {})
          @action = action
          @verb = options[:verb] || verb_for_action
          self
        end

        def in_context(context)
          @context = context
          self
        end

        def matches?(controller = nil)
          simulate_controller_action && parameters_difference.empty?
        end

        def does_not_match?(controller = nil)
          simulate_controller_action && parameters_difference.present?
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

          verify_permit_call(model_attrs)
        end

        def verify_permit_call(model_attrs)
          matcher = Mocha::API::HaveReceived.new(:permit).with do |*params|
            self.permitted_params = params
          end

          matcher.matches?(model_attrs)
        rescue Mocha::ExpectationError
          false
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
          if action.blank?
            raise ActionNotDefinedError
          end
          if verb.blank?
            raise VerbNotDefinedError
          end
        end

        def arbitrary_attributes
          {:any_key => 'any_value'}
        end

        def verb_for_action
          verb_lookup = { :create => :post, :update => :put }
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
          ' e.g. for(:authorize, :verb => :post)'
        end
      end
    end
  end
end
