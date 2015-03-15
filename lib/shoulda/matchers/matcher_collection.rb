module Shoulda
  module Matchers
    # @private
    module MatcherCollection
      def initialize
        @matcher_builder_configurations = []
        @matcher_customizers = []
      end

      def add(klass, *args, &block)
        matcher_builder_configurations << {
          klass: klass,
          args: args,
          block: block
        }
      end

      def configure(&customizer)
        matcher_customizers << customizer
      end

      def invoke(method_name)
        matchers.
          select { |matcher| matcher.respond_to?(method_name) }.
          map(&method_name)
      end

      def matches?(subject)
        @subject = subject
        failing_submatchers.empty?
      end

      def does_not_match?(subject)
        @subject = subject
        passing_submatchers.empty?
      end

      def failure_message
        first_failing_matcher.failure_message
      end

      def failure_message_when_negated
        first_passing_matcher.failure_message_when_negated
      end

      protected

      attr_reader :matcher_builder_configurations, :matcher_customizers

      private

      def matchers
        @_matchers ||= matcher_builder_configurations.map do |config|
          config[:klass].new(*config[:args]).tap do |matcher|
            if config[:block]
              matcher.call(config[:block])
            end

            matcher_customizers.each do |customizer|
              customizer.call(matcher)
            end
          end
        end
      end

      def matcher_result_tuples
        @_matcher_result_tuples ||=
          matchers.map do |matcher|
            { matcher: matcher, matches: matcher.matches?(subject) }
          end
      end

      def first_failing_matcher
        matcher_result_tuples.detect { |tuple| tuple[:matches] }
      end

      def first_passing_matcher
        matcher_result_tuples.detect { |tuple| !tuple[:matches] }
      end
    end
  end
end
