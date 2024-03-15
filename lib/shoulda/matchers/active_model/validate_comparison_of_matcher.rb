module Shoulda
  module Matchers
    module ActiveModel
      # The `validate_comparison_of` matcher tests usage of the
      # `validates_comparison_of` validation.
      #
      #     class Person
      #       include ActiveModel::Model
      #       attr_accessor :gpa
      #
      #       validates_comparison_of :gpa, greater_than: 10
      #     end
      #
      #     # RSpec
      #     RSpec.describe Person, type: :model do
      #       it { should validate_comparison_of(:gpa).is_greater_than(10) }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PersonTest < ActiveSupport::TestCase
      #       should validate_comparison_of(:gpa).is_greater_than(10)
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
      #       attribute :number_of_dependents, :integer
      #       attr_accessor :number_of_dependents
      #
      #       validates_comparison_of :number_of_dependents, on: :create, greater_than: 0
      #     end
      #
      #     # RSpec
      #     RSpec.describe Person, type: :model do
      #       it do
      #         should validate_comparison_of(:number_of_dependents).
      #           is_greater_than(0).
      #           on(:create)
      #       end
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PersonTest < ActiveSupport::TestCase
      #       should validate_comparison_of(:number_of_dependents).is_greater_than(0).on(:create)
      #     end
      #
      # ##### is_less_than
      #
      # Use `is_less_than` to test usage of the the `:less_than` option. This
      # asserts that the attribute can take a value which is less than the
      # given value and cannot take a value which is greater than or equal to
      # it. It can also accept methods or procs that returns a given value.
      #
      #     class Person
      #       include ActiveModel::Model
      #       attribute :number_of_cars, :integer
      #       attr_accessor :number_of_cars
      #
      #       validates_comparison_of :number_of_cars, less_than: :current_number_of_cars
      #
      #       def current_number_of_cars
      #         10
      #       end
      #     end
      #
      #     # RSpec
      #     RSpec.describe Person, type: :model do
      #       it do
      #         should validate_comparison_of(:number_of_cars).
      #           is_less_than(:current_number_of_cars)
      #       end
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PersonTest < ActiveSupport::TestCase
      #       should validate_comparison_of(:number_of_cars).
      #         is_less_than(:current_number_of_cars)
      #     end
      #
      # ##### is_less_than_or_equal_to
      #
      # Use `is_less_than_or_equal_to` to test usage of the
      # `:less_than_or_equal_to` option. This asserts that the attribute can
      # take a value which is less than or equal to the given value and cannot
      # take a value which is greater than it. It can also accept methods or
      # procs that returns a given value.
      #
      #     class Person
      #       include ActiveModel::Model
      #       attr_accessor :birth_date
      #
      #       validates_comparison_of :birth_date, less_than_or_equal_to: Date.new(1987, 12, 31)
      #     end
      #
      #     # RSpec
      #     RSpec.describe Person, type: :model do
      #       it do
      #         should validate_comparison_of(:birth_date).
      #           is_less_than_or_equal_to(Date.new(1987, 12, 31))
      #       end
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PersonTest < ActiveSupport::TestCase
      #       should validate_comparison_of(:birth_date).
      #         is_less_than_or_equal_to(Date.new(1987, 12, 31))
      #     end
      #
      # ##### is_greater_than_or_equal_to
      #
      # Use `is_greater_than_or_equal_to` to test usage of the
      # `:greater_than_or_equal_to` option. This asserts that the attribute can
      # take a value which is greater than or equal to the given value and
      # cannot take a value which is less than it.
      #
      #     class Person
      #       include ActiveModel::Model
      #       attribute :birth_date, :date
      #       attr_accessor :birth_date
      #
      #       validates_comparison_of :birth_date,
      #                                greater_than_or_equal_to: -> { 18.years.ago.to_date }
      #     end
      #
      #     # RSpec
      #     RSpec.describe Person, type: :model do
      #       it do
      #         should validate_comparison_of(:birth_date).
      #           is_greater_than_or_equal_to(-> { 18.years.ago.to_date })
      #       end
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PersonTest < ActiveSupport::TestCase
      #       should validate_comparison_of(:birth_date).
      #         is_greater_than_or_equal_to(-> { 18.years.ago.to_date })
      #     end
      #
      # ##### is_greater_than
      #
      # Use `is_greater_than` to test usage of the `:greater_than` option.
      # This asserts that the attribute can take a value which is greater than
      # the given value and cannot take a value less than or equal to it.
      # It can also accept methods or procs that returns a given value.
      #
      #     class Person
      #       include ActiveModel::Model
      #       attribute :legal_age, :integer
      #       attr_accessor :legal_age
      #
      #       validates_comparison_of :legal_age, greater_than: 21
      #     end
      #
      #     # RSpec
      #     RSpec.describe Person, type: :model do
      #       it do
      #         should validate_comparison_of(:legal_age).
      #           is_greater_than(21)
      #       end
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PersonTest < ActiveSupport::TestCase
      #       should validate_comparison_of(:legal_age).
      #         is_greater_than(21)
      #     end
      #
      # ##### is_equal_to
      #
      # Use `is_equal_to` to test usage of the `:equal_to` option. This asserts
      # that the attribute can take a value which is equal to the given value
      # and cannot take a value which is not equal. It can also accept methods or
      # procs that returns a given value.
      #
      #     class Person
      #       include ActiveModel::Model
      #       attribute :favorite_color, :string
      #       attr_accessor :favorite_color
      #
      #       validates_comparison_of :favorite_color, equal_to: "blue"
      #     end
      #
      #     # RSpec
      #     RSpec.describe Person, type: :model do
      #       it { should validate_comparison_of(:favorite_color).is_equal_to("blue") }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PersonTest < ActiveSupport::TestCase
      #       should validate_comparison_of(:favorite_color).is_equal_to("blue")
      #     end
      #
      #
      # ##### is_other_than
      #
      # Use `is_other_than` to test usage of the `:other_than` option.
      # This asserts that the attribute can take a number which is not equal to
      # the given value.
      #
      #     class Person
      #       include ActiveModel::Model
      #       attr_accessor :legal_age
      #
      #       validates_comparison_of :legal_age, other_than: 21
      #     end
      #
      #     # RSpec
      #     RSpec.describe Person, type: :model do
      #       it do
      #         should validate_comparison_of(:legal_age).
      #           is_other_than(21)
      #       end
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PersonTest < ActiveSupport::TestCase
      #       should validate_comparison_of(:legal_age).
      #         is_other_than(21)
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
      #       validates_comparison_of :number_of_dependents, greater_than: 0
      #         message: 'Number of dependents must be a number'
      #     end
      #
      #     # RSpec
      #     RSpec.describe Person, type: :model do
      #       it do
      #         should validate_comparison_of(:number_of_dependents).
      #           is_greater_than(0).
      #           with_message('Number of dependents must be a number')
      #       end
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PersonTest < ActiveSupport::TestCase
      #       should validate_comparison_of(:number_of_dependents).
      #         is_greater_than(0).
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
      #       validates_comparison_of :age, greater_than: 0, allow_nil: true
      #     end
      #
      #     # RSpec
      #     RSpec.describe Post, type: :model do
      #       it { should validate_comparison_of(:age).is_greater_than(0).allow_nil }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PostTest < ActiveSupport::TestCase
      #       should validate_comparison_of(:age).is_greater_than(0).allow_nil
      #     end
      #
      # @return [ValidateComparisonOfMatcher]
      #
      def validate_comparison_of(attr)
        ValidateComparisonOfMatcher.new(attr)
      end

      # @private
      class ValidateComparisonOfMatcher < ValidationMatcher
        NUMERIC_NAME = 'number'.freeze
        DEFAULT_DIFF_TO_COMPARE = 1

        attr_reader :diff_to_compare, :number_of_submatchers

        def initialize(attribute)
          super
          @submatchers = []
          @diff_to_compare = DEFAULT_DIFF_TO_COMPARE
          @expects_to_allow_nil = false
          @comparison_submatcher = false
        end

        def allow_nil
          @expects_to_allow_nil = true
          prepare_submatcher(allow_value_matcher(nil))
          self
        end

        def expects_to_allow_nil?
          @expects_to_allow_nil
        end

        def is_greater_than(value)
          prepare_submatcher(comparison_matcher_for(value, :>).for(attribute))
          self
        end

        def is_greater_than_or_equal_to(value)
          prepare_submatcher(comparison_matcher_for(value, :>=).for(attribute))
          self
        end

        def is_equal_to(value)
          prepare_submatcher(comparison_matcher_for(value, :==).for(attribute))
          self
        end

        def is_less_than(value)
          prepare_submatcher(comparison_matcher_for(value, :<).for(attribute))
          self
        end

        def is_less_than_or_equal_to(value)
          prepare_submatcher(comparison_matcher_for(value, :<=).for(attribute))
          self
        end

        def is_other_than(value)
          prepare_submatcher(comparison_matcher_for(value, :!=).for(attribute))
          self
        end

        def matches?(subject)
          @subject = subject
          @number_of_submatchers = @submatchers.size
          unless @comparison_matcher
            raise(ArgumentError, "matcher isn't qualified with any comparison matcher")
          end

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
          String.new.tap do |description|
            description << "validate that :#{attribute} looks like "
            description << Shoulda::Matchers::Util.a_or_an(allowed_type_name)

            if comparison_descriptions.present?
              description << " #{comparison_descriptions}"
            end
          end
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

        def attribute_is_active_record_column?
          columns_hash.key?(attribute.to_s)
        end

        def column_type
          columns_hash[attribute.to_s].type
        end

        def columns_hash
          if subject.class.respond_to?(:columns_hash)
            subject.class.columns_hash
          else
            {}
          end
        end

        def prepare_submatcher(submatcher)
          add_submatcher(submatcher)
          submatcher
        end

        def comparison_matcher_for(value, operator)
          @comparison_matcher = true
          ComparisonMatcher.
            new(self, value, operator).
            for(attribute)
        end

        def add_submatcher(submatcher)
          @submatchers << submatcher
        end

        def qualify_submatchers
          @submatchers.each do |submatcher|
            if @expects_strict
              submatcher.strict
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
              !submatcher.matches?(subject)
            end
        end

        def first_submatcher_that_fails_to_not_match
          @_first_submatcher_that_fails_to_not_match ||=
            @submatchers.detect do |submatcher|
              submatcher.matches?(subject)
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
            arr << if submatcher.respond_to? :comparison_description
                     submatcher.comparison_description
                   end
          end
        end

        def allowed_type_name
          'value'
        end

        def non_numeric_value
          'abcd'
        end
      end
    end
  end
end
