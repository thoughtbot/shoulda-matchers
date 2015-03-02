module Shoulda
  module Matchers
    module ActiveModel
      def allow_values(*values)
        AllowValuesMatcher.new(values)
      end

      # @private
      class AllowValuesMatcher
        def initialize(values)
          @submatchers = values.map { |value| AllowValueMatcher.new(value) }
        end

        def for(attribute)
          submatchers.each { |submatcher| submatcher.for(attribute) }
        end

        def matches?(record)
          submatchers.all? { |record| submatcher.matches?(record) }
        end

        def does_not_match?(record)
          submatchers.all? { |record| !submatcher.matches?(record) }
        end

        def failure_message
          first_failing_submatcher.failure_message
        end

        def failure_message_when_negated
          first_succeeding_submatcher.failure_message_when_negated
        end

        def description
          "be valid when #{attribute} is set to #{formatted_values(values)}"
        end

        private

        def formatted_values(values)
          values.to_sentence(
            two_words_connector: ' or ',
            last_word_connector: ', or '
          )
        end
      end
    end
  end
end
