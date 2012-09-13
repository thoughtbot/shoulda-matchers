module Shoulda # :nodoc:
  module Matchers
    module ActiveModel # :nodoc:

      # Ensures that the attribute can be set to the given value or values. If
      # multiple values are given the match succeeds only if all given values
      # are allowed. Otherwise, the matcher fails at the first bad value in the
      # argument list (the remaining arguments are not processed then).
      #
      # Options:
      # * <tt>with_message</tt> - value the test expects to find in
      #   <tt>errors.on(:attribute)</tt>. Regexp or string. If omitted,
      #   the test looks for any errors in <tt>errors.on(:attribute)</tt>.
      #
      # Example:
      #   it { should_not allow_value('bad').for(:isbn) }
      #   it { should allow_value("isbn 1 2345 6789 0").for(:isbn) }
      #
      def allow_value(*values)
        if values.empty?
          raise ArgumentError, "need at least one argument"
        else
          AllowValueMatcher.new(*values)
        end
      end

      class AllowValueMatcher # :nodoc:
        include Helpers

        def initialize(*values)
          @values_to_match = values
          @strict = false
          @options = {}
        end

        def for(attribute)
          @attribute = attribute
          self
        end

        def with_message(message)
          @options[:expected_message] = message
          self
        end

        def strict
          @strict = true
          self
        end

        def matches?(instance)
          @instance = instance
          @values_to_match.none? do |value|
            @value = value
            @instance.send("#{@attribute}=", @value)
            errors_match?
          end
        end

        def failure_message
          "Did not expect #{expectation}, got error: #{@matched_error}"
        end

        def negative_failure_message
          "Expected #{expectation}, got #{error_description}"
        end

        def description
          base = "allow #{@attribute} to be set to #{allowed_values}"

          if strict?
            "strictly #{base}"
          else
            message_finder.allow_description(allowed_values)
          end
        end

        private

        def errors_match?
          has_messages? && errors_for_attribute_match?
        end

        def has_messages?
          if strict?
            has_exception_message?
          else
            message_finder.has_messages?
          end
        end

        def has_exception_message?
          @instance.valid?
          false
        rescue ::ActiveModel::StrictValidationFailed => exception
          @strict_exception = exception
          true
        end

        def errors_for_attribute_match?
          if expected_message
            @matched_error = errors_match_regexp? || errors_match_string?
          else
            errors_for_attribute.compact.any?
          end
        end

        def errors_for_attribute
          if strict?
            [strict_exception_message]
          else
            message_finder.messages
          end
        end

        def strict_exception_message
          @strict_exception.message
        end

        def strict?
          @strict
        end

        def errors_match_regexp?
          if Regexp === expected_message
            errors_for_attribute.detect { |e| e =~ expected_message }
          end
        end

        def errors_match_string?
          if errors_for_attribute.include?(expected_message)
            expected_message
          end
        end

        def expectation
          includes_expected_message = expected_message ? "to include #{expected_message.inspect}" : ''
          [error_source, includes_expected_message, "when #{@attribute} is set to #{@value.inspect}"].join(' ')
        end

        def error_source
          if strict?
            'exception'
          else
            message_finder.source_description
          end
        end

        def error_description
          if strict?
            exception_description
          else
            message_finder.messages_description
          end
        end

        def exception_description
          if @strict_exception
            strict_exception_message
          else
            'no exception'
          end
        end

        def allowed_values
          if @values_to_match.length > 1
            "any of [#{@values_to_match.map(&:inspect).join(', ')}]"
          else
            @values_to_match.first.inspect
          end
        end

        def expected_message
          if @options.key?(:expected_message)
            if Symbol === @options[:expected_message]
              default_expected_message
            else
              @options[:expected_message]
            end
          end
        end

        def default_expected_message
          if strict?
            default_full_message
          else
            message_finder.expected_message_from(default_attribute_message)
          end
        end

        def default_full_message
          "#{human_attribute_name} #{default_attribute_message}"
        end

        def human_attribute_name
          @instance.class.human_attribute_name(@attribute)
        end

        def default_attribute_message
          default_error_message(
            @options[:expected_message],
            :model_name => model_name,
            :attribute => @attribute
          )
        end

        def model_name
          @instance.class.to_s.underscore
        end

        def message_finder
          @message_finder ||= ValidationMessageFinder.new(@instance, @attribute)
        end
      end
    end
  end
end
