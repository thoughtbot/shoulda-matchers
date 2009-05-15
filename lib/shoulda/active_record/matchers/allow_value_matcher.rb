module Shoulda # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers

      # Ensures that the attribute can be set to the given value.
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
      def allow_value(value)
        AllowValueMatcher.new(value)
      end

      class AllowValueMatcher # :nodoc:
        include Helpers

        def initialize(value)
          @value = value
        end

        def for(attribute)
          @attribute = attribute
          self
        end

        def with_message(message)
          @expected_message = message if message
          self
        end

        def matches?(instance)
          @instance = instance
          if Symbol === @expected_message
            @expected_message = default_error_message(@expected_message)
          end
          @instance.send("#{@attribute}=", @value)
          !errors_match?
        end

        def failure_message
          "Did not expect #{expectation}, got error: #{@matched_error}"
        end

        def negative_failure_message
          "Expected #{expectation}, got #{error_description}"
        end

        def description
          "allow #{@attribute} to be set to #{@value.inspect}"
        end

        private

        def errors_match?
          @instance.valid?
          @errors = @instance.errors.on(@attribute)
          @errors = [@errors] unless @errors.is_a?(Array)
          @expected_message ? (errors_match_regexp? || errors_match_string?) : (@errors != [nil])
        end

        def errors_match_regexp?
          if Regexp === @expected_message
            @matched_error = @errors.detect { |e| e =~ @expected_message }
            !@matched_error.nil?
          else
            false
          end
        end

        def errors_match_string?
          if @errors.include?(@expected_message)
            @matched_error = @expected_message
            true
          else
            false
          end
        end

        def expectation
          "errors " <<
          (@expected_message ? "to include #{@expected_message.inspect} " : "") <<
          "when #{@attribute} is set to #{@value.inspect}"
        end

        def error_description
          if @instance.errors.empty?
            "no errors"
          else
            "errors: #{pretty_error_messages(@instance)}"
          end
        end
      end

    end
  end
end
