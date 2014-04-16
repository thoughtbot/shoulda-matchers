module Shoulda # :nodoc:
  module Matchers
    module ActionController # :nodoc:
      # Ensure a controller uses a given before_filter
      #
      # Example:
      #
      #   it { should use_before_filter(:authenticate_user!) }
      #   it { should_not use_before_filter(:prevent_ssl) }
      def use_before_filter(callback)
        CallbackMatcher.new(callback, :before, :filter)
      end

      # Ensure a controller uses a given before_filter
      #
      # Example:
      #
      #   it { should use_after_filter(:log_activity) }
      #   it { should_not use_after_filter(:destroy_user) }
      def use_after_filter(callback)
        CallbackMatcher.new(callback, :after, :filter)
      end

      # Ensure a controller uses a given before_action
      #
      # Example:
      #
      #   it { should use_before_action(:authenticate_user!) }
      #   it { should_not use_before_action(:prevent_ssl) }
      def use_before_action(callback)
        CallbackMatcher.new(callback, :before, :action)
      end

      # Ensure a controller uses a given after_action
      #
      # Example:
      #
      #   it { should use_after_action(:log_activity) }
      #   it { should_not use_after_action(:destroy_user) }
      def use_after_action(callback)
        CallbackMatcher.new(callback, :after, :action)
      end

      # Ensure a controller uses a given around_filter
      #
      # Example:
      #
      #   it { should use_around_filter(:log_activity) }
      #   it { should_not use_around_filter(:destroy_user) }
      def use_around_filter(callback)
        CallbackMatcher.new(callback, :around, :filter)
      end

      # Ensure a controller uses a given around_action
      #
      # Example:
      #
      #   it { should use_around_action(:log_activity) }
      #   it { should_not use_around_action(:destroy_user) }
      def use_around_action(callback)
        CallbackMatcher.new(callback, :around, :action)
      end

      class CallbackMatcher # :nodoc:
        def initialize(method_name, kind, callback_type)
          @method_name = method_name
          @kind = kind
          @callback_type = callback_type
        end

        def matches?(controller)
          @controller = controller
          @controller_class = controller.class

          callbacks.map(&:filter).include?(method_name)
        end

        def failure_message
          "Expected that #{controller_class.name} would have :#{method_name} as a #{kind}_#{callback_type}"
        end
        alias failure_message_for_should failure_message

        def failure_message_when_negated
          "Expected that #{controller_class.name} would not have :#{method_name} as a #{kind}_#{callback_type}"
        end
        alias failure_message_for_should_not failure_message_when_negated

        def description
          "have :#{method_name} as a #{kind}_#{callback_type}"
        end

        private

        def callbacks
          controller_class._process_action_callbacks.select do |callback|
            callback.kind == kind
          end
        end

        attr_reader :method_name, :controller, :controller_class, :kind,
          :callback_type
      end
    end
  end
end
