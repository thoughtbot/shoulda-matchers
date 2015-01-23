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
      #     # Test::Unit
      #     class PersonTest < ActiveSupport::TestCase
      #       should validate_numericality_of(:gpa)
      #     end
      #
      # #### Qualifiers
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
      #     # Test::Unit
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
      #     # Test::Unit
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
      #     # Test::Unit
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
      #     # Test::Unit
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
      #     # Test::Unit
      #     class PersonTest < ActiveSupport::TestCase
      #       should validate_numericality_of(:height).
      #         is_greater_than_or_equal_to(55)
      #     end
      #
      # ##### is_greater_than
      #
      # Use `is_greater_than` to test usage of tthe `:greater_than` option.
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
      #     # Test::Unit
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
      #     # Test::Unit
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
      #     # Test::Unit
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
      #     # Test::Unit
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
      #     # Test::Unit
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
          add_disallow_value_matcher
        end

        def only_integer
          prepare_submatcher(
            NumericalityMatchers::OnlyIntegerMatcher.new(@attribute)
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
            NumericalityMatchers::OddNumberMatcher.new(@attribute)
          )
          self
        end

        def even
          prepare_submatcher(
            NumericalityMatchers::EvenNumberMatcher.new(@attribute)
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

        def matches?(subject)
          @subject = subject
          failing_submatchers.empty?
        end

        def description
          "only allow #{allowed_types} for #{@attribute}#{comparison_descriptions}"
        end

        def failure_message
          last_failing_submatcher.failure_message
        end
        alias failure_message_for_should failure_message

        def failure_message_when_negated
          last_failing_submatcher.failure_message_when_negated
        end
        alias failure_message_for_should_not failure_message_when_negated

        private

        def add_disallow_value_matcher
          disallow_value_matcher = DisallowValueMatcher.new(NON_NUMERIC_VALUE).
            for(@attribute).
            with_message(:not_a_number)

          add_submatcher(disallow_value_matcher)
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

        def submatchers_and_results
          @_submatchers_and_results ||=
            @submatchers.map do |matcher|
              { matcher: matcher, matched: matcher.matches?(@subject) }
            end
        end

        def failing_submatchers
          submatchers_and_results.
            select { |x| !x[:matched] }.
            map { |x| x[:matcher] }
        end

        def last_failing_submatcher
          failing_submatchers.last
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
          description_array.empty? ? '' : ' which are ' + submatcher_comparison_descriptions.join(' and ')
        end

        def submatcher_comparison_descriptions
          @submatchers.inject([]) do |arr, submatcher|
            if submatcher.respond_to? :comparison_description
              arr << submatcher.comparison_description
            end
            arr
          end
        end
      end
    end
  end
end
