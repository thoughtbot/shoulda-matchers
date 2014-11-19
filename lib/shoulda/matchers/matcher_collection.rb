module Shoulda
  module Matchers
    module MatcherCollection
      attr_reader :failure_message, :failure_message_when_negated
      alias_method :failure_message_for_should,
        :failure_message
      alias_method :failure_message_for_should_not,
        :failure_message_when_negated

      def initialize
        @matchers_to_create = []
        @matcher_configurations = []
      end

      def add(klass, *args, &block)
        matchers_to_create << [klass, args, block]
      end

      def configure(&block)
        matcher_configurations << block
      end

      def invoke(method_name)
        matchers.
          select { |matcher| matcher.respond_to?(method_name) }.
          map(&method_name)
      end

      def matches?(subject)
        @subject = subject
        @failure_message = first_failing_matcher.failure_message
      end

      def does_not_match?(subject)
        @subject = subject
        @failure_message_when_negated =
          first_passing_matcher.failure_message_when_negated
      end

      private

      def matchers
        @_matchers ||= matchers_to_create.map do |klass, args, block|
          klass.new(*args).tap do |matcher|
            matcher.call(block) if block

            matcher_configurations.each do |block|
              block.call(matcher)
            end
          end
        end
      end

      def first_failing_matcher
        matchers.detect do |matcher|
          !matcher.matches?(subject)
        end
      end

      def first_passing_matcher
        matchers.detect do |matcher|
          matcher.matches?(subject)
        end
      end
    end
  end
end
