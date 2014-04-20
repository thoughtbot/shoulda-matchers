require 'delegate'

begin
  require 'strong_parameters'
rescue LoadError
end

require 'active_support/hash_with_indifferent_access'

module Shoulda
  module Matchers
    module ActionController
      def permit(*params)
        StrongParametersMatcher.new(params).in_context(self)
      end

      class StrongParametersMatcher
        attr_writer :stubbed_params

        def initialize(expected_permitted_params)
          @action = nil
          @verb = nil
          @request_params = {}
          @expected_permitted_params = expected_permitted_params
          set_double_collection
        end

        def for(action, options = {})
          @action = action
          @verb = options.fetch(:verb, default_verb)
          @request_params = options.fetch(:params, {})
          self
        end

        def in_context(context)
          @context = context
          self
        end

        def description
          "permit #{verb.upcase} ##{action} to receive parameters #{param_names_as_sentence}"
        end

        def matches?(controller)
          @controller = controller
          ensure_action_and_verb_present!

          Doublespeak.with_doubles_activated do
            context.__send__(verb, action, request_params)
          end

          unpermitted_params.empty?
        end

        def failure_message
          "Expected controller to permit #{unpermitted_params.to_sentence}, but it did not."
        end
        alias failure_message_for_should failure_message

        def failure_message_when_negated
          "Expected controller not to permit #{verified_permitted_params.to_sentence}, but it did."
        end
        alias failure_message_for_should_not failure_message_when_negated

        private

        attr_reader :controller, :double_collection, :action, :verb,
          :request_params, :expected_permitted_params, :context

        def set_double_collection
          @double_collection =
            Doublespeak.register_double_collection(::ActionController::Parameters)

          @double_collection.register_stub(:require).to_return { |params| params }
          @double_collection.register_proxy(:permit)
        end

        def actual_permitted_params
          double_collection.calls_to(:permit).inject([]) do |all_param_names, call|
            all_param_names + call.args
          end.flatten
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

        class ActionNotDefinedError < StandardError
          def message
            'You must specify the controller action using the #for method.'
          end
        end

        class VerbNotDefinedError < StandardError
          def message
            'You must specify an HTTP verb when using a non-RESTful action. For example: for(:authorize, verb: :post)'
          end
        end
      end
    end
  end
end
