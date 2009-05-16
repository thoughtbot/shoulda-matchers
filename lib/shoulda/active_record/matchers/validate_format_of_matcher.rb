module Shoulda # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers

      # Ensures that the model is not valid if the given attribute is not
      # formatted correctly.
      #
      # Options:
      # * <tt>with_message</tt> - value the test expects to find in
      #   <tt>errors.on(:attribute)</tt>. <tt>Regexp</tt> or <tt>String</tt>.
      #   Defaults to the translation for <tt>:blank</tt>.
      # * <tt>with(string to test against)</tt>
      # * <tt>not_with(string to test against)</tt>
      #
      # Examples:
      #   it { should validate_format_of(:name).
      #                 with('12345').
      #                 with_message(/is not optional/) }
      #   it { should validate_format_of(:name).
      #                 not_with('12D45').
      #                 with_message(/is not optional/) }
      #
      def validate_format_of(attr)
        ValidateFormatOfMatcher.new(attr)
      end

      class ValidateFormatOfMatcher < ValidationMatcher # :nodoc:
        
        def initialize(attribute)
          super
        end

        def with_message(message)
          @expected_message = message if message
          self
        end
        
        def with(value)
          raise "You may not call both with and not_with" if @value_to_fail
          @value_to_pass = value
          self
        end
        

        def not_with(value)
          raise "You may not call both with and not_with" if @value_to_pass
          @value_to_fail = value
          self
        end


        def matches?(subject)
          super(subject)
          @expected_message ||= :blank
          return disallows_value_of(@value_to_fail, @expected_message) if @value_to_fail
          allows_value_of(@value_to_pass, @expected_message) if @value_to_pass
        end

        def description
          "#{@attribute} have a valid format"
        end

      end

    end
  end
end
