module Shoulda
  module Matchers
    module ActiveModel
      # The `validate_numericality_of` matcher tests usage of the
      # `validates_numericality_of` validation.
      #
      #     class Person
      #       include ActiveModel::Model
      #       attr_accessor :gpa
      #
      #       validates_numericality_of :gpa
      #     end
      #
      #     # RSpec
      #     describe Person do
      #       it { should validate_numericality_of(:gpa) }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PersonTest < ActiveSupport::TestCase
      #       should validate_numericality_of(:gpa)
      #     end
      #
      # #### Qualifiers
      #
      # ##### on
      #
      # Use `on` if your validation applies only under a certain context.
      #
      #     class Person
      #       include ActiveModel::Model
      #       attr_accessor :number_of_dependents
      #
      #       validates_numericality_of :number_of_dependents, on: :create
      #     end
      #
      #     # RSpec
      #     describe Person do
      #       it do
      #         should validate_numericality_of(:number_of_dependents).
      #           on(:create)
      #       end
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PersonTest < ActiveSupport::TestCase
      #       should validate_numericality_of(:number_of_dependents).on(:create)
      #     end
      #
      # ##### only_integer
      #
      # Use `only_integer` to test usage of the `:only_integer` option. This
      # asserts that your attribute only allows integer numbers and disallows
      # non-integer ones.
      #
      #     class Person
      #       include ActiveModel::Model
      #       attr_accessor :age
      #
      #       validates_numericality_of :age, only_integer: true
      #     end
      #
      #     # RSpec
      #     describe Person do
      #       it { should validate_numericality_of(:age).only_integer }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PersonTest < ActiveSupport::TestCase
      #       should validate_numericality_of(:age).only_integer
      #     end
      #
      # ##### is_less_than
      #
      # Use `is_less_than` to test usage of the the `:less_than` option. This
      # asserts that the attribute can take a number which is less than the
      # given value and cannot take a number which is greater than or equal to
      # it.
      #
      #     class Person
      #       include ActiveModel::Model
      #       attr_accessor :number_of_cars
      #
      #       validates_numericality_of :number_of_cars, less_than: 2
      #     end
      #
      #     # RSpec
      #     describe Person do
      #       it do
      #         should validate_numericality_of(:number_of_cars).
      #           is_less_than(2)
      #       end
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PersonTest < ActiveSupport::TestCase
      #       should validate_numericality_of(:number_of_cars).
      #         is_less_than(2)
      #     end
      #
      # ##### is_less_than_or_equal_to
      #
      # Use `is_less_than_or_equal_to` to test usage of the
      # `:less_than_or_equal_to` option. This asserts that the attribute can
      # take a number which is less than or equal to the given value and cannot
      # take a number which is greater than it.
      #
      #     class Person
      #       include ActiveModel::Model
      #       attr_accessor :birth_year
      #
      #       validates_numericality_of :birth_year, less_than_or_equal_to: 1987
      #     end
      #
      #     # RSpec
      #     describe Person do
      #       it do
      #         should validate_numericality_of(:birth_year).
      #           is_less_than_or_equal_to(1987)
      #       end
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PersonTest < ActiveSupport::TestCase
      #       should validate_numericality_of(:birth_year).
      #         is_less_than_or_equal_to(1987)
      #     end
      #
      # ##### is_equal_to
      #
      # Use `is_equal_to` to test usage of the `:equal_to` option. This asserts
      # that the attribute can take a number which is equal to the given value
      # and cannot take a number which is not equal.
      #
      #     class Person
      #       include ActiveModel::Model
      #       attr_accessor :weight
      #
      #       validates_numericality_of :weight, equal_to: 150
      #     end
      #
      #     # RSpec
      #     describe Person do
      #       it { should validate_numericality_of(:weight).is_equal_to(150) }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PersonTest < ActiveSupport::TestCase
      #       should validate_numericality_of(:weight).is_equal_to(150)
      #     end
      #
      # ##### is_greater_than_or_equal_to
      #
      # Use `is_greater_than_or_equal_to` to test usage of the
      # `:greater_than_or_equal_to` option. This asserts that the attribute can
      # take a number which is greater than or equal to the given value and
      # cannot take a number which is less than it.
      #
      #     class Person
      #       include ActiveModel::Model
      #       attr_accessor :height
      #
      #       validates_numericality_of :height, greater_than_or_equal_to: 55
      #     end
      #
      #     # RSpec
      #     describe Person do
      #       it do
      #         should validate_numericality_of(:height).
      #           is_greater_than_or_equal_to(55)
      #       end
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PersonTest < ActiveSupport::TestCase
      #       should validate_numericality_of(:height).
      #         is_greater_than_or_equal_to(55)
      #     end
      #
      # ##### is_greater_than
      #
      # Use `is_greater_than` to test usage of the `:greater_than` option.
      # This asserts that the attribute can take a number which is greater than
      # the given value and cannot take a number less than or equal to it.
      #
      #     class Person
      #       include ActiveModel::Model
      #       attr_accessor :legal_age
      #
      #       validates_numericality_of :legal_age, greater_than: 21
      #     end
      #
      #     # RSpec
      #     describe Person do
      #       it do
      #         should validate_numericality_of(:legal_age).
      #           is_greater_than(21)
      #       end
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PersonTest < ActiveSupport::TestCase
      #       should validate_numericality_of(:legal_age).
      #         is_greater_than(21)
      #     end
      #
      # ##### even
      #
      # Use `even` to test usage of the `:even` option. This asserts that the
      # attribute can take odd numbers and cannot take even ones.
      #
      #     class Person
      #       include ActiveModel::Model
      #       attr_accessor :birth_month
      #
      #       validates_numericality_of :birth_month, even: true
      #     end
      #
      #     # RSpec
      #     describe Person do
      #       it { should validate_numericality_of(:birth_month).even }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PersonTest < ActiveSupport::TestCase
      #       should validate_numericality_of(:birth_month).even
      #     end
      #
      # ##### odd
      #
      # Use `odd` to test usage of the `:odd` option. This asserts that the
      # attribute can take a number which is odd and cannot take a number which
      # is even.
      #
      #     class Person
      #       include ActiveModel::Model
      #       attr_accessor :birth_day
      #
      #       validates_numericality_of :birth_day, odd: true
      #     end
      #
      #     # RSpec
      #     describe Person do
      #       it { should validate_numericality_of(:birth_day).odd }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PersonTest < ActiveSupport::TestCase
      #       should validate_numericality_of(:birth_day).odd
      #     end
      #
      # ##### with_message
      #
      # Use `with_message` if you are using a custom validation message.
      #
      #     class Person
      #       include ActiveModel::Model
      #       attr_accessor :number_of_dependents
      #
      #       validates_numericality_of :number_of_dependents,
      #         message: 'Number of dependents must be a number'
      #     end
      #
      #     # RSpec
      #     describe Person do
      #       it do
      #         should validate_numericality_of(:number_of_dependents).
      #           with_message('Number of dependents must be a number')
      #       end
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PersonTest < ActiveSupport::TestCase
      #       should validate_numericality_of(:number_of_dependents).
      #         with_message('Number of dependents must be a number')
      #     end
      #
      # ##### allow_nil
      #
      # Use `allow_nil` to assert that the attribute allows nil.
      #
      #     class Post
      #       include ActiveModel::Model
      #       attr_accessor :age
      #
      #       validates_numericality_of :age, allow_nil: true
      #     end
      #
      #     # RSpec
      #     describe Post do
      #       it { should validate_numericality_of(:age).allow_nil }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PostTest < ActiveSupport::TestCase
      #       should validate_numericality_of(:age).allow_nil
      #     end
      #
      # ##### ignoring_interference_by_writer
      #
      # Use `ignoring_interference_by_writer` when the attribute you're testing
      # changes incoming values. This qualifier will instruct the matcher to
      # suppress raising an AttributeValueChangedError, as long as changing the
      # doesn't also change the outcome of the test and cause it to fail. See
      # the documentation for `allow_value` for more information on this.
      #
      # Here, `gpa` is an integer column, so it will typecast all values to
      # integers. We need to use `ignoring_interference_by_writer` because the
      # `only_integer` qualifier will attempt to set `gpa` to a float and assert
      # that it makes the record invalid.
      #
      #     class Person < ActiveRecord::Base
      #       validates_numericality_of :gpa, only_integer: true
      #     end
      #
      #     # RSpec
      #     describe Person do
      #       it do
      #         should validate_numericality_of(:gpa).
      #           only_integer.
      #           ignoring_interference_by_writer
      #       end
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PersonTest < ActiveSupport::TestCase
      #       should validate_numericality_of(:gpa).
      #         only_integer.
      #         ignoring_interference_by_writer
      #     end
      #
      # @return [ValidateNumericalityOfMatcher]
      #
      def validate_numericality_of(attr)
        ValidateNumericalityOfMatcher.new(attr)
      end

      # @private
      class ValidateNumericalityOfMatcher
        NUMERIC_NAME = 'number'
        NON_NUMERIC_VALUE = 'abcd'
        DEFAULT_DIFF_TO_COMPARE = 1

        include Qualifiers::IgnoringInterferenceByWriter

        attr_reader :diff_to_compare

        def initialize(attribute)
          super
          @attribute = attribute
          @submatchers = []
          @diff_to_compare = DEFAULT_DIFF_TO_COMPARE
          @expects_custom_validation_message = false
          @expects_to_allow_nil = false
          @expects_strict = false
          @allowed_type_adjective = nil
          @allowed_type_name = 'number'
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

        def only_integer
          prepare_submatcher(
            NumericalityMatchers::OnlyIntegerMatcher.new(self, @attribute)
          )
          self
        end

        def allow_nil
          @expects_to_allow_nil = true
          prepare_submatcher(
            AllowValueMatcher.new(nil)
              .for(@attribute)
              .with_message(:not_a_number)
          )
          self
        end

        def expects_to_allow_nil?
          @expects_to_allow_nil
        end

        def odd
          prepare_submatcher(
            NumericalityMatchers::OddNumberMatcher.new(self, @attribute)
          )
          self
        end

        def even
          prepare_submatcher(
            NumericalityMatchers::EvenNumberMatcher.new(self, @attribute)
          )
          self
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

          unless given_numeric_column?
            add_disallow_value_matcher
          end

          if @submatchers.empty?
            raise IneffectiveTestError.create(
              model: @subject.class,
              attribute: @attribute,
              column_type: column_type
            )
          end

          qualify_submatchers
          first_failing_submatcher.nil?
        end

        def simple_description
          description = ''

          description << "validate that :#{@attribute} looks like "
          description << Shoulda::Matchers::Util.a_or_an(full_allowed_type)

          if comparison_descriptions.present?
            description << ' ' + comparison_descriptions
          end

          description
        end

        def description
          ValidationMatcher::BuildDescription.call(self, simple_description)
        end

        def failure_message
          overall_failure_message.dup.tap do |message|
            message << "\n"
            message << failure_message_for_first_failing_submatcher
          end
        end

        def failure_message_when_negated
          overall_failure_message_when_negated.dup.tap do |message|
            if submatcher_failure_message_when_negated.present?
              raise "hmm, this needs to be implemented."
              message << "\n"
              message << Shoulda::Matchers.word_wrap(
                submatcher_failure_message_when_negated,
                indent: 2
              )
            end
          end
        end

        def given_numeric_column?
          [:integer, :float, :decimal].include?(column_type)
        end

        private

        def model
          @subject.class
        end

        def overall_failure_message
          Shoulda::Matchers.word_wrap(
            "#{model.name} did not properly #{description}."
          )
        end

        def overall_failure_message_when_negated
          Shoulda::Matchers.word_wrap(
            "Expected #{model.name} not to #{description}, but it did."
          )
        end

        def column_type
          if @subject.class.respond_to?(:columns_hash)
            @subject.class.columns_hash[@attribute.to_s].type
          end
        end

        def add_disallow_value_matcher
          disallow_value_matcher = DisallowValueMatcher.
            new(NON_NUMERIC_VALUE).
            for(@attribute).
            with_message(:not_a_number)

          add_submatcher(disallow_value_matcher)
        end

        def prepare_submatcher(submatcher)
          add_submatcher(submatcher)
          submatcher
        end

        def comparison_matcher_for(value, operator)
          NumericalityMatchers::ComparisonMatcher.
            new(self, value, operator).
            for(@attribute)
        end

        def add_submatcher(submatcher)
          if submatcher.respond_to?(:allowed_type_name)
            @allowed_type_name = submatcher.allowed_type_name
          end

          if submatcher.respond_to?(:allowed_type_adjective)
            @allowed_type_adjective = submatcher.allowed_type_adjective
          end

          if submatcher.respond_to?(:diff_to_compare)
            @diff_to_compare = [@diff_to_compare, submatcher.diff_to_compare].max
          end

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
              ignore_interference_by_writer
            )
          end
        end

        def number_of_submatchers_for_failure_message
          if has_been_qualified?
            @submatchers.size - 1
          else
            @submatchers.size
          end
        end

        def has_been_qualified?
          @submatchers.any? do |submatcher|
            submatcher.class.parent == NumericalityMatchers
          end
        end

        def first_failing_submatcher
          @_failing_submatchers ||= @submatchers.detect do |submatcher|
            !submatcher.matches?(@subject)
          end
        end

        def submatcher_failure_message
          first_failing_submatcher.failure_message
        end

        def submatcher_failure_message_when_negated
          first_failing_submatcher.failure_message_when_negated
        end

        def failure_message_for_first_failing_submatcher
          submatcher = first_failing_submatcher

          if number_of_submatchers_for_failure_message > 1
            submatcher_description = submatcher.simple_description.
              sub(/\bvalidate that\b/, 'validates').
              sub(/\bdisallow\b/, 'disallows').
              sub(/\ballow\b/, 'allows')
            submatcher_message =
              "In checking that #{model.name} #{submatcher_description}, " +
              submatcher.failure_message[0].downcase +
              submatcher.failure_message[1..-1]
          else
            submatcher_message = submatcher.failure_message
          end

          Shoulda::Matchers.word_wrap(submatcher_message, indent: 2)
        end

        def full_allowed_type
          "#{@allowed_type_adjective} #{@allowed_type_name}".strip
        end

        def comparison_descriptions
          description_array = submatcher_comparison_descriptions
          description_array.empty? ? '' : submatcher_comparison_descriptions.join(' and ')
        end

        def submatcher_comparison_descriptions
          @submatchers.inject([]) do |arr, submatcher|
            if submatcher.respond_to? :comparison_description
              arr << submatcher.comparison_description
            end
            arr
          end
        end

        class IneffectiveTestError < Shoulda::Matchers::Error
          attr_accessor :model, :attribute, :column_type

          def message
            Shoulda::Matchers.word_wrap <<-MESSAGE
You are attempting to use validate_numericality_of, but the attribute you're
testing, :#{attribute}, is #{a_or_an(column_type)} column. One of the things
that the numericality matcher does is to assert that setting :#{attribute} to a
string that doesn't look like #{a_or_an(column_type)} will cause your
#{humanized_model_name} to become invalid. In this case, it's impossible to make
this assertion since :#{attribute} will typecast any incoming value to
#{a_or_an(column_type)}. This means that it's already guaranteed to be numeric!
Since this matcher isn't doing anything, you can remove it from your model
tests, and in fact, you can remove the validation from your model as it isn't
doing anything either.
            MESSAGE
          end

          private

          def humanized_model_name
            model.name.humanize.downcase
          end

          def a_or_an(next_word)
            Shoulda::Matchers::Util.a_or_an(next_word)
          end
        end
      end
    end
  end
end
