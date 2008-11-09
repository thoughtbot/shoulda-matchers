module Shoulda # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers # :nodoc:

      class AttributeMatcher
        include Helpers

        def for(attribute)
          @attribute = attribute
          self
        end

        def accepting_value(value)
          @value = value
          self
        end

        def with_message(message)
          @expected_message = message
          self
        end

        def matches?(instance)
          @instance = instance
          @expected_message ||= :invalid
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
          "Expected #{expectation}, got errors: #{pretty_error_messages(@instance)}"
        end

        def description
          if @value.nil?
            "allow #{@attribute} to be blank"
          else
            description = "have an attribute called #{@attribute}"
            description << " accepting value #{@value.inspect}"
            description << " without error #{@expected_message.inspect}"
            description
          end
        end

        private

        def errors_match?
          @instance.valid?
          @errors = @instance.errors.on(@attribute)
          @errors = [@errors] unless @errors.is_a?(Array)
          errors_match_regexp? || errors_match_string?
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
          "errors to include #{@expected_message.inspect} " <<
          "when #{@attribute} is set to #{@value.inspect}"
        end
      end

      def have_attribute(attr)
        AttributeMatcher.new.for(attr)
      end

      def accept_value(value)
        AttributeMatcher.new.accepting_value(value)
      end

      def allow_blank_for(attr)
        AttributeMatcher.new.for(attr).accepting_value(nil).with_message(:blank)
      end
    end
  end
end
