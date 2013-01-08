module Shoulda # :nodoc:
  module Matchers
    module ActionController # :nodoc:

      # Ensures that the flash contains the given value. Can be a String, a
      # Regexp, or nil (indicating that the flash should not be set).
      #
      # Example:
      #
      #   it { should set_the_flash }
      #   it { should set_the_flash.to('Thank you for placing this order.') }
      #   it { should set_the_flash.to(/created/i) }
      #   it { should set_the_flash[:alert].to('Password does not match') }
      #   it { should set_the_flash.to(/logged in/i).now }
      #   it { should_not set_the_flash }
      def set_the_flash
        SetTheFlashMatcher.new
      end

      class SetTheFlashMatcher # :nodoc:
        def initialize
          @options = {}
        end

        def to(value)
          if !value.is_a?(String) && !value.is_a?(Regexp)
            raise "cannot match against #{value.inspect}"
          end
          @value = value
          self
        end

        def now
          @options[:now] = true
          self
        end

        def [](key)
          @options[:key] = key
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

        def failure_message_for_should
          "Expected #{expectation}"
        end

        def failure_message_for_should_not
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
          if @options.key?(:key)
            [flash.to_hash[@options[:key]]]
          else
            flash.to_hash.values
          end
        end

        def flash
          if @flash
            @flash
          else
            @flash = @controller.flash.dup
            used = @controller.flash.instance_variable_get(:@used).dup
            @flash.instance_variable_set(:@used, used)
            sweep_flash_if_necessary
            @flash
          end
        end

        def sweep_flash_if_necessary
          unless @options[:now]
            @flash.sweep
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
            'no flash was set'
          else
            "was #{flash.inspect}"
          end
        end

        def expected_flash_invocation
          "flash#{pretty_now}#{pretty_key}"
        end

        def pretty_now
          if @options[:now]
            '.now'
          else
            ''
          end
        end

        def pretty_key
          if @options[:key]
            "[:#{@options[:key]}]"
          else
            ''
          end
        end
      end
    end
  end
end
