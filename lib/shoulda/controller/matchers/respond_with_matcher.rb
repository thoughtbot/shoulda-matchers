module Shoulda # :nodoc:
  module Controller # :nodoc:
    module Matchers

      # docs
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
        
        def failure_message
          "Expected status to be #{@status}"
        end
        
        def negative_failure_message
          "Did not expect status to be #{@status} but was #{response_code}"
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
            ActionController::StatusCodes::SYMBOL_TO_STATUS_CODE[potential_symbol]
          else
            potential_symbol
          end
        end
        
      end
      
    end
  end
end