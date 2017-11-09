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
          @subject = nil
          @submatchers = []
          @expected_message = nil
          @expects_custom_validation_message = false
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

        def matches?(subject)
          @subject = subject
          @was_negated = false
          false
        end

        def does_not_match?(subject)
          @subject = subject
          !matches?(subject)
          @was_negated = true
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
            message << 'At least one of these submatchers should have failed:'
          else
            message << 'All of these submatchers should have passed:'
          end

          message << "\n\n"

          list = submatcher_results.map do |submatcher, matched|
            icon = if matched then '✔︎' else '✘' end
            submessage = "#{icon} should #{submatcher.description}"

            if !matched
              sub_failure_message =
                if submatcher.was_negated?
                  submatcher.failure_message_when_negated
                else
                  submatcher.failure_message
                end

              submessage << "\n\n"
              submessage << Shoulda::Matchers.word_wrap(
                "#{sub_failure_message}\n",
                indent: 2,
              )
            end

            submessage
          end

          message << Shoulda::Matchers.word_wrap(list.join("\n"))
        end

        def was_negated?
          @was_negated
        end

        protected

        attr_reader :attribute, :context, :subject, :submatchers,
          :first_failing_submatcher

        def model
          subject.class
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

        def disallows_value_of(value_or_values, message: nil, &block)
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
          message =
            "Expected #{model.name} to #{description}, " +
            "but there were some issues."

          Shoulda::Matchers.word_wrap(message)
        end

        def overall_failure_message_when_negated
          Shoulda::Matchers.word_wrap(
            "Expected #{model.name} not to #{description}, but it did."
          )
        end

        def indented_failure_message_for_first_failing_submatcher
          if failure_message_for_first_failing_submatcher.present?
            "\n" + Shoulda::Matchers.word_wrap(
              failure_message_for_first_failing_submatcher,
              indent: 2
            )
          end
        end

        def failure_message_for_first_failing_submatcher
          first_failing_submatcher.try(:failure_message)
        end

        def all_submatchers_match?
          submatcher_results.all? { |submatcher, matched| matched }
        end

        def first_failing_submatcher
          tuple = submatcher_results.detect { |submatcher, matched | !matched }

          if tuple
            tuple.first
          end
        end

        def submatcher_results
          @_submatcher_results ||= submatchers.map do |submatcher|
            [submatcher, submatcher.matches?(subject)]
          end
        end

        def build_allow_or_disallow_value_matcher(matcher_class:, values:, message:)
          matcher = matcher_class.new(*values).
            for(attribute).
            with_message(message).
            on(context).
            strict(expects_strict?).
            ignoring_interference_by_writer(ignore_interference_by_writer)

          yield matcher if block_given?

          matcher
        end
      end
    end
  end
end
