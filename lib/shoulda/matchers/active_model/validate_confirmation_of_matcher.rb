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

        attr_reader :attribute, :confirmation_attribute

        def initialize(attribute)
          @attribute = attribute
          @confirmation_attribute = "#{attribute}_confirmation"
        end

        def with_message(message)
          @message = message if message
          self
        end

        def description
          "require #{@confirmation_attribute} to match #{@attribute}"
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
          set_confirmation('some value')
          disallows_value_of('different value') do |matcher|
            matcher.with_message(@message, against: error_attribute)
          end
        end

        def allows_same_value
          set_confirmation('same value')
          allows_value_of('same value') do |matcher|
            matcher.with_message(@message, against: error_attribute)
          end
        end

        def allows_missing_confirmation
          set_confirmation(nil)
          allows_value_of('any value') do |matcher|
            matcher.with_message(@message, against: error_attribute)
          end
        end

        def set_confirmation(val)
          setter = :"#{@confirmation_attribute}="
          if @subject.respond_to?(setter)
            @subject.__send__(setter, val)
          end
        end

        def error_attribute
          RailsShim.validates_confirmation_of_error_attribute(self)
        end
      end
    end
  end
end
