module Shoulda
  module Matchers
    # @private
    class MatcherCollection
      def self.build(attrs, &block)
        new(attrs.map(&block))
      end

      def initialize(matchers)
        @matchers = matchers
        @failed_matchers = []
      end

      def description
        matchers.map(&:description).join(' and ')
      end

      def matches?(subject)
        @subject = subject
        @failed_matchers = matchers.reject do |matcher|
          matcher.matches?(fresh_subject_for(subject))
        end
        @failed_matchers.empty?
      end

      def does_not_match?(subject)
        @subject = subject
        @failed_matchers = matchers.reject do |matcher|
          fresh_subject = fresh_subject_for(subject)
          if matcher.respond_to?(:does_not_match?)
            matcher.does_not_match?(fresh_subject)
          else
            !matcher.matches?(fresh_subject)
          end
        end
        @failed_matchers.empty?
      end

      def failure_message
        if matchers.one?
          matchers.first.failure_message
        else
          build_failure_message('to')
        end
      end

      def failure_message_when_negated
        if matchers.one?
          matchers.first.failure_message_when_negated
        else
          build_failure_message('not to')
        end
      end

      def method_missing(method, *args, &block)
        if all_matchers_respond_to?(method)
          matchers.each { |matcher| matcher.send(method, *args, &block) }
          self
        else
          super
        end
      end

      def respond_to_missing?(method, include_private = false)
        all_matchers_respond_to?(method) || super
      end

      private

      attr_reader :matchers

      def fresh_subject_for(subject)
        matchers.one? ? subject : subject.dup
      end

      def build_failure_message(direction)
        header = Shoulda::Matchers.word_wrap(
          "Expected #{@subject.class.name} #{direction} "\
          "#{failed_description}, but this could not be proved.",
        )

        reasons = @failed_matchers.filter_map do |matcher|
          reason = matcher.failure_reason
          Shoulda::Matchers.word_wrap(reason, indent: 2) if reason.present?
        end

        ([header] + reasons).join("\n")
      end

      def failed_description
        @failed_matchers.map(&:description).join(' and ')
      end

      def all_matchers_respond_to?(method)
        matchers.all? { |matcher| matcher.respond_to?(method) }
      end
    end
  end
end
