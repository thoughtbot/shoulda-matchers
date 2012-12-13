require 'bourne'
require 'strong_parameters'

module Shoulda
  module Matchers
    module ActionController

      def permit(attributes)
        StrongParametersMatcher.new(attributes, self)
      end

      class StrongParametersMatcher

        def initialize(attributes, context)
          @attributes = attributes
          @context = context
        end

        def for(action)
          @action = action
          self
        end

        def matches?(controller)
          extend Mocha::API
          values = {name: 'George', admin: true}
          model_attrs = ::ActionController::Parameters.new(values)
          model_attrs.stubs(:permit)
          ::ActionController::Parameters.any_instance.stubs(:[]).returns(model_attrs)

          action = @action

          @context.instance_eval do
            post action, user: values
          end

          model_attrs.should have_received(:permit).with(@attributes)
        end

        def failure_message
          'nil'
        end
      end
    end
  end
end
