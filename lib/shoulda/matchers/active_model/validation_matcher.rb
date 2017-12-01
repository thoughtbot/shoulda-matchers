module Shoulda
  module Matchers
    module ActiveModel
      # @private
      class ValidationMatcher
        include Qualifiers::IgnoringInterferenceByWriter

        def initialize(attribute)
          super
          @attribute = attribute
          @expects_strict = false
          @record = nil
          @submatchers = []
          @expected_message = nil
          @expects_custom_validation_message = false
          @_submatchers_added = false
          @was_negated = nil
        end

        def description
          ValidationMatcher::BuildDescription.call(self, simple_description)
        end

        def on(context)
          @context = context
          self
        end

        def strict
          @expects_strict = true
          self
        end

        def expects_strict?
          @expects_strict
        end

        def with_message(expected_message)
          if expected_message
            @expects_custom_validation_message = true
            @expected_message = expected_message
          end

          self
        end

        def expects_custom_validation_message?
          @expects_custom_validation_message
        end

        def matches?(record)
          @record = record

          if !@_submatchers_added
            add_submatchers
            @_submatchers_added = true
          end

          all_submatchers_match?.tap do
            @was_negated = false
          end
        end

        def does_not_match?(record)
          @record = record

          !matches?(record).tap do
            @was_negated = true
          end
        end

        def failure_message
          overall_failure_message + submatchers_report
        end

        def failure_message_when_negated
          overall_failure_message_when_negated + submatchers_report
        end

        def submatchers_report
          message = "\n\n"

          if was_negated?
            message << 'At least one of these subtests should have failed:'
          else
            message << 'All of these subtests should have passed:'
          end

          message << "\n\n"

          list = submatcher_results.map do |result|
            item = ''

            if result.expected?
              item << "#{result.submatcher_expectation} (✔︎)"
            elsif result.matched?
              item << "#{result.submatcher_expectation} (PASSED ✘)"
            else
              item << "#{result.submatcher_failure_message} (✘)"
            end

            indented_item = Shoulda::Matchers.word_wrap(item, indent: 2)
            indented_item[0] = '*'
            indented_item
          end

          message << list.join("\n")

          if submatcher_result_with_attribute_changed_value_message.present?
            attribute_changed_value_message = Shoulda::Matchers.word_wrap(
              submatcher_result_with_attribute_changed_value_message.
                submatcher_attribute_changed_value_message,
            )
            message << "\n\n#{attribute_changed_value_message}"
          end

          message
        end

        def was_negated?
          @was_negated
        end

        protected

        attr_reader :attribute, :context, :record, :submatchers,
          :first_failing_submatcher

        def model
          record.class
        end

        def add_submatchers
        end

        def add_submatcher(submatcher)
          submatchers << submatcher
        end

        def allows_value_of(value_or_values, message = nil, &block)
          matcher =
            if value_or_values.is_a?(Array)
              allow_value_matcher(*value_or_values, message: message, &block)
            else
              allow_value_matcher(value_or_values, message: message, &block)
            end
          add_submatcher(matcher)
          matcher
        end
        alias_method :add_matcher_allowing, :allows_value_of

        def disallows_value_of(value_or_values, message = nil, &block)
          matcher =
            if value_or_values.is_a?(Array)
              disallow_value_matcher(*value_or_values, message: message, &block)
            else
              disallow_value_matcher(value_or_values, message: message, &block)
            end
          add_submatcher(matcher)
          matcher
        end
        alias_method :add_matcher_disallowing, :disallows_value_of

        def allow_value_matcher(*values, message: nil, &block)
          build_allow_or_disallow_value_matcher(
            matcher_class: AllowValueMatcher,
            values: values,
            message: message,
            &block
          )
        end

        def disallow_value_matcher(*values, message: nil, &block)
          build_allow_or_disallow_value_matcher(
            matcher_class: DisallowValueMatcher,
            values: values,
            message: message,
            &block
          )
        end

        private

        def overall_failure_message
          Shoulda::Matchers.word_wrap(<<~MESSAGE)
            Your test expecting #{model.name} to #{simple_description} didn't
            pass.
          MESSAGE
        end

        def overall_failure_message_when_negated
          Shoulda::Matchers.word_wrap(<<~MESSAGE)
            Your test expecting #{model.name} not to #{simple_description}
            didn't pass.
          MESSAGE
        end

        def indented_failure_message_for_first_failing_submatcher
          if failure_message_for_first_failing_submatcher.present?
            "\n" + Shoulda::Matchers.word_wrap(
              failure_message_for_first_failing_submatcher,
              indent: 2,
            )
          end
        end

        def failure_message_for_first_failing_submatcher
          first_failing_submatcher.try(:failure_message)
        end

        def all_submatchers_match?
          submatcher_results.all?(&:expected?)
        end

        def first_failing_submatcher
          tuple = submatcher_results.detect(&:unexpected?)

          if tuple
            tuple.first
          end
        end

        def submatcher_result_with_attribute_changed_value_message
          unexpected_submatcher_results.detect do |result|
            result.submatcher_includes_attribute_changed_value_message?
          end
        end

        def unexpected_submatcher_results
          submatcher_results.select(&:unexpected?)
        end

        def submatcher_results
          @_submatcher_results ||= submatchers.map do |submatcher|
            SubmatcherResult.new(
              submatcher,
              submatcher.matches?(record),
              was_negated?,
            )
          end
        end

        def build_allow_or_disallow_value_matcher(matcher_class:, values:, message:)
          matcher = matcher_class.new(*values, part_of_larger_matcher: true).
            for(attribute).
            with_message(message).
            on(context).
            strict(expects_strict?).
            ignoring_interference_by_writer(ignore_interference_by_writer)

          yield matcher if block_given?

          matcher
        end

        class SubmatcherResult
          def initialize(submatcher, matched, parent_was_negated)
            @submatcher = submatcher
            @matched = matched
            @parent_was_negated = parent_was_negated
          end

          def matched?
            @matched
          end

          def expected?
            (!parent_was_negated? && matched?) ||
              (parent_was_negated? && !matched?)
          end

          def unexpected?
            !expected?
          end

          def submatcher_model
            submatcher.model
          end

          def submatcher_description
            submatcher.description
          end

          def submatcher_failure_message
            submatcher.failure_message
          end

          def submatcher_expectation
            if submatcher.was_negated?
              "Expected #{submatcher.model} not to #{submatcher.description}"
            else
              "Expected #{submatcher.model} to #{submatcher.description}"
            end
          end

          def submatcher_includes_attribute_changed_value_message?
            submatcher.include_attribute_changed_value_message?
          end

          def submatcher_attribute_changed_value_message
            submatcher.attribute_changed_value_message
          end

          private

          attr_reader :submatcher

          def parent_was_negated?
            @parent_was_negated
          end
        end
      end
    end
  end
end
