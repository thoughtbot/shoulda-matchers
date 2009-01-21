module Shoulda # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers # :nodoc:

      class AllowValueMatcher
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
          @expected_message ||= :invalid
          if Symbol === @expected_message
            @expected_message = default_error_message(@expected_message)
          end
          fix_blank_value!
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
          if @value.blank?
            "allow #{@attribute} to be blank"
          else
            "allow #{@attribute} to be set to #{@value.inspect}"
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

        def error_description
          if @instance.errors.empty?
            "no errors"
          else
            "errors: #{pretty_error_messages(@instance)}"
          end
        end

        def fix_blank_value!
          if @value.nil? && 
            (reflection = @instance.class.reflect_on_association(@attribute)) &&
            [:has_many, :has_and_belongs_to_many].include?(reflection.macro)
            @value = []
          end
        end
      end

      def allow_value(value)
        AllowValueMatcher.new(value)
      end

      def allow_blank_for(attr)
        AllowValueMatcher.
          new(nil).
          for(attr).
          with_message(:blank)
      end
    end
  end
end
