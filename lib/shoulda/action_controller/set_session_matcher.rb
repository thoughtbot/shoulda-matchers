module Shoulda # :nodoc:
  module ActionController # :nodoc:
    module Matchers

      # Ensures that a session key was set to the expected value.
      #
      # Example:
      #
      #   it { should set_session(:message) }
      #   it { should set_session(:user_id).to(@user.id) }
      #   it { should_not set_session(:user_id) }
      def set_session(key)
        SetSessionMatcher.new(key)
      end

      class SetSessionMatcher # :nodoc:

        def initialize(key)
          @key = key.to_s
        end

        def to(value = nil, &block)
          @value = value
          @value_block = block
          self
        end

        def matches?(controller)
          @controller = controller
          @value = @context.instance_eval(&@value_block) if @value_block
          (assigned_value? && assigned_correct_value?) || cleared_value?
        end

        def failure_message
          "Expected #{expectation}, but #{result}"
        end

        def negative_failure_message
          "Didn't expect #{expectation}, but #{result}"
        end

        def description
          description = "set session variable #{@key.inspect}"
          description << " to #{@value.inspect}" if defined?(@value)
          description
        end

        def in_context(context)
          @context = context
          self
        end

        private

        def assigned_value?
          !assigned_value.nil?
        end

        def cleared_value?
          defined?(@value) && @value.nil? && assigned_value.nil?
        end

        def assigned_correct_value?
          return true if @value.nil?
          assigned_value == @value
        end

        def assigned_value
          session[@key]
        end

        def session
          if @controller.request.respond_to?(:session)
            @controller.request.session.to_hash
          else
            @controller.response.session.data
          end
        end

        def expectation
          expectation = "session variable #{@key} to be set"
          expectation << " to #{@value.inspect}" if @value
          expectation
        end

        def result
          if session.empty?
            "no session variables were set"
          else
            "the session was #{session.inspect}"
          end
        end

      end

    end
  end
end
