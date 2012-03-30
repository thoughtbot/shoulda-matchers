module Shoulda # :nodoc:
  module Matchers
    module ActionController # :nodoc:

      # Ensures that the flash contains the given value. Can be a String, a
      # Regexp, or nil (indicating that the flash should not be set).
      #
      # Example:
      #
      #   it { should set_the_flash }
      #   it { should set_the_flash.to("Thank you for placing this order.") }
      #   it { should set_the_flash.to(/created/i) }
      #   it { should set_the_flash[:alert].to("Password doesn't match") }
      #   it { should set_the_flash.to(/logged in/i).now }
      #   it { should_not set_the_flash }
      def set_the_flash
        SetTheFlashMatcher.new
      end

      class SetTheFlashMatcher # :nodoc:
        attr_reader :failure_message, :negative_failure_message

        def to(value)
          @value = value
          self
        end

        def now
          @now = true
          self
        end

        def [](key)
          @key = key
          self
        end

        def matches?(controller)
          @controller = controller
          sets_the_flash? && string_value_matches? && regexp_value_matches?
        end

        def description
          description = "set the #{expected_flash_invocation}"
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
          flash_values.any?
        end

        def string_value_matches?
          if @value.is_a?(String)
            flash_values.any? {|value| value == @value }
          else
            true
          end
        end

        def regexp_value_matches?
          if @value.is_a?(Regexp)
            flash_values.any? {|value| value =~ @value }
          else
            true
          end
        end

        def flash_values
          if @key
            [flash.to_hash[@key]]
          else
            flash.to_hash.values
          end
        end

        def flash
          if @flash
            @flash
          else
            @flash = @controller.flash.dup
            @flash.instance_variable_set(:@used, @controller.flash.instance_variable_get(:@used).dup)
            if ! @now
              @flash.sweep
            end
            @flash
          end
        end

        def expectation
          expectation = "the #{expected_flash_invocation} to be set"
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

        def expected_flash_invocation
          now = ""
          key = ""

          if @now
            now = ".now"
          end

          if @key
            key = "[:#{@key}]"
          end

          "flash#{now}#{key}"
        end
      end
    end
  end
end
