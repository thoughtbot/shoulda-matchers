module Shoulda
  module Matchers
    module ActiveModel
      module NumericalityMatchers
        # @private
        class Submatchers
          def initialize(submatchers)
            @submatchers = submatchers
          end

          def matches?(subject)
            @subject = subject
            failing_submatchers.empty?
          end

          def does_not_match?(subject)
            @subject = subject
            not_failing_submatchers.empty?
          end

          def failure_message
            failing_submatcher.failure_message
          end

          def failure_message_when_negated
            not_failing_submatcher.failure_message_when_negated
          end

          def add(submatcher)
            @submatchers << submatcher
          end

          private

          def failing_submatchers
            @_failing_submatchers ||= @submatchers.reject do |submatcher|
              submatcher.matches?(@subject)
            end
          end

          def not_failing_submatchers
            @_not_failing_submatchers ||= @submatchers.reject do |submatcher|
              submatcher.does_not_match?(@subject)
            end
          end

          def failing_submatcher
            failing_submatchers.last
          end

          def not_failing_submatcher
            not_failing_submatchers.detect { |submatcher| submatcher.instance_of?(DisallowValueMatcher) } || not_failing_submatchers.first
          end
        end
      end
    end
  end
end
