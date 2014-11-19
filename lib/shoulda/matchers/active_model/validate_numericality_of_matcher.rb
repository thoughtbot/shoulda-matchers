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

        delegate :failure_message, :failure_message_when_negated,
          :failure_message_for_should, :failure_message_for_should_not,
          to: :submatchers

        def initialize(attribute)
          @attribute = attribute
          @submatchers = MatcherCollection.new
          @diff_to_compare = DEFAULT_DIFF_TO_COMPARE
          add_disallow_value_matcher

          submatchers.configure do |matcher|
            matcher.for(attribute)
          end
        end

        def only_integer
          add_submatcher(Numericality::OnlyIntegerMatcher)
          self
        end

        def allow_nil
          add_submatcher(AllowValueMatcher, nil) do |matcher|
            matcher.with_message(:not_a_number)
          end
          self
        end

        def odd
          add_submatcher(Numericality::OddNumberMatcher)
          self
        end

        def even
          add_submatcher(Numericality::EvenNumberMatcher)
          self
        end

        def is_greater_than(value)
          add_comparison_submatcher(value, :>)
          self
        end

        def is_greater_than_or_equal_to(value)
          add_comparison_submatcher(value, :>=)
          self
        end

        def is_equal_to(value)
          add_comparison_submatcher(value, :==)
          self
        end

        def is_less_than(value)
          add_comparison_submatcher(value, :<)
          self
        end

        def is_less_than_or_equal_to(value)
          add_comparison_submatcher(value, :<=)
          self
        end

        def with_message(message)
          submatchers.configure { |matcher| matcher.with_message(message) }
          self
        end

        def matches?(subject)
          @subject = subject
          submatchers.matches?(subject)
        end

        def description
          "only allow #{allowed_types} for #{attribute}#{comparison_descriptions}"
        end

        protected

        attr_reader :attribute

        private

        def add_submatcher(klass, *args, &block)
          submatchers.add(klass, *args, &block)
        end

        def add_disallow_value_matcher
          add_submatcher(DisallowValueMatcher, NON_NUMERIC_VALUE) do |matcher|
            matcher.with_message(:not_a_number)
          end
        end

        def add_comparison_submatcher(value, operator)
          add_submatcher(Numericality::ComparisonMatcher, self, value, operator)
        end

        def diff_to_compare
          possible_diff_to_compares.max
        end

        def possible_diff_to_compares
          [DEFAULT_DIFF_TO_COMPARE] + submatchers.invoke(:diff_to_compare)
        end

        def allowed_types
          if submatcher_allowed_types.empty?
            NUMERIC_NAME
          else
            submatcher_allowed_types.join(', ')
          end
        end

        def submatcher_allowed_types
          submatchers.invoke(:allowed_type)
        end

        def comparison_descriptions
          if submatcher_comparison_descriptions.empty?
            ''
          else
            ' which are ' + submatcher_comparison_descriptions.join(' and ')
          end
        end

        def submatcher_comparison_descriptions
          submatchers.invoke(:comparison_description)
        end
      end
    end
  end
end
