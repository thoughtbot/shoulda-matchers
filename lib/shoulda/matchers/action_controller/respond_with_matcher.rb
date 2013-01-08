module Shoulda # :nodoc:
  module Matchers
    module ActionController # :nodoc:

      # Ensures a controller responded with expected 'response' status code.
      #
      # You can pass an explicit status number like 200, 301, 404, 500
      # or its symbolic equivalent :success, :redirect, :missing, :error.
      # See ActionController::StatusCodes for a full list.
      #
      # Example:
      #
      #   it { should respond_with(:success)  }
      #   it { should respond_with(:redirect) }
      #   it { should respond_with(:missing)  }
      #   it { should respond_with(:error)    }
      #   it { should respond_with(501)       }
      def respond_with(status)
        RespondWithMatcher.new(status)
      end

      class RespondWithMatcher # :nodoc:

        def initialize(status)
          @status = symbol_to_status_code(status)
        end

        def matches?(controller)
          @controller = controller
          correct_status_code? || correct_status_code_range?
        end

        def failure_message_for_should
          "Expected #{expectation}"
        end

        def failure_message_for_should_not
          "Did not expect #{expectation}"
        end

        def description
          "respond with #{@status}"
        end

        protected

        def correct_status_code?
          response_code == @status
        end

        def correct_status_code_range?
          @status.is_a?(Range) &&
            @status.include?(response_code)
        end

        def response_code
          @controller.response.response_code
        end

        def symbol_to_status_code(potential_symbol)
          case potential_symbol
          when :success  then 200
          when :redirect then 300..399
          when :missing  then 404
          when :error    then 500..599
          when Symbol
            if defined?(::Rack::Utils::SYMBOL_TO_STATUS_CODE)
              ::Rack::Utils::SYMBOL_TO_STATUS_CODE[potential_symbol]
            else
              ::ActionController::Base::SYMBOL_TO_STATUS_CODE[potential_symbol]
            end
          else
            potential_symbol
          end
        end

        def expectation
          "response to be a #{@status}, but was #{response_code}"
        end
      end
    end
  end
end
