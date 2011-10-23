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

      class ValidateConfirmationOfMatcher < ValidationMatcher # :nodoc:
        include Helpers

        def initialize(attribute)
          @attribute = attribute
          @confirmation = "#{attribute}_confirmation"
        end

        def with_message(message)
          @message = message if message
          self
        end

        def description
          "require #{@base_attribute} to match #{@attribute}"
        end

        def matches?(subject)
          super(subject)
          @message ||= :confirmation

          disallows_different_value &&
            allows_same_value &&
            allows_missing_confirmation
        end

        private

        def disallows_different_value
          @subject.send(:"#{@confirmation}=", "some value")
          matches = disallows_value_of("different value", @message)
        end

        def allows_same_value
          @subject.send(:"#{@confirmation}=", "same value")
          allows_value_of("same value", @message)
        end

        def allows_missing_confirmation
          @subject.send(:"#{@confirmation}=", nil)
          allows_value_of("any value", @message)
        end
      end
    end
  end
end
