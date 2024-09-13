module Shoulda
  module Matchers
    module ActiveModel
      # @private
      class MatcherCollection
        def initialize(matchers)
          @matchers = matchers
        end

        def description
          matchers.map(&:description).join(' and ')
        end

        def matches?(subject)
          @failed_matchers = failed_matchers_for(subject, :matches?)
          @failed_matchers.empty?
        end

        def does_not_match?(subject)
          @failed_matchers = failed_matchers_for(subject, :does_not_match?)
          @failed_matchers.empty?
        end

        def failure_message
          first_failure_message(:failure_message)
        end

        def failure_message_when_negated
          first_failure_message(:failure_message_when_negated)
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

        def failed_matchers_for(subject, method)
          matchers.reject { |matcher| matcher.send(method, subject) }
        end

        def first_failure_message(method)
          @failed_matchers.first&.send(method)
        end

        def all_matchers_respond_to?(method)
          matchers.all? { |matcher| matcher.respond_to?(method) }
        end
      end
    end
  end
end
