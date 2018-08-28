module Shoulda
  module Matchers
    module ActiveModel
      # @private
      class ValidationMatcher
        include Qualifiers::Callbacks
        include Qualifiers::IgnoringInterferenceByWriter

        attr_reader :expected_message, :validation_context

        def initialize(attribute)
          @attribute = attribute
          @expects_strict = false
          @expected_message = nil
          @expects_custom_validation_message = false
          @validation_context = nil
          @submatchers = []

          @record = nil
          @was_negated = nil
          @_submatchers_populated = false
        end

        def description
          ValidationMatcher::BuildDescription.call(self, simple_description)
        end

        def expectation_description
          if was_negated?
            "Expected #{model} not to #{expectation}."
          else
            "Expected #{model} to #{expectation}."
          end
        end

        def on(validation_context)
          @validation_context = validation_context
          self
        end

        def strict(expects_strict = true)
          @expects_strict = expects_strict
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
          @subject = @record = record

          populate_submatchers

          matching do
            all_submatchers_match?.tap do
              @was_negated = false
            end
          end
        end

        def does_not_match?(record)
          !matches?(record).tap do
            @was_negated = true
          end
        end

        def failure_message
          overall_failure_message + submatchers_report
        end

        alias_method :failure_message_when_negated, :failure_message

        def submatchers_report
          message = "\n\n"

          # if was_negated?
            message << 'The matcher ran the following subtests:'
          # else
            # message << Shoulda::Matchers.word_wrap(
              # 'The matcher ran the following subtests. ' +
              # 'Those indicated with ✘ failed when they should have ' +
              # 'passed:',
            # )
          # end

          message << "\n\n"

          list = submatcher_results.map do |result|
            indented_item = Shoulda::Matchers.word_wrap(
              result.report_item,
              indent: 2
            )

            icon =
              if result.expected?
                '✔︎'
              elsif result.matched?
                '*'
              else
                '✘'
              end

            icon + indented_item[1..-1]
          end

          message << list.join("\n\n")

          if was_negated?
            message << "\n\nAs noted above, all tests passed. "
            message << 'However, in this case, at least one of them should '
            message << 'have failed!'
          end

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

        def populated_submatchers
          populate_submatchers
          submatchers
        end

        def pretty_print(pp)
          Shoulda::Matchers::Util.pretty_print(self, pp, {
            attribute: attribute,
            expects_strict: expects_strict?,
            expected_message: expected_message,
            expects_custom_validation_message: expects_custom_validation_message?,
            validation_context: validation_context,
            submatchers: submatchers,
            was_negated?: was_negated?,
            record: record
          })
        end

        protected

        attr_reader :attribute, :submatchers, :record, :subject

        def simple_description
          raise NotImplementedError
        end

        def expectation
          description
        end

        def populate_submatchers
          if !@_submatchers_populated
            add_submatchers
            @_submatchers_populated = true
          end
        end

        def add_submatchers
        end

        def add_submatcher(*args)
          submatcher =
            if args.size == 1
              args[0]
            else
              if args[0] < ValidationMatcher
                build_child_validation_matcher(*args)
              else
                args[0].new(*args[1..-1])
              end
            end

          if !submatcher.respond_to?(:active) || submatcher.active?
            submatchers << submatcher
          end
        end

        def submatcher_matches?(submatcher)
          submatcher.matches?(record)
        end

        def add_submatcher_allowing(value_or_values, message = nil, &block)
          matcher =
            if value_or_values.is_a?(Array)
              allow_value_matcher(*value_or_values, message: message, &block)
            else
              allow_value_matcher(value_or_values, message: message, &block)
            end
          add_submatcher(matcher)
          matcher
        end

        def add_submatcher_disallowing(value_or_values, message = nil, &block)
          matcher =
            if value_or_values.is_a?(Array)
              disallow_value_matcher(*value_or_values, message: message, &block)
            else
              disallow_value_matcher(value_or_values, message: message, &block)
            end
          add_submatcher(matcher)
          matcher
        end

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

        def build_child_validation_matcher(matcher_class, *args)
          matcher = matcher_class.new(*args).
            with_message(expected_message).
            on(validation_context).
            strict(expects_strict?).
            ignoring_interference_by_writer(ignore_interference_by_writer)

          yield matcher if block_given?

          matcher
        end

        def model
          record.class
        end

        private

        attr_reader :before_matching_blocks, :after_matching_blocks

        def overall_failure_message
          should_or_should_not =
            if was_negated?
              'should not'
            else
              'should'
            end

          message =
            "The expectation that #{model.name} " +
            "#{should_or_should_not} #{description}"

          message <<
            if message.include?(',')
              ", could not be proved."
            else
              " could not be proved."
            end

          Shoulda::Matchers.word_wrap(message)
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
              submatcher_matches?(submatcher),
              was_negated?,
            )
          end
        end

        def build_allow_or_disallow_value_matcher(matcher_class:, values:, message:)
          build_child_validation_matcher(
            matcher_class,
            *values,
            part_of_larger_matcher: true,
          ) do |matcher|
            matcher.for(attribute).with_message(message || expected_message)
            yield matcher if block_given?
          end
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

          def report_item
            # if expected?
              # submatcher_expectation_description
            # elsif submatcher.respond_to?(:failure_message_as_submatcher)
              # submatcher.failure_message_as_submatcher
            # else
              sections = [submatcher_expectation_description]

              if !expected? && submatcher_aberration_description.present?
                sections << submatcher_aberration_description
              end

              Shoulda::Matchers::Util.join_sections(sections)
            # end
          end

          def submatcher_expectation_description
            submatcher.expectation_description
          end

          def submatcher_aberration_description
            if submatcher.try(:was_negated?)
              submatcher.aberration_description_when_negated
            else
              submatcher.aberration_description
            end
          end

          def submatcher_includes_attribute_changed_value_message?
            submatcher.try(:include_attribute_changed_value_message?)
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
