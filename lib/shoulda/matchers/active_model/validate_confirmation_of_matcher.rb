module Shoulda # :nodoc:
  module Matchers
    module ActiveModel # :nodoc:

      # Ensures that the model's attribute matches confirmation
      #
      # Example:
      #   it { should validate_confirmation_of(:password) }
      #
      def validate_confirmation_of(attr)
        ValidateConfirmationOfMatcher.new(attr)
      end

      class ValidateConfirmationOfMatcher # :nodoc:

        def initialize(attribute)
          @attribute = attribute.to_s
        end

        def with_message(message)
          @expected_message = message if message
          self
        end

        def matches?(subject)
          @subject = subject
          @expected_message ||= :confirmed
          match_confirmation
        end

        def description
          "require #{@attribute} match confirmation"
        end

        attr_reader :failure_message, :negative_failure_message

        private

        def match_confirmation
          if @subject.instance_variable_get(:"@#{@attribute}_confirmation")
            if @subject.instance_variable_get(:"@#{@attribute}_confirmation") == @subject.send("#{@attribute}")
              @negative_failure_message = "#{@attribute} matches confirmation"
              true
            else
              @failure_message = "#{@attribute} should match #{@attribute}_confirmation"
              false
            end
          else
            @failure_message = "Expected #{@attribute} to have confirmation"
            false
          end
        end

      end

    end
  end
end
