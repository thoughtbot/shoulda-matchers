module Shoulda # :nodoc:
  module Matchers
    module ActionController # :nodoc:

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
          if @value_block
            @value = @context.instance_eval(&@value_block)
          end
          assigned_correct_value? || cleared_value?
        end

        def failure_message_for_should
          "Expected #{expectation}, but #{result}"
        end

        def failure_message_for_should_not
          "Didn't expect #{expectation}, but #{result}"
        end

        def description
          description = "set session variable #{@key.inspect}"
          if @value
            description << " to #{@value.inspect}"
          end
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
          if assigned_value?
            if @value.nil?
              true
            else
              assigned_value == @value
            end
          end
        end

        def assigned_value
          session[@key]
        end

        def expectation
          expectation = "session variable #{@key} to be set"
          if @value
            expectation << " to #{@value.inspect}"
          end
        end

        def result
          if session.empty?
            'no session variables were set'
          else
            "the session was #{session.inspect}"
          end
        end

        def session
          if @controller.request.respond_to?(:session)
            @controller.request.session.to_hash
          else
            @controller.response.session.data
          end
        end
      end
    end
  end
end
