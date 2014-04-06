begin
  require 'strong_parameters'
rescue LoadError
end

module Shoulda
  module Matchers
    module ActionController
      def permit(*attributes)
        StrongParametersMatcher.new(self, attributes)
      end

      class StrongParametersMatcher
        def self.stubbed_parameters_class
          @stubbed_parameters_class ||= build_stubbed_parameters_class
        end

        def self.build_stubbed_parameters_class
          Class.new(::ActionController::Parameters) do
            include StubbedParameters
          end
        end

        def initialize(context = nil, attributes)
          @attributes = attributes
          @context = context
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

        def matches?(controller = nil)
          simulate_controller_action && parameters_difference.empty?
        end

        def does_not_match?(controller = nil)
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

        attr_reader :verb, :action, :attributes, :context

        def simulate_controller_action
          ensure_action_and_verb_present!
          stub_model_attributes

          begin
            context.send(verb, action)
          ensure
            unstub_model_attributes
          end

          verify_permit_call
        end

        def verify_permit_call
          @model_attrs.permit_was_called
        end

        def parameters_difference
          attributes - @model_attrs.shoulda_permitted_params
        end

        def parameters_intersection
          attributes & @model_attrs.shoulda_permitted_params
        end

        def stub_model_attributes
          @model_attrs = self.class.stubbed_parameters_class.new(arbitrary_attributes)

          local_model_attrs = @model_attrs
          ::ActionController::Parameters.class_eval do
            alias_method :'shoulda_original_[]', :[]

            define_method :[] do |*args|
              local_model_attrs
            end
          end
        end

        def unstub_model_attributes
          ::ActionController::Parameters.class_eval do
            alias_method :[], :'shoulda_original_[]'
            undef_method :'shoulda_original_[]'
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

        def arbitrary_attributes
          {any_key: 'any_value'}
        end

        def verb_for_action
          verb_lookup = { create: :post, update: :put }
          verb_lookup[action]
        end

        def attributes_as_sentence
          attributes.map(&:inspect).to_sentence
        end
      end

      module StrongParametersMatcher::StubbedParameters
        extend ActiveSupport::Concern

        included do
          attr_accessor :permit_was_called, :shoulda_permitted_params
        end

        def initialize(*)
          @permit_was_called = false
          super
        end

        def permit(*args)
          self.shoulda_permitted_params = args
          self.permit_was_called = true
          nil
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
