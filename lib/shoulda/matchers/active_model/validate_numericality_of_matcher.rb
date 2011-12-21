module Shoulda # :nodoc:
  module Matchers
    module ActiveModel # :nodoc:
      # Ensure that the attribute is numeric.
      #
      # Options:
      # * <tt>with_message</tt> - value the test expects to find in
      #   <tt>errors.on(:attribute)</tt>. Regexp or string.  Defaults to the
      #   translation for <tt>:not_a_number</tt>.
      # * <tt>only_integer</tt> - allows only integer values
      # * <tt>with_greater_than_message</tt> - value the test expects to find in
      #   <tt>errors.on(:attribute)</tt> when parameter 'greater_than' added. Regexp or string.  Defaults to the
      #   translation for <tt>:greater_than</tt>.
      # * <tt>with_less_than_message</tt> - value the test expects to find in
      #   <tt>errors.on(:attribute)</tt> when parameter 'less_than' added. Regexp or string.  Defaults to the
      #   translation for <tt>:less_than</tt>.
      # * <tt>with_greater_than_or_equal_to_message</tt> - value the test expects to find in
      #   <tt>errors.on(:attribute)</tt> when parameter 'greater_than_or_equal_to' added. Regexp or string.  Defaults to the
      #   translation for <tt>:greater_than_or_equal_to</tt>.
      # * <tt>with_less_than_or_equal_to_message</tt> - value the test expects to find in
      #   <tt>errors.on(:attribute)</tt> when parameter 'less_than_or_equal_to' added. Regexp or string.  Defaults to the
      #   translation for <tt>:less_than_or_equal_to</tt>.
      # * <tt>with_equal_to_message</tt> - value the test expects to find in
      #   <tt>errors.on(:attribute)</tt> when parameter 'equal_to' added. Regexp or string.  Defaults to the
      #   translation for <tt>:equal_to</tt>.
      #
      # Example:
      #   it { should validate_numericality_of(:age) }
      #   it { should validate_numericality_of(:age).only_integer }
      #   it { should validate_numericality_of(:age).with_message('custom message') }
      #   it { should validate_numericality_of(:age).greater_than(18) }
      #   it { should validate_numericality_of(:age).greater_than(18).with_greater_than_message('custom message') }
      #   it { should validate_numericality_of(:age).less_than(300) }
      #   it { should validate_numericality_of(:age).less_than(300).with_less_than_message('custom message') }
      #   it { should validate_numericality_of(:age).greater_than_or_equal_to(18) }
      #   it { should validate_numericality_of(:age).greater_than_or_equal_to(18).with_greater_than_or_equal_to_message('custom message') }
      #   it { should validate_numericality_of(:age).less_than_or_equal_to(300) }
      #   it { should validate_numericality_of(:age).less_than_or_equal_to(300).with_less_than_or_equal_to_message('custom message') }
      #   it { should validate_numericality_of(:age).equal_to(25) }
      #   it { should validate_numericality_of(:age).equal_to(25).with_equal_to_message('custom message') }
      def validate_numericality_of(attr)
        ValidateNumericalityOfMatcher.new(attr)
      end

      class ValidateNumericalityOfMatcher < ValidationMatcher # :nodoc:
        include Helpers

        def initialize(attribute)
          super(attribute)
          @options = {}
        end

        def only_integer
          @options[:only_integer] = true
          self
        end

        [:greater_than, :less_than, :greater_than_or_equal_to, :less_than_or_equal_to, :equal_to].each do |method|
          define_method(method) do |number|
            instance_variable_set("@#{method}".to_sym, number) if number
            instance_variable_set("@#{method}_message".to_sym, method) unless instance_variable_get("@#{method}_message")
            self
          end

          define_method("with_#{method}_message") do |message|
            instance_variable_set("@#{method}_message".to_sym, message) if message
            self
          end
        end

        def with_message(message)
          if message
            @expected_message = message
          end
          self
        end

        def matches?(subject)
          super(subject)

          @expected_message ||= :not_a_number
          translate_messages!

          disallows_greater_than_value &&
            disallows_less_than_value &&
            disallows_greater_than_or_equal_to_value &&
            disallows_less_than_or_equal_to_value &&
            disallows_equal_to_value &&
            disallows_text_value &&
            disallows_non_integers
        end

        def description
          result = "only allow #{allowed_type} values for #{@attribute}"
          [:greater_than, :less_than, :greater_than_or_equal_to, :less_than_or_equal_to, :equal_to].each do |method|
            result << "#{method} #{instance_variable_get("@#{method}")}" if instance_variable_get("@#{method}")
          end
          result.join(', ') + " for #{@attribute}"
        end
        private

        def allowed_type
          if @options[:only_integer]
            "integer"
          else
            "numeric"
          end
        end

        def disallows_non_integers?
          if @options[:only_integer]
            message = @expected_message || :not_an_integer
            disallows_value_of(0.1, message)
          else
            true
          end
        end

        def disallows_text?
          message = @expected_message || :not_a_number
          disallows_value_of('abcd', message)
        end

          def disallows_greater_than_value
            @greater_than.nil? ? true : disallows_value_of(@greater_than, @greater_than_message)
          end

          def disallows_less_than_value
            @less_than.nil? ? true : disallows_value_of(@less_than, @less_than_message)
          end

          def disallows_greater_than_or_equal_to_value
            @greater_than_or_equal_to.nil? ? true : disallows_value_of(@greater_than_or_equal_to-1, @greater_than_or_equal_to_message)
          end

          def disallows_less_than_or_equal_to_value
            @less_than_or_equal_to.nil? ? true : disallows_value_of(@less_than_or_equal_to+1, @less_than_or_equal_to_message)
          end

          def disallows_equal_to_value
            @equal_to.nil? ? true : disallows_value_of(@equal_to+1, @equal_to_message)
          end

          def disallows_text_value
            disallows_value_of('abcd', @expected_message)
          end

          def translate_messages!
            if Symbol === @greater_than_message
              @greater_than_message = default_error_message(@greater_than_message, :count => @greater_than)
            end

            if Symbol === @less_than_message
              @less_than_message = default_error_message(@less_than_message, :count => @less_than)
            end

            if Symbol === @greater_than_or_equal_to_message
              @greater_than_or_equal_to_message = default_error_message(@greater_than_or_equal_to_message, :count => @greater_than_or_equal_to)
            end

            if Symbol === @less_than_or_equal_to_message
              @less_than_or_equal_to_message = default_error_message(@less_than_or_equal_to_message, :count => @less_than_or_equal_to)
            end

            if Symbol === @equal_to_message
              @equal_to_message = default_error_message(@equal_to_message, :count => @equal_to)
            end
          end
      end
    end
  end
end
