module Shoulda # :nodoc:
  module Matchers
    module ActiveModel # :nodoc:

      # Ensures that the model is not valid if the given attribute is not
      # formatted correctly.
      #
      # Options:
      # * <tt>with_message</tt> - value the test expects to find in
      #   <tt>allow_blank</tt> - allows a blank value
      #   <tt>allow_nil</tt> - allows a nil value
      #   <tt>errors.on(:attribute)</tt>. <tt>Regexp</tt> or <tt>String</tt>.
      #   Defaults to the translation for <tt>:invalid</tt>.
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
          @options = {}
        end

        def allow_blank(allow_blank = true)
          @options[:allow_blank] = allow_blank
          self
        end

        def allow_nil(allow_nil = true)
          @options[:allow_nil] = allow_nil
          self
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
          @expected_message ||= :invalid

          if @value_to_fail
            disallows_value_of(@value_to_fail, @expected_message) && allows_blank_value? && allows_nil_value?
          else
            allows_value_of(@value_to_pass, @expected_message) && allows_blank_value? && allows_nil_value?
          end
        end

        def description
          "#{@attribute} have a valid format"
        end

        private

        def allows_blank_value?
          if @options.key?(:allow_blank)
            @options[:allow_blank] == allows_value_of('')
          else
            true
          end
        end

        def allows_nil_value?
          if @options.key?(:allow_nil)
            @options[:allow_nil] == allows_value_of(nil)
          else
            true
          end
        end
      end

    end
  end
end
