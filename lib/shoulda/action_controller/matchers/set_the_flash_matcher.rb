module Shoulda # :nodoc:
  module ActionController # :nodoc:
    module Matchers

      # Ensures that the flash contains the given value. Can be a String, a
      # Regexp, or nil (indicating that the flash should not be set).
      #
      # Example:
      #
      #   it { should set_the_flash }
      #   it { should set_the_flash.to("Thank you for placing this order.") }
      #   it { should set_the_flash.to(/created/i) }
      #   it { should_not set_the_flash }
      def set_the_flash
        SetTheFlashMatcher.new
      end

      class SetTheFlashMatcher # :nodoc:

        def to(value)
          @value = value
          self
        end

        def matches?(controller)
          @controller = controller
          sets_the_flash? && string_value_matches? && regexp_value_matches?
        end

        attr_reader :failure_message, :negative_failure_message

        def description
          description = "set the flash"
          description << " to #{@value.inspect}" unless @value.nil?
          description
        end

        def failure_message
          "Expected #{expectation}"
        end

        def negative_failure_message
          "Did not expect #{expectation}"
        end

        private

        def sets_the_flash?
          !flash.blank?
        end

        def string_value_matches?
          return true unless String === @value
          flash.values.any? {|value| value == @value }
        end

        def regexp_value_matches?
          return true unless Regexp === @value
          flash.values.any? {|value| value =~ @value }
        end

        def flash
          @controller.response.session['flash']
        end

        def expectation
          expectation = "the flash to be set"
          expectation << " to #{@value.inspect}" unless @value.nil?
          expectation << ", but #{flash_description}"
          expectation
        end

        def flash_description
          if flash.blank?
            "no flash was set"
          else
            "was #{flash.inspect}"
          end
        end

      end

    end
  end
end
