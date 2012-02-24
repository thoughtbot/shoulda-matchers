module Shoulda # :nodoc:
  module Matchers
    module ActiveModel # :nodoc:

      # Ensures that the model cannot be saved the given attribute is not
      # confirmed.
      #
      # Options:
      # * <tt>with_message</tt> - value the test expects to find in
      # 
      #
      # Example:
      #   it { should validate_confirmation_of(:password) }
      #
      def validate_confirmation_of(attr)
        ValidateConfirmationOf.new(attr)
      end

      class ValidateConfirmationOf < ValidationMatcher # :nodoc:

        def with_message(message)
          @expected_message = message if message
          self
        end
        
        def with_value(value)
          @test_value = value
          self
        end
        
        def with_unconfirmed_value(value)
          @unconfirmed_value = value
          self
        end

        def matches?(subject)
          super(subject)
          @expected_message ||= :confirmation
          subject[@attribute] ||= (@test_value || 'some value')
          subject.send("#{@attribute}_confirmation=", subject[@attribute])
          allows_confirmed = allows_value_of(subject[@attribute], @expected_message)
          subject.send("#{@attribute}_confirmation=", (@unconfirmed_value || (subject[@attribute] + ' something')))
          allows_confirmed && disallows_value_of(subject[@attribute], @expected_message)
        end

        def description
          "require #{@attribute} to be confirmed"
        end

      end

    end
  end
end

