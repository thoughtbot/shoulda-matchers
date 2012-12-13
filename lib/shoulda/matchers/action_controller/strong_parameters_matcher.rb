require 'bourne'
require 'strong_parameters'

module Shoulda
  module Matchers
    module ActionController

      def permit(attributes)
        StrongParametersMatcher.new(attributes, self)
      end

      class StrongParametersMatcher

        def initialize(*attributes, context)
          @attributes = attributes
          @context = context
        end

        def for(action)
          @action = action
          self
        end

        def matches?(controller)
          extend Mocha::API

          model_attrs = ::ActionController::Parameters.new(arbitrary_attributes)
          model_attrs.stubs(:permit)


          ::ActionController::Parameters.any_instance.stubs(:[]).returns(model_attrs)

          @context.send(:post, @action)

          begin
            model_attrs.should have_received(:permit).with { |*params|
              @attributes.all? do |attribute|
                params.include?(attribute)
              end
            }
          rescue RSpec::Expectations::ExpectationNotMetError, Mocha::ExpectationError
            false
          end
        end

        def failure_message
          'nil'
        end

        private

        def arbitrary_attributes
          {any_key: 'any_value'}
        end
      end
    end
  end
end
