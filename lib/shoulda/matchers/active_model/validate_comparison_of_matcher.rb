module Shoulda
  module Matchers
    module ActiveModel
      def validate_comparison_of(attr)
        ValidateComparisonOfMatcher.new(attr)
      end

      # @private
      class ValidateComparisonOfMatcher
        NUMERIC_NAME = 'number'.freeze
        DEFAULT_DIFF_TO_COMPARE = 1

        include Qualifiers::IgnoringInterferenceByWriter

        attr_reader :diff_to_compare, :number_of_submatchers

        def initialize(attribute)
          super
          @attribute = attribute
          @submatchers = []
          @diff_to_compare = DEFAULT_DIFF_TO_COMPARE
          @expects_custom_validation_message = false
          @expects_to_allow_nil = false
          @expects_strict = false
          @context = nil
          @expected_message = nil
        end

        def strict
          @expects_strict = true
          self
        end

        def expects_strict?
          @expects_strict
        end

        def allow_nil
          @expects_to_allow_nil = true
          prepare_submatcher(
            AllowValueMatcher.new(nil).
              for(@attribute).
              with_message(:not_a_number),
          )
          self
        end

        def expects_to_allow_nil?
          @expects_to_allow_nil
        end

        def is_greater_than(value)
          prepare_submatcher(comparison_matcher_for(value, :>).for(@attribute))
          self
        end

        def is_greater_than_or_equal_to(value)
          prepare_submatcher(comparison_matcher_for(value, :>=).for(@attribute))
          self
        end

        def is_equal_to(value)
          prepare_submatcher(comparison_matcher_for(value, :==).for(@attribute))
          self
        end

        def is_less_than(value)
          prepare_submatcher(comparison_matcher_for(value, :<).for(@attribute))
          self
        end

        def is_less_than_or_equal_to(value)
          prepare_submatcher(comparison_matcher_for(value, :<=).for(@attribute))
          self
        end

        def is_other_than(value)
          prepare_submatcher(comparison_matcher_for(value, :!=).for(@attribute))
          self
        end

        def with_message(message)
          @expects_custom_validation_message = true
          @expected_message = message
          self
        end

        def expects_custom_validation_message?
          @expects_custom_validation_message
        end

        def on(context)
          @context = context
          self
        end

        def matches?(subject)
          @subject = subject
          @number_of_submatchers = @submatchers.size

          qualify_submatchers
          first_submatcher_that_fails_to_match.nil?
        end

        def does_not_match?(subject)
          @subject = subject
          @number_of_submatchers = @submatchers.size

          qualify_submatchers
          first_submatcher_that_fails_to_not_match.nil?
        end

        def simple_description
          description = ''

          description << "validate that :#{@attribute} looks like "
          description << Shoulda::Matchers::Util.a_or_an(allowed_type_name)

          if comparison_descriptions.present?
            description << " #{comparison_descriptions}"
          end

          description
        end

        def description
          ValidationMatcher::BuildDescription.call(self, simple_description)
        end

        def failure_message
          overall_failure_message.dup.tap do |message|
            message << "\n"
            message << failure_message_for_first_submatcher_that_fails_to_match
          end
        end

        def failure_message_when_negated
          overall_failure_message_when_negated.dup.tap do |message|
            message << "\n"
            message <<
              failure_message_for_first_submatcher_that_fails_to_not_match
          end
        end

        def given_numeric_column?
          attribute_is_active_record_column? &&
            [:integer, :float, :decimal].include?(column_type)
        end

        private

        def overall_failure_message
          Shoulda::Matchers.word_wrap(
            "Expected #{model.name} to #{description}, but this could not "\
            'be proved.',
          )
        end

        def overall_failure_message_when_negated
          Shoulda::Matchers.word_wrap(
            "Expected #{model.name} not to #{description}, but this could not "\
            'be proved.',
          )
        end

        def attribute_is_active_record_column?
          columns_hash.key?(@attribute.to_s)
        end

        def column_type
          columns_hash[@attribute.to_s].type
        end

        def columns_hash
          if @subject.class.respond_to?(:columns_hash)
            @subject.class.columns_hash
          else
            {}
          end
        end

        def prepare_submatcher(submatcher)
          add_submatcher(submatcher)
          submatcher
        end

        def comparison_matcher_for(value, operator)
          ComparisonMatcher.
            new(self, value, operator).
            for(@attribute)
        end

        def add_submatcher(submatcher)
          @submatchers << submatcher
        end

        def qualify_submatchers
          @submatchers.each do |submatcher|
            if @expects_strict
              submatcher.strict(@expects_strict)
            end

            if @expected_message.present?
              submatcher.with_message(@expected_message)
            end

            if @context
              submatcher.on(@context)
            end

            submatcher.ignoring_interference_by_writer(
              ignore_interference_by_writer,
            )
          end
        end

        def number_of_submatchers_for_failure_message
          if has_been_qualified?
            number_of_submatchers - 1
          else
            number_of_submatchers
          end
        end

        def has_been_qualified?
          @submatchers.any? { |submatcher| submatcher_qualified?(submatcher) }
        end

        def submatcher_qualified?(submatcher)
          submatcher.instance_of?(ComparisonMatcher)
        end

        def first_submatcher_that_fails_to_match
          @_first_submatcher_that_fails_to_match ||=
            @submatchers.detect do |submatcher|
              !submatcher.matches?(@subject)
            end
        end

        def first_submatcher_that_fails_to_not_match
          @_first_submatcher_that_fails_to_not_match ||=
            @submatchers.detect do |submatcher|
              !submatcher.does_not_match?(@subject)
            end
        end

        def failure_message_for_first_submatcher_that_fails_to_match
          build_submatcher_failure_message_for(
            first_submatcher_that_fails_to_match,
            :failure_message,
          )
        end

        def failure_message_for_first_submatcher_that_fails_to_not_match
          build_submatcher_failure_message_for(
            first_submatcher_that_fails_to_not_match,
            :failure_message_when_negated,
          )
        end

        def build_submatcher_failure_message_for(
          submatcher,
          failure_message_method
        )
          failure_message = submatcher.public_send(failure_message_method)
          submatcher_description = submatcher.simple_description.
            sub(/\bvalidate that\b/, 'validates').
            sub(/\bdisallow\b/, 'disallows').
            sub(/\ballow\b/, 'allows')
          submatcher_message =
            if number_of_submatchers_for_failure_message > 1
              "In checking that #{model.name} #{submatcher_description}, " +
                failure_message[0].downcase +
                failure_message[1..]
            else
              failure_message
            end

          Shoulda::Matchers.word_wrap(submatcher_message, indent: 2)
        end

        def comparison_descriptions
          description_array = submatcher_comparison_descriptions
          if description_array.empty?
            ''
          else
            submatcher_comparison_descriptions.join(' and ')
          end
        end

        def submatcher_comparison_descriptions
          @submatchers.inject([]) do |arr, submatcher|
            if submatcher.respond_to? :comparison_description
              arr << submatcher.comparison_description
            end
          end
        end

        def allowed_type_name
          'value'
        end

        def model
          @subject.class
        end

        def non_numeric_value
          'abcd'
        end
      end
    end
  end
end
