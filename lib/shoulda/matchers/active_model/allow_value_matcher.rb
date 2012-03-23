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
        raise ArgumentError.new("need at least one argument") if values.empty?
        AllowValueMatcher.new(*values)
      end

      class AllowValueMatcher # :nodoc:
        include Helpers

        def initialize(*values)
          @values_to_match = values
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
            @expected_message = default_error_message(@expected_message, :model_name => @instance.class.to_s.underscore, :attribute => @attribute)
          end
          @values_to_match.each do |value|
            @value = value
            @instance.send("#{@attribute}=", @value)
            return false if errors_match?
          end
          true
        end

        def failure_message
          "Did not expect #{expectation}, got error: #{@matched_error}"
        end

        def negative_failure_message
          "Expected #{expectation}, got #{error_description}"
        end

        def description
          "allow #{@attribute} to be set to " <<
            if @values_to_match.length > 1
              "any of [#{@values_to_match.map {|v| v.inspect }.join(', ')}]"
            else
              @values_to_match.first.inspect
            end
        end

        private

        def errors_match?
          if ! @instance.valid?
            @errors = errors_for_attribute(@instance, @attribute)
            @errors = [@errors] unless @errors.is_a?(Array)
            @expected_message ? (errors_match_regexp? || errors_match_string?) : (@errors.compact.any?)
          else
            @errors = []
            false
          end
        end

        def errors_for_attribute(instance, attribute)
          if instance.errors.respond_to?(:[])
            instance.errors[attribute]
          else
            instance.errors.on(attribute)
          end
        end

        def errors_match_regexp?
          if Regexp === @expected_message
            @matched_error = @errors.detect { |e| e =~ @expected_message }
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
