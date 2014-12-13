module UnitTests
  module Matchers
    def have_instance_method(method_name)
      HaveInstanceMethodMatcher.new(method_name)
    end

    class HaveInstanceMethodMatcher
      def initialize(method_name)
        @method_name = method_name
      end

      def with_arity(arity)
        @arity = arity
        self
      end

      def matches?(klass)
        @klass = klass
        instance_method_defined? && instance_method_has_arity?
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

      attr_reader :method_name, :arity, :klass

      private

      def arity_specified?
        defined?(@arity)
      end

      def instance_method_defined?
        method_name == :initialize ||
          klass.instance_methods.include?(method_name)
      end

      def instance_method_has_arity?
        !arity_specified? || instance_method.arity == arity
      end

      def instance_method
        klass.instance_method(method_name)
      end

      def expectation
        string = "have instance method ##{method_name}"

        if arity_specified?
          string << " with arity of #{arity}"
        end

        string
      end
    end
  end
end
