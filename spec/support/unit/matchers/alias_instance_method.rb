module UnitTests
  module Matchers
    def alias_instance_method(old_method_name)
      AliasInstanceMethodMatcher.new(old_method_name)
    end

    class AliasInstanceMethodMatcher
      def initialize(old_method_name)
        @old_method_name = old_method_name
      end

      def to(new_method_name)
        @new_method_name = new_method_name
        self
      end

      def matches?(klass)
        @klass = klass
        instance_method(old_method_name) == instance_method(new_method_name)
      end

      def description
        "should #{expectation}"
      end

      def failure_message
        "Expected #{klass} to #{expectation}"
      end
      alias_method :failure_message_for_should, :failure_message

      def failure_message_when_negated
        "Expected #{klass} not to #{expectation}"
      end
      alias_method :failure_message_for_should_not,
        :failure_message_when_negated

      protected

      attr_reader :old_method_name, :new_method_name, :klass

      private

      def expectation
        "alias instance method ##{old_method_name} to ##{new_method_name}"
      end
    end
  end
end
