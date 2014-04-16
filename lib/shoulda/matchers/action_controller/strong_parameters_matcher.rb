require 'delegate'

begin
  require 'strong_parameters'
rescue LoadError
end

require 'active_support/hash_with_indifferent_access'

module Shoulda
  module Matchers
    module ActionController
      def permit(*attributes)
        StrongParametersMatcher.new(self, attributes)
      end

      class StrongParametersMatcher
        attr_writer :stubbed_params

        def initialize(context = nil, attributes)
          @attributes = attributes
          @context = context
          @stubbed_params = NullStubbedParameters.new
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

        def description
          "permit #{verb.upcase} ##{action} to receive parameters #{attributes_as_sentence}"
        end

        def matches?(controller)
          @controller = controller
          simulate_controller_action && parameters_difference.empty?
        end

        def does_not_match?(controller)
          @controller = controller
          simulate_controller_action && parameters_intersection.empty?
        end

        def failure_message
          "Expected controller to permit #{parameters_difference.to_sentence}, but it did not."
        end
        alias failure_message_for_should failure_message

        def failure_message_when_negated
          "Expected controller not to permit #{parameters_intersection.to_sentence}, but it did."
        end
        alias failure_message_for_should_not failure_message_when_negated

        private

        attr_reader :controller, :verb, :action, :attributes, :context

        def simulate_controller_action
          ensure_action_and_verb_present!
          stub_params

          begin
            context.send(verb, action)
          ensure
            unstub_params
          end

          verify_permit_call
        end

        def verify_permit_call
          @stubbed_params.permit_was_called
        end

        def parameters_difference
          attributes - @stubbed_params.shoulda_permitted_params
        end

        def parameters_intersection
          attributes & @stubbed_params.shoulda_permitted_params
        end

        def stub_params
          matcher = self

          controller.singleton_class.class_eval do
            alias_method :__shoulda_original_params__, :params

            define_method :params do
              matcher.stubbed_params = StubbedParameters.new(__shoulda_original_params__)
            end
          end
        end

        def unstub_params
          controller.singleton_class.class_eval do
            alias_method :params, :__shoulda_original_params__
          end
        end

        def ensure_action_and_verb_present!
          if action.blank?
            raise ActionNotDefinedError
          end
          if verb.blank?
            raise VerbNotDefinedError
          end
        end

        def verb_for_action
          verb_lookup = { create: :post, update: :put }
          verb_lookup[action]
        end

        def attributes_as_sentence
          attributes.map(&:inspect).to_sentence
        end

        class StubbedParameters < SimpleDelegator
          attr_reader :permit_was_called, :shoulda_permitted_params

          def initialize(original_params)
            super(original_params)
            @permit_was_called = false
          end

          def require(*args)
            self
          end

          def permit(*args)
            @shoulda_permitted_params = args
            @permit_was_called = true
            super(*args)
          end
        end

        class NullStubbedParameters < ActiveSupport::HashWithIndifferentAccess
          def permit_was_called; false; end
          def shoulda_permitted_params; self; end
          def require(*); self; end
          def permit(*); self; end
        end

        class ActionNotDefinedError < StandardError
          def message
            'You must specify the controller action using the #for method.'
          end
        end

        class VerbNotDefinedError < StandardError
          def message
            'You must specify an HTTP verb when using a non-RESTful action.' +
            ' e.g. for(:authorize, verb: :post)'
          end
        end
      end
    end
  end
end
