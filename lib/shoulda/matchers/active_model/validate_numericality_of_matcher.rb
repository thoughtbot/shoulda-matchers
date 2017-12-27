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
      #     RSpec.describe Person, type: :model do
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
      #     RSpec.describe Person, type: :model do
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
      #     RSpec.describe Person, type: :model do
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
      #     RSpec.describe Person, type: :model do
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
      #     RSpec.describe Person, type: :model do
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
      #     RSpec.describe Person, type: :model do
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
      #     RSpec.describe Person, type: :model do
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
      #     RSpec.describe Person, type: :model do
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
      #     RSpec.describe Person, type: :model do
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
      #     RSpec.describe Person, type: :model do
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
      #     RSpec.describe Person, type: :model do
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
      #     RSpec.describe Post, type: :model do
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
      class ValidateNumericalityOfMatcher < ValidationMatcher
        NON_NUMERIC_VALUE = 'not-a-number'.freeze
        DEFAULT_DIFF_TO_COMPARE = 1

        attr_reader :diff_to_compare

        def initialize(attribute)
          super(attribute)
          @options = {
            only_integer: false,
            allow_nil: false,
            comparisons: {},
            cardinality: nil,
          }
          @diff_to_compare = DEFAULT_DIFF_TO_COMPARE
        end

        def only_integer
          options[:only_integer] = true
          self
        end

        def allow_nil
          options[:allow_nil] = true
          self
        end

        def expects_to_allow_nil?
          options[:allow_nil]
        end

        def odd
          options[:cardinality] = :odd
          self
        end

        def even
          options[:cardinality] = :even
          self
        end

        def is_greater_than(value)
          options[:comparisons][:>] = value
          self
        end

        def is_greater_than_or_equal_to(value)
          options[:comparisons][:>=] = value
          self
        end

        def is_equal_to(value)
          options[:comparisons][:==] = value
          self
        end

        def is_less_than(value)
          options[:comparisons][:<] = value
          self
        end

        def is_less_than_or_equal_to(value)
          options[:comparisons][:<=] = value
          self
        end

        def given_numeric_column?
          attribute_is_active_record_column? &&
            [:integer, :float, :decimal].include?(column_type)
        end

        protected

        def simple_description
          parts = [
            "validate that :#{attribute} looks like",
            Shoulda::Matchers::Util.a_or_an(expected_value_description),
          ]

          parts.join(' ')
        end

        def add_submatchers
          add_default_submatcher
          add_submatcher_for_only_integer
          add_submatcher_for_allow_nil
          add_submatcher_for_cardinality
          add_submatchers_for_comparisons
        end

        def add_submatcher(submatcher)
          if submatcher.respond_to?(:diff_to_compare)
            @diff_to_compare = [diff_to_compare, submatcher.diff_to_compare].max
          end

          super(submatcher)
        end

        private

        attr_reader :options, :allowed_type_adjective, :allowed_type_name

        def attribute_is_active_record_column?
          columns_hash.key?(attribute.to_s)
        end

        def column_type
          columns_hash[attribute.to_s].type
        end

        def columns_hash
          if model.respond_to?(:columns_hash)
            model.columns_hash
          else
            {}
          end
        end

        def add_default_submatcher
          add_submatcher_disallowing(
            NON_NUMERIC_VALUE,
            expected_message || :not_a_number,
          )
        end

        def add_submatcher_for_only_integer
          if options[:only_integer]
            submatcher = build_submatcher(
              NumericalityMatchers::OnlyIntegerMatcher,
              self,
              attribute,
            )
            add_submatchers_within(submatcher)
          end
        end

        def add_submatcher_for_allow_nil
          if options[:allow_nil]
            add_submatcher_allowing(nil, :not_a_number)
          end
        end

        def add_submatcher_for_cardinality
          case options[:cardinality]
          when :odd
            submatcher = build_submatcher(
              NumericalityMatchers::OddNumberMatcher,
              self,
              attribute,
            )
            add_submatchers_within(submatcher)
          when :even
            submatcher = build_submatcher(
              NumericalityMatchers::EvenNumberMatcher,
              self,
              attribute,
            )
            add_submatchers_within(submatcher)
          end
        end

        def add_submatchers_for_comparisons
          options[:comparisons].each do |operator, value|
            submatcher = build_submatcher(
              NumericalityMatchers::ComparisonMatcher,
              self,
              attribute,
              value,
              operator,
            )
            add_submatchers_within(submatcher)
          end
        end

        def expected_value_description
          parts = [
            expected_value_cardinality,
            expected_value_type,
            expected_value_comparisons,
          ]

          parts.select(&:present?).join(' ')
        end

        def expected_value_cardinality
          if options[:cardinality]
            options[:cardinality].to_s
          end
        end

        def expected_value_type
          if options[:only_integer]
            'integer'
          else
            'number'
          end
        end

        def expected_value_comparisons
          parts = options[:comparisons].map do |operator, value|
            subparts = []

            subparts <<
              case operator
              when :> then 'greater than'
              when :>= then 'greater than or equal to'
              when :< then 'less than'
              when :<= then 'less than or equal to'
              when :== then 'equal to'
              end

            subparts << value

            subparts.join(' ')
          end

          parts.to_sentence
        end

        def add_submatchers_within(matcher)
          matcher.populated_submatchers.each do |submatcher|
            add_submatcher(submatcher)
          end
        end
      end
    end
  end
end
