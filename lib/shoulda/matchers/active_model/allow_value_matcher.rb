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
      # * <tt>strict</tt> - expects the model to raise an exception when the
      #   validation fails rather than adding to the errors collection. Used for
      #   testing `validates!` and the `:strict => true` validation options.
      #
      # Example:
      #   it { should_not allow_value('bad').for(:isbn) }
      #   it { should allow_value('isbn 1 2345 6789 0').for(:isbn) }
      #
      def allow_value(*values)
        if values.empty?
          raise ArgumentError, 'need at least one argument'
        else
          AllowValueMatcher.new(*values)
        end
      end

      class AllowValueMatcher # :nodoc:
        include Helpers

        attr_accessor :options

        def initialize(*values)
          self.values_to_match = values
          self.message_finder_factory = ValidationMessageFinder
          self.options = {}
        end

        def for(attribute)
          self.attribute = attribute
          self
        end

        def on(context)
          @context = context
          self
        end

        def with_message(message)
          self.options[:expected_message] = message
          self
        end

        def strict
          self.message_finder_factory = ExceptionMessageFinder
          self
        end

        def matches?(instance)
          self.instance = instance

          values_to_match.none? do |value|
            self.value = value
            instance.send("#{attribute}=", value)
            errors_match?
          end
        end

        def failure_message_for_should
          "Did not expect #{expectation}, got error: #{matched_error}"
        end

        def failure_message_for_should_not
          "Expected #{expectation}, got #{error_description}"
        end

        def description
          message_finder.allow_description(allowed_values)
        end

        private

        attr_accessor :values_to_match, :message_finder_factory,
          :instance, :attribute, :context, :value, :matched_error

        def errors_match?
          has_messages? && errors_for_attribute_match?
        end

        def has_messages?
          message_finder.has_messages?
        end

        def errors_for_attribute_match?
          if expected_message
            self.matched_error = errors_match_regexp? || errors_match_string?
          else
            errors_for_attribute.compact.any?
          end
        end

        def errors_for_attribute
          message_finder.messages
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
          [error_source, includes_expected_message, "when #{attribute} is set to #{value.inspect}"].join(' ')
        end

        def error_source
          message_finder.source_description
        end

        def error_description
          message_finder.messages_description
        end

        def allowed_values
          if values_to_match.length > 1
            "any of [#{values_to_match.map(&:inspect).join(', ')}]"
          else
            values_to_match.first.inspect
          end
        end

        def expected_message
          if options.key?(:expected_message)
            if Symbol === options[:expected_message]
              default_expected_message
            else
              options[:expected_message]
            end
          end
        end

        def default_expected_message
          message_finder.expected_message_from(default_attribute_message)
        end

        def default_attribute_message
          default_error_message(
            options[:expected_message],
            :model_name => model_name,
            :instance => instance,
            :attribute => attribute
          )
        end

        def model_name
          instance.class.to_s.underscore
        end

        def message_finder
          message_finder_factory.new(instance, attribute, context)
        end
      end
    end
  end
end
