module Shoulda
  module Matchers
    module ActiveModel
      def allow_values(*values)
        AllowValuesMatcher.new(values)
      end

      # @private
      class AllowValuesMatcher
        delegate :matches?, :does_not_match?, :failure_message,
          :failure_message_when_negated, to: :matcher_collection

        def initialize(values)
          @matcher_collection = build_matcher_collection
        end

        def for(attribute)
          matcher_collection.configure do |matcher|
            matcher.for(attribute)
          end
        end

        def on(context)
          matcher_collection.configure do |matcher|
            matcher.on(context)
          end
        end

        def strict
          matcher_collection.configure do |matcher|
            matcher.strict
          end
        end

        def with_message(message, options = {})
          matcher_collection.configure do |matcher|
            matcher.with_message(message, options)
          end
        end

        def description
          "be valid when #{attribute} is set to #{formatted_values(values)}"
        end

        protected

        attr_reader :matcher_collection

        private

        def build_matcher_collection
          MatcherCollection.new.tap do |matchers|
            values.each do |value|
              matchers.add(AllowValueMatcher, value)
            end
          end
        end

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
