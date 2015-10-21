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
      #     class Age
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
      # @return [ValidateNumericalityOfMatcher]
      #
      def validate_numericality_of(attr)
        ValidateNumericalityOfMatcher.new(attr)
      end

      # @private
      class ValidateNumericalityOfMatcher
        NUMERIC_NAME = 'numbers'
        NON_NUMERIC_VALUE = 'abcd'
        DEFAULT_DIFF_TO_COMPARE = 1

        attr_reader :diff_to_compare

        def initialize(attribute)
          @attribute = attribute
          @submatchers = []
          @diff_to_compare = DEFAULT_DIFF_TO_COMPARE
          @strict = false

          add_disallow_value_matcher
        end

        def strict
          @strict = true
          @submatchers.each(&:strict)
          self
        end

        def only_integer
          prepare_submatcher(
            NumericalityMatchers::OnlyIntegerMatcher.new(self, @attribute)
          )
          self
        end

        def allow_nil
          prepare_submatcher(
            AllowValueMatcher.new(nil)
              .for(@attribute)
              .with_message(:not_a_number)
          )
          self
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
          @submatchers.each { |matcher| matcher.with_message(message) }
          self
        end

        def on(context)
          @submatchers.each { |matcher| matcher.on(context) }
          self
        end

        def matches?(subject)
          @subject = subject

          if given_numeric_column?
            remove_disallow_value_matcher
          end

          if @submatchers.empty?
            raise IneffectiveTestError.create(
              model: @subject.class,
              attribute: @attribute,
              column_type: column_type
            )
          end

          first_failing_submatcher.nil?
        end

        def description
          description_parts = ["only allow #{allowed_types} for #{@attribute}"]

          if comparison_descriptions.present?
            description_parts << comparison_descriptions
          end

          if @strict
            description_parts.insert(1, 'strictly')
            description_parts.join(', ')
          else
            description_parts.join(' ')
          end
        end

        def failure_message
          first_failing_submatcher.failure_message
        end

        def failure_message_when_negated
          first_failing_submatcher.failure_message_when_negated
        end

        def given_numeric_column?
          [:integer, :float, :decimal].include?(column_type)
        end

        private

        def column_type
          if @subject.class.respond_to?(:columns_hash)
            @subject.class.columns_hash[@attribute.to_s].type
          end
        end

        def add_disallow_value_matcher
          disallow_value_matcher = DisallowValueMatcher.new(NON_NUMERIC_VALUE).
            for(@attribute).
            with_message(:not_a_number)

          add_submatcher(disallow_value_matcher)
        end

        def remove_disallow_value_matcher
          @submatchers.shift
        end

        def prepare_submatcher(submatcher)
          add_submatcher(submatcher)

          if submatcher.respond_to?(:diff_to_compare)
            update_diff_to_compare(submatcher)
          end
        end

        def comparison_matcher_for(value, operator)
          NumericalityMatchers::ComparisonMatcher
            .new(self, value, operator)
            .for(@attribute)
        end

        def add_submatcher(submatcher)
          @submatchers << submatcher
        end

        def update_diff_to_compare(matcher)
          @diff_to_compare = [@diff_to_compare, matcher.diff_to_compare].max
        end

        def first_failing_submatcher
          @_first_failing_submatcher ||= @submatchers.detect do |submatcher|
            !submatcher.matches?(@subject)
          end
        end

        def allowed_types
          allowed_array = submatcher_allowed_types
          allowed_array.empty? ? NUMERIC_NAME : allowed_array.join(', ')
        end

        def submatcher_allowed_types
          @submatchers.inject([]){|m, s| m << s.allowed_type if s.respond_to?(:allowed_type); m }
        end

        def comparison_descriptions
          description_array = submatcher_comparison_descriptions
          description_array.empty? ? '' : 'which are ' + submatcher_comparison_descriptions.join(' and ')
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
            if next_word =~ /[aeiou]/
              "an #{next_word}"
            else
              "a #{next_word}"
            end
          end
        end
      end
    end
  end
end
