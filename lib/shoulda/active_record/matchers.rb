module Shoulda # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers # :nodoc:

      class AttributeMatcher
        include Helpers

        def initialize(attribute)
          @attribute        = attribute
          @value            = nil
          @expected_message = nil 
        end

        # optional parameters

        def accepting_value(value)
          @value = value
          self
        end

        def with_message(message)
          @expected_message = message
          self
        end

        # standard matcher methods

        def matches?(instance)
          @instance = instance
          accepts_value?
        end

        def failure_message
          "Expected errors to exclude #{@expected_message.inspect} #{state_expectation}, got error #{@matched_error.inspect}"
        end

        def negative_failure_message
          "Expected errors to include #{@expected_message.inspect} #{state_expectation}, got errors: #{pretty_error_messages(@instance)}"
        end

        private

        # matches? conditions

        def accepts_value?
          @expected_message ||= default_error_message(:invalid)
          @instance.send("#{@attribute}=", @value)
          !errors_match?
        end

        # matches? helpers

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

        # expectation helpers

        def state_expectation
          "when #{@attribute} is set to #{@value.inspect}"
        end
      end

      def have_attribute(attr)
        AttributeMatcher.new(attr)
      end
    end
  end
end
