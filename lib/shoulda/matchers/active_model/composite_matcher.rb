module Shoulda # :nodoc:
  module Matchers
    module ActiveModel # :nodoc:
      class CompositeMatcher
        def initialize
          @matchers = []
        end

        def add_matcher(matcher)
          @matchers << matcher
          self
        end

        def matches?(subject)
          matchers_match?(subject)
        end

        def description
          @matchers.map(&:description).join(" ")
        end

        def failure_message
          @matchers.map(&:failure_message).join(" ")
        end

        def negative_failure_message
          @matchers.map(&:negative_failure_message).join(" ")
        end

        private

        def matchers_match?(subject)
          if @matchers.empty?
            true
          else
            @matchers.all? { |matcher| matcher.matches?(subject) }
          end
        end

        def matcher_descriptions
          @matchers.map(&:description)
        end
      end
    end
  end
end
