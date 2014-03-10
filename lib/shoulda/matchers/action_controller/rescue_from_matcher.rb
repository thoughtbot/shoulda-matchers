module Shoulda
  module Matchers
    module ActionController
      def rescue_from(exception)
        RescueFromMatcher.new exception
      end

      class RescueFromMatcher
        def initialize(exception)
          @exception = exception
        end

        def with(method)
          @expected_method = method
          self
        end

        def matches?(controller)
          @controller = controller
          rescues_from_exception? && method_name_matches? && handler_exists?
        end

        def description
          description = "rescues from #{exception}"
          description << " with ##{expected_method}" if expected_method
          description
        end

        def failure_message
          "Expected #{expectation}"
        end
        alias failure_message_for_should failure_message

        def failure_message_when_negated
          "Did not expect #{expectation}"
        end
        alias failure_message_for_should_not failure_message_when_negated

        private

        attr_reader :controller, :exception, :expected_method, :handlers

        def expectation
          expectation = "#{controller} to rescue from #{exception}"

          if expected_method && !method_name_matches?
            expectation << " with ##{expected_method}"
          end

          unless handler_exists?
            expectation << " but #{controller} does not respond to #{expected_method}"
          end
          expectation
        end

        def rescues_from_exception?
          @handlers = controller.rescue_handlers.select do |handler|
            handler.first == exception.to_s
          end
          handlers.any?
        end

        def method_name_matches?
          if expected_method.present?
            handlers.any? do |handler|
              handler.last == expected_method
            end
          else
            true
          end
        end

        def handler_exists?
          if expected_method.present?
            controller.respond_to? expected_method, true
          else
            true
          end
        end
      end
    end
  end
end
