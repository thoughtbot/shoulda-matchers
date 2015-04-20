module Shoulda
  module Matchers
    # @private
    class MatcherCollection
      Configuration = Struct.new(:klass, :args, :block)
      MatcherWithResult = Struct.new(:matcher, :result)

      def initialize
        @matcher_builder_configurations = []
        @matcher_customizers = []
      end

      def add(klass, *args, &block)
        matcher_builder_configurations << Configuration.new(klass, args, block)
      end

      def configure(*args, &customizer)
        matcher_customizers << customizer
      end

      def add_qualifier(name, *args)
        matcher_customizers << lambda do |matcher|
          matcher.__send__(name, *args)
        end
      end

      def invoke(method_name)
        matchers.
          select { |matcher| matcher.respond_to?(method_name) }.
          map(&method_name)
      end

      def matches?(subject)
        @subject = subject
        first_failing_matcher.nil?
      end

      def does_not_match?(subject)
        @subject = subject
        !first_failing_matcher.nil?
      end

      # def failure_message
        # first_failing_matcher.failure_message
      # end

      # def failure_message_when_negated
        # first_passing_matcher.failure_message_when_negated
      # end

      protected

      attr_reader :matcher_builder_configurations, :matcher_customizers,
        :subject

      private

      def matchers
        @_matchers ||= matcher_builder_configurations.map do |config|
          config.klass.new(*config.args).tap do |matcher|
            if config.block
              matcher.call(config.block)
            end

            matcher_customizers.each do |customizer|
              customizer.call(matcher)
            end
          end
        end
      end

      def first_failing_matcher
        @_first_failing_matcher ||=
          matchers.detect { |matcher| !matcher.matches?(subject) }
      end

      def first_passing_matcher
        @_first_passing_matcher ||=
          matchers.detect { |matcher| matcher.matches?(subject) }
      end
    end
  end
end
