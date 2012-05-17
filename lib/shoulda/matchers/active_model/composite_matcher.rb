module Shoulda # :nodoc:
  module Matchers
    module ActiveModel # :nodoc:
      class CompositeMatcher < ValidationMatcher
        def initialize(attribute)
          super
          @sub_matchers = []
        end

        def add_matcher(matcher)
          @sub_matchers << matcher
          self
        end

        def matches?(subject)
          sub_matchers_match?(subject)
        end

        def description
          "No description"
        end

        private

        def sub_matchers_match?(subject)
          if @sub_matchers.empty?
            true
          else
            @sub_matchers.all? { |matcher| matcher.matches?(subject) }
          end
        end

        def sub_matcher_descriptions
          @sub_matchers.map(&:description)
        end
      end
    end
  end
end
