require 'unit_spec_helper'

describe Shoulda::Matchers::ActiveModel::ValidateNumericalityOfMatcher, type: :model do
  class << self
    def all_qualifiers
      [
        {
          category: :comparison,
          name: :is_greater_than,
          argument: 1,
          validation_name: :greater_than,
          validation_value: 1,
        },
        {
          category: :comparison,
          name: :is_greater_than_or_equal_to,
          argument: 1,
          validation_name: :greater_than_or_equal_to,
          validation_value: 1,
        },
        {
          category: :comparison,
          name: :is_less_than,
          argument: 1,
          validation_name: :less_than,
          validation_value: 1,
        },
        {
          category: :comparison,
          name: :is_less_than_or_equal_to,
          argument: 1,
          validation_name: :less_than_or_equal_to,
          validation_value: 1,
        },
        {
          category: :comparison,
          name: :is_equal_to,
          argument: 1,
          validation_name: :equal_to,
          validation_value: 1,
        },
        {
          category: :cardinality,
          name: :odd,
          validation_name: :odd,
          validation_value: true,
        },
        {
          category: :cardinality,
          name: :even,
          validation_name: :even,
          validation_value: true,
        },
        {
          name: :only_integer,
          validation_name: :only_integer,
          validation_value: true,
        },
        {
          name: :on,
          argument: :customizable,
          validation_name: :on,
          validation_value: :customizable
        }
      ]
    end

    def qualifiers_under(category)
      all_qualifiers.select do |qualifier|
        qualifier[:category] == category
      end
    end

    def mutually_exclusive_qualifiers
      qualifiers_under(:cardinality) + qualifiers_under(:comparison)
    end

    def non_mutually_exclusive_qualifiers
      all_qualifiers - mutually_exclusive_qualifiers
    end

    def validations_by_qualifier
      all_qualifiers.each_with_object({}) do |qualifier, hash|
        hash[qualifier[:name]] = qualifier[:validation_name]
      end
    end

    def all_qualifier_combinations
      combinations = []

      ([nil] + mutually_exclusive_qualifiers).each do |mutually_exclusive_qualifier|
        (0..non_mutually_exclusive_qualifiers.length).each do |n|
          non_mutually_exclusive_qualifiers.combination(n) do |combination|
            super_combination = (
              [mutually_exclusive_qualifier] +
              combination
            )
            super_combination.select!(&:present?)

            if super_combination.any?
              combinations << super_combination
            end
          end
        end
      end

      combinations
    end

    def default_qualifier_arguments
      all_qualifiers.each_with_object({}) do |qualifier, hash|
        hash[qualifier[:name]] = qualifier[:argument]
      end
    end

    def default_validation_values
      all_qualifiers.each_with_object({}) do |qualifier, hash|
        hash[qualifier[:validation_name]] = qualifier[:validation_value]
      end
    end
  end

  context 'qualified with nothing' do
    context 'and validating numericality' do
      it 'accepts' do
        record = build_record_validating_numericality
        expect(record).to validate_numericality
      end

      it_supports(
        'ignoring_interference_by_writer',
        tests: {
          accept_if_qualified_but_changing_value_does_not_interfere: {
            changing_values_with: :next_value,
          },
          reject_if_qualified_but_changing_value_interferes: {
            model_name: 'Example',
            attribute_name: :attr,
            changing_values_with: :numeric_value,
            expected_message: <<-MESSAGE.strip
Example did not properly validate that :attr looks like a number.
  After setting :attr to ‹"abcd"› -- which was read back as ‹"1"› -- the
  matcher expected the Example to be invalid, but it was valid instead.

  As indicated in the message above, :attr seems to be changing certain
  values as they are set, and this could have something to do with why
  this test is failing. If you've overridden the writer method for this
  attribute, then you may need to change it to make this test pass, or
  do something else entirely.
            MESSAGE
          }
        }
      )

      context 'when the attribute is a virtual attribute in an ActiveRecord model' do
        it 'accepts' do
          record = build_record_validating_numericality_of_virtual_attribute
          expect(record).to validate_numericality
        end
      end

      context 'when the column is an integer column' do
        it 'accepts (and does not raise an AttributeChangedValueError)' do
          record = build_record_validating_numericality(column_type: :integer)
          expect(record).to validate_numericality
        end
      end

      context 'when the column is a float column' do
        it 'accepts (and does not raise an AttributeChangedValueError)' do
          record = build_record_validating_numericality(column_type: :float)
          expect(record).to validate_numericality
        end
      end

      context 'when the column is a decimal column' do
        it 'accepts (and does not raise an AttributeChangedValueError)' do
          record = build_record_validating_numericality(column_type: :decimal)
          expect(record).to validate_numericality
        end
      end

      if database_supports_money_columns?
        context 'when the column is a money column' do
          it 'accepts (and does not raise an AttributeChangedValueError)' do
            record = build_record_validating_numericality(column_type: :money)
            expect(record).to validate_numericality
          end
        end
      end
    end

    context 'and not validating anything' do
      it 'rejects since it does not disallow non-numbers' do
        record = build_record_validating_nothing

        assertion = -> { expect(record).to validate_numericality }

        message = <<-MESSAGE
Example did not properly validate that :attr looks like a number.
  After setting :attr to ‹"abcd"›, the matcher expected the Example to
  be invalid, but it was valid instead.
        MESSAGE

        expect(&assertion).to fail_with_message(message)
      end
    end
  end

  context 'qualified with allow_nil' do
    context 'and validating with allow_nil' do
      it 'accepts' do
        record = build_record_validating_numericality(allow_nil: true)
        expect(record).to validate_numericality.allow_nil
      end

      it_supports(
        'ignoring_interference_by_writer',
        tests: {
          accept_if_qualified_but_changing_value_does_not_interfere: {
            changing_values_with: :next_value_or_numeric_value,
          },
          reject_if_qualified_but_changing_value_interferes: {
            model_name: 'Example',
            attribute_name: :attr,
            changing_values_with: :next_value_or_non_numeric_value,
            expected_message: <<-MESSAGE.strip
Example did not properly validate that :attr looks like a number, but
only if it is not nil.
  In checking that Example allows :attr to be ‹nil›, after setting :attr
  to ‹nil› -- which was read back as ‹"a"› -- the matcher expected the
  Example to be valid, but it was invalid instead, producing these
  validation errors:

  * attr: ["is not a number"]

  As indicated in the message above, :attr seems to be changing certain
  values as they are set, and this could have something to do with why
  this test is failing. If you've overridden the writer method for this
  attribute, then you may need to change it to make this test pass, or
  do something else entirely.
            MESSAGE
          }
        }
      ) do
        def validation_matcher_scenario_args
          super.deep_merge(validation_options: { allow_nil: true })
        end

        def configure_validation_matcher(matcher)
          matcher.allow_nil
        end
      end
    end

    context 'and not validating with allow_nil' do
      it 'rejects since it tries to treat nil as a number' do
        record = build_record_validating_numericality

        assertion = lambda do
          expect(record).to validate_numericality.allow_nil
        end

        message = <<-MESSAGE
Example did not properly validate that :attr looks like a number, but
only if it is not nil.
  In checking that Example allows :attr to be ‹nil›, after setting :attr
  to ‹nil›, the matcher expected the Example to be valid, but it was
  invalid instead, producing these validation errors:

  * attr: ["is not a number"]
        MESSAGE

        expect(&assertion).to fail_with_message(message)
      end
    end
  end

  context 'qualified with only_integer' do
    context 'and validating with only_integer' do
      it 'accepts' do
        record = build_record_validating_numericality(only_integer: true)
        expect(record).to validate_numericality.only_integer
      end

      it_supports(
        'ignoring_interference_by_writer',
        tests: {
          accept_if_qualified_but_changing_value_does_not_interfere: {
            changing_values_with: :next_value,
          },
          reject_if_qualified_but_changing_value_interferes: {
            model_name: 'Example',
            attribute_name: :attr,
            changing_values_with: :numeric_value,
            expected_message: <<-MESSAGE.strip
Example did not properly validate that :attr looks like an integer.
  After setting :attr to ‹"0.1"› -- which was read back as ‹"1"› -- the
  matcher expected the Example to be invalid, but it was valid instead.

  As indicated in the message above, :attr seems to be changing certain
  values as they are set, and this could have something to do with why
  this test is failing. If you've overridden the writer method for this
  attribute, then you may need to change it to make this test pass, or
  do something else entirely.
            MESSAGE
          }
        }
      ) do
        def validation_matcher_scenario_args
          super.deep_merge(validation_options: { only_integer: true })
        end

        def configure_validation_matcher(matcher)
          matcher.only_integer
        end
      end
    end

    context 'and not validating with only_integer' do
      it 'rejects since it does not disallow non-integers' do
        record = build_record_validating_numericality

        assertion = lambda do
          expect(record).to validate_numericality.only_integer
        end

        message = <<-MESSAGE
Example did not properly validate that :attr looks like an integer.
  After setting :attr to ‹"0.1"›, the matcher expected the Example to be
  invalid, but it was valid instead.
        MESSAGE

        expect(&assertion).to fail_with_message(message)
      end
    end
  end

  context 'qualified with odd' do
    context 'and validating with odd' do
      it 'accepts' do
        record = build_record_validating_numericality(odd: true)
        expect(record).to validate_numericality.odd
      end

      it_supports(
        'ignoring_interference_by_writer',
        tests: {
          accept_if_qualified_but_changing_value_does_not_interfere: {
            changing_values_with: :next_next_value,
          },
          reject_if_qualified_but_changing_value_interferes: {
            model_name: 'Example',
            attribute_name: :attr,
            changing_values_with: :next_value,
            expected_message: <<-MESSAGE.strip
Example did not properly validate that :attr looks like an odd number.
  After setting :attr to ‹"2"› -- which was read back as ‹"3"› -- the
  matcher expected the Example to be invalid, but it was valid instead.

  As indicated in the message above, :attr seems to be changing certain
  values as they are set, and this could have something to do with why
  this test is failing. If you've overridden the writer method for this
  attribute, then you may need to change it to make this test pass, or
  do something else entirely.
            MESSAGE
          }
        }
      ) do
        def validation_matcher_scenario_args
          super.deep_merge(validation_options: { odd: true })
        end

        def configure_validation_matcher(matcher)
          matcher.odd
        end
      end

      context 'when the attribute is a virtual attribute in ActiveRecord model' do
        it 'accepts' do
          record = build_record_validating_numericality_of_virtual_attribute(
            odd: true
          )
          expect(record).to validate_numericality.odd
        end
      end

      context 'when the column is an integer column' do
        it 'accepts (and does not raise an error)' do
          record = build_record_validating_numericality(
            column_type: :integer,
            odd: true
          )

          expect(record).to validate_numericality.odd
        end
      end

      context 'when the column is a float column' do
        it 'accepts (and does not raise an error)' do
          record = build_record_validating_numericality(
            column_type: :float,
            odd: true
          )

          expect(record).to validate_numericality.odd
        end
      end

      context 'when the column is a decimal column' do
        it 'accepts (and does not raise an error)' do
          record = build_record_validating_numericality(
            column_type: :decimal,
            odd: true,
          )

          expect(record).to validate_numericality.odd
        end
      end
    end

    context 'and not validating with odd' do
      it 'rejects since it does not disallow even numbers' do
        record = build_record_validating_numericality

        assertion = lambda do
          expect(record).to validate_numericality.odd
        end

        message = <<-MESSAGE
Example did not properly validate that :attr looks like an odd number.
  After setting :attr to ‹"2"›, the matcher expected the Example to be
  invalid, but it was valid instead.
        MESSAGE

        expect(&assertion).to fail_with_message(message)
      end
    end
  end

  context 'qualified with even' do
    context 'and validating with even' do
      it 'accepts' do
        record = build_record_validating_numericality(even: true)
        expect(record).to validate_numericality.even
      end

      it_supports(
        'ignoring_interference_by_writer',
        tests: {
          accept_if_qualified_but_changing_value_does_not_interfere: {
            changing_values_with: :next_next_value,
          },
          reject_if_qualified_but_changing_value_interferes: {
            model_name: 'Example',
            attribute_name: :attr,
            changing_values_with: :next_value,
            expected_message: <<-MESSAGE.strip
Example did not properly validate that :attr looks like an even number.
  After setting :attr to ‹"1"› -- which was read back as ‹"2"› -- the
  matcher expected the Example to be invalid, but it was valid instead.

  As indicated in the message above, :attr seems to be changing certain
  values as they are set, and this could have something to do with why
  this test is failing. If you've overridden the writer method for this
  attribute, then you may need to change it to make this test pass, or
  do something else entirely.
            MESSAGE
          }
        }
      ) do
        def validation_matcher_scenario_args
          super.deep_merge(validation_options: { even: true })
        end

        def configure_validation_matcher(matcher)
          matcher.even
        end
      end

      context 'when the attribute is a virtual attribute in an ActiveRecord model' do
        it 'accepts' do
          record = build_record_validating_numericality_of_virtual_attribute(
            even: true,
          )
          expect(record).to validate_numericality.even
        end
      end

      context 'when the column is an integer column' do
        it 'accepts (and does not raise an error)' do
          record = build_record_validating_numericality(
            column_type: :integer,
            even: true
          )

          expect(record).to validate_numericality.even
        end
      end

      context 'when the column is a float column' do
        it 'accepts (and does not raise an error)' do
          record = build_record_validating_numericality(
            column_type: :float,
            even: true
          )

          expect(record).to validate_numericality.even
        end
      end

      context 'when the column is a decimal column' do
        it 'accepts (and does not raise an error)' do
          record = build_record_validating_numericality(
            column_type: :decimal,
            even: true,
          )

          expect(record).to validate_numericality.even
        end
      end
    end

    context 'and not validating with even' do
      it 'rejects since it does not disallow odd numbers' do
        record = build_record_validating_numericality

        assertion = lambda do
          expect(record).to validate_numericality.even
        end

        message = <<-MESSAGE
Example did not properly validate that :attr looks like an even number.
  After setting :attr to ‹"1"›, the matcher expected the Example to be
  invalid, but it was valid instead.
        MESSAGE

        expect(&assertion).to fail_with_message(message)
      end
    end
  end

  context 'qualified with is_less_than_or_equal_to' do
    context 'and validating with less_than_or_equal_to' do
      it 'accepts' do
        record = build_record_validating_numericality(
          less_than_or_equal_to: 18
        )
        expect(record).to validate_numericality.is_less_than_or_equal_to(18)
      end

      it_supports(
        'ignoring_interference_by_writer',
        tests: {
          reject_if_qualified_but_changing_value_interferes: {
            model_name: 'Example',
            attribute_name: :attr,
            changing_values_with: :next_value,
            expected_message: <<-MESSAGE.strip
Example did not properly validate that :attr looks like a number less
than or equal to 18.
  After setting :attr to ‹"18"› -- which was read back as ‹"19"› -- the
  matcher expected the Example to be valid, but it was invalid instead,
  producing these validation errors:

  * attr: ["must be less than or equal to 18"]

  As indicated in the message above, :attr seems to be changing certain
  values as they are set, and this could have something to do with why
  this test is failing. If you've overridden the writer method for this
  attribute, then you may need to change it to make this test pass, or
  do something else entirely.
            MESSAGE
          }
        }
      ) do
        def validation_matcher_scenario_args
          super.deep_merge(
            validation_options: { less_than_or_equal_to: 18 }
          )
        end

        def configure_validation_matcher(matcher)
          matcher.is_less_than_or_equal_to(18)
        end
      end

      context 'when the attribute is a virtual attribute in an ActiveRecord model' do
        it 'accepts' do
          record = build_record_validating_numericality_of_virtual_attribute(
            less_than_or_equal_to: 18,
          )
          expect(record).to validate_numericality.is_less_than_or_equal_to(18)
        end
      end

      context 'when the column is an integer column' do
        it 'accepts (and does not raise an error)' do
          record = build_record_validating_numericality(
            column_type: :integer,
            less_than_or_equal_to: 18
          )

          expect(record).to validate_numericality.is_less_than_or_equal_to(18)
        end
      end

      context 'when the column is a float column' do
        it 'accepts (and does not raise an error)' do
          record = build_record_validating_numericality(
            column_type: :float,
            less_than_or_equal_to: 18
          )

          expect(record).to validate_numericality.is_less_than_or_equal_to(18)
        end
      end

      context 'when the column is a decimal column' do
        it 'accepts (and does not raise an error)' do
          record = build_record_validating_numericality(
            column_type: :decimal,
            less_than_or_equal_to: 18,
          )

          expect(record).to validate_numericality.is_less_than_or_equal_to(18)
        end
      end
    end

    context 'and not validating with less_than_or_equal_to' do
      it 'rejects since it does not disallow numbers greater than the value' do
        record = build_record_validating_numericality

        assertion = lambda do
          expect(record).to validate_numericality.is_less_than_or_equal_to(18)
        end

        message = <<-MESSAGE
Example did not properly validate that :attr looks like a number less
than or equal to 18.
  After setting :attr to ‹"19"›, the matcher expected the Example to be
  invalid, but it was valid instead.
        MESSAGE

        expect(&assertion).to fail_with_message(message)
      end
    end
  end

  context 'qualified with is_less_than' do
    context 'and validating with less_than' do
      it 'accepts' do
        record = build_record_validating_numericality(less_than: 18)
        expect(record).
          to validate_numericality.
          is_less_than(18)
      end

      it_supports(
        'ignoring_interference_by_writer',
        tests: {
          reject_if_qualified_but_changing_value_interferes: {
            model_name: 'Example',
            attribute_name: :attr,
            changing_values_with: :next_value,
            expected_message: <<-MESSAGE.strip
Example did not properly validate that :attr looks like a number less
than 18.
  After setting :attr to ‹"17"› -- which was read back as ‹"18"› -- the
  matcher expected the Example to be valid, but it was invalid instead,
  producing these validation errors:

  * attr: ["must be less than 18"]

  As indicated in the message above, :attr seems to be changing certain
  values as they are set, and this could have something to do with why
  this test is failing. If you've overridden the writer method for this
  attribute, then you may need to change it to make this test pass, or
  do something else entirely.
            MESSAGE
          }
        }
      ) do
        def validation_matcher_scenario_args
          super.deep_merge(validation_options: { less_than: 18 })
        end

        def configure_validation_matcher(matcher)
          matcher.is_less_than(18)
        end
      end

      context 'when the attribute is a virtual attribute in an ActiveRecord model' do
        it 'accepts' do
          record = build_record_validating_numericality_of_virtual_attribute(
            less_than: 18,
          )
          expect(record).to validate_numericality.is_less_than(18)
        end
      end

      context 'when the column is an integer column' do
        it 'accepts (and does not raise an error)' do
          record = build_record_validating_numericality(
            column_type: :integer,
            less_than: 18
          )

          expect(record).to validate_numericality.is_less_than(18)
        end
      end

      context 'when the column is a float column' do
        it 'accepts (and does not raise an error)' do
          record = build_record_validating_numericality(
            column_type: :float,
            less_than: 18
          )

          expect(record).to validate_numericality.is_less_than(18)
        end
      end

      context 'when the column is a decimal column' do
        it 'accepts (and does not raise an error)' do
          record = build_record_validating_numericality(
            column_type: :decimal,
            less_than: 18,
          )

          expect(record).to validate_numericality.is_less_than(18)
        end
      end
    end

    context 'and not validating with less_than' do
      it 'rejects since it does not disallow numbers greater than or equal to the value' do
        record = build_record_validating_numericality

        assertion = lambda do
          expect(record).to validate_numericality.is_less_than(18)
        end

        message = <<-MESSAGE
Example did not properly validate that :attr looks like a number less
than 18.
  After setting :attr to ‹"19"›, the matcher expected the Example to be
  invalid, but it was valid instead.
        MESSAGE

        expect(&assertion).to fail_with_message(message)
      end
    end
  end

  context 'qualified with is_equal_to' do
    context 'and validating with equal_to' do
      it 'accepts' do
        record = build_record_validating_numericality(equal_to: 18)
        expect(record).to validate_numericality.is_equal_to(18)
      end

      it_supports(
        'ignoring_interference_by_writer',
        tests: {
          reject_if_qualified_but_changing_value_interferes: {
            model_name: 'Example',
            attribute_name: :attr,
            changing_values_with: :next_value,
            expected_message: <<-MESSAGE.strip
Example did not properly validate that :attr looks like a number equal
to 18.
  After setting :attr to ‹"18"› -- which was read back as ‹"19"› -- the
  matcher expected the Example to be valid, but it was invalid instead,
  producing these validation errors:

  * attr: ["must be equal to 18"]

  As indicated in the message above, :attr seems to be changing certain
  values as they are set, and this could have something to do with why
  this test is failing. If you've overridden the writer method for this
  attribute, then you may need to change it to make this test pass, or
  do something else entirely.
            MESSAGE
          }
        }
      ) do
        def validation_matcher_scenario_args
          super.deep_merge(validation_options: { equal_to: 18 })
        end

        def configure_validation_matcher(matcher)
          matcher.is_equal_to(18)
        end
      end

      context 'when the attribute is a virtual attribute in an ActiveRecord model' do
        it 'accepts' do
          record = build_record_validating_numericality_of_virtual_attribute(
            equal_to: 18,
          )
          expect(record).to validate_numericality.is_equal_to(18)
        end
      end

      context 'when the column is an integer column' do
        it 'accepts (and does not raise an error)' do
          record = build_record_validating_numericality(
            column_type: :integer,
            equal_to: 18
          )

          expect(record).to validate_numericality.is_equal_to(18)
        end
      end

      context 'when the column is a float column' do
        it 'accepts (and does not raise an error)' do
          record = build_record_validating_numericality(
            column_type: :float,
            equal_to: 18
          )

          expect(record).to validate_numericality.is_equal_to(18)
        end
      end

      context 'when the column is a decimal column' do
        it 'accepts (and does not raise an error)' do
          record = build_record_validating_numericality(
            column_type: :decimal,
            equal_to: 18,
          )

          expect(record).to validate_numericality.is_equal_to(18)
        end
      end
    end

    context 'and not validating with equal_to' do
      it 'rejects since it does not disallow numbers that are not the value' do
        record = build_record_validating_numericality

        assertion = lambda do
          expect(record).to validate_numericality.is_equal_to(18)
        end

        message = <<-MESSAGE
Example did not properly validate that :attr looks like a number equal
to 18.
  After setting :attr to ‹"19"›, the matcher expected the Example to be
  invalid, but it was valid instead.
        MESSAGE

        expect(&assertion).to fail_with_message(message)
      end
    end
  end

  context 'qualified with is_greater_than_or_equal to' do
    context 'validating with greater_than_or_equal_to' do
      it 'accepts' do
        record = build_record_validating_numericality(
          greater_than_or_equal_to: 18
        )
        expect(record).
          to validate_numericality.
          is_greater_than_or_equal_to(18)
      end

      it_supports(
        'ignoring_interference_by_writer',
        tests: {
          reject_if_qualified_but_changing_value_interferes: {
            model_name: 'Example',
            attribute_name: :attr,
            changing_values_with: :next_value,
            expected_message: <<-MESSAGE.strip
Example did not properly validate that :attr looks like a number greater
than or equal to 18.
  After setting :attr to ‹"17"› -- which was read back as ‹"18"› -- the
  matcher expected the Example to be invalid, but it was valid instead.

  As indicated in the message above, :attr seems to be changing certain
  values as they are set, and this could have something to do with why
  this test is failing. If you've overridden the writer method for this
  attribute, then you may need to change it to make this test pass, or
  do something else entirely.
            MESSAGE
          }
        }
      ) do
        def validation_matcher_scenario_args
          super.deep_merge(
            validation_options: { greater_than_or_equal_to: 18 }
          )
        end

        def configure_validation_matcher(matcher)
          matcher.is_greater_than_or_equal_to(18)
        end
      end

      context 'when the attribute is a virtual attribute in an ActiveRecord model' do
        it 'accepts' do
          record = build_record_validating_numericality_of_virtual_attribute(
            greater_than_or_equal_to: 18,
          )
          expect(record).to validate_numericality.
            is_greater_than_or_equal_to(18)
        end
      end

      context 'when the column is an integer column' do
        it 'accepts (and does not raise an error)' do
          record = build_record_validating_numericality(
            column_type: :integer,
            greater_than_or_equal_to: 18
          )

          expect(record).
            to validate_numericality.
            is_greater_than_or_equal_to(18)
        end
      end

      context 'when the column is a float column' do
        it 'accepts (and does not raise an error)' do
          record = build_record_validating_numericality(
            column_type: :float,
            greater_than_or_equal_to: 18
          )

          expect(record).
            to validate_numericality.
            is_greater_than_or_equal_to(18)
        end
      end

      context 'when the column is a decimal column' do
        it 'accepts (and does not raise an error)' do
          record = build_record_validating_numericality(
            column_type: :decimal,
            greater_than_or_equal_to: 18,
          )

          expect(record).
            to validate_numericality.
            is_greater_than_or_equal_to(18)
        end
      end
    end

    context 'not validating with greater_than_or_equal_to' do
      it 'rejects since it does not disallow numbers that are less than the value' do
        record = build_record_validating_numericality

        assertion = lambda do
          expect(record).to validate_numericality.
            is_greater_than_or_equal_to(18)
        end

        message = <<-MESSAGE
Example did not properly validate that :attr looks like a number greater
than or equal to 18.
  After setting :attr to ‹"17"›, the matcher expected the Example to be
  invalid, but it was valid instead.
        MESSAGE

        expect(&assertion).to fail_with_message(message)
      end
    end
  end

  context 'qualified with is_greater_than' do
    context 'and validating with greater_than' do
      it 'accepts' do
        record = build_record_validating_numericality(greater_than: 18)
        expect(record).
          to validate_numericality.
          is_greater_than(18)
      end

      it_supports(
        'ignoring_interference_by_writer',
        tests: {
          reject_if_qualified_but_changing_value_interferes: {
            model_name: 'Example',
            attribute_name: :attr,
            changing_values_with: :next_value,
            expected_message: <<-MESSAGE.strip
Example did not properly validate that :attr looks like a number greater
than 18.
  After setting :attr to ‹"18"› -- which was read back as ‹"19"› -- the
  matcher expected the Example to be invalid, but it was valid instead.

  As indicated in the message above, :attr seems to be changing certain
  values as they are set, and this could have something to do with why
  this test is failing. If you've overridden the writer method for this
  attribute, then you may need to change it to make this test pass, or
  do something else entirely.
            MESSAGE
          }
        }
      ) do
        def validation_matcher_scenario_args
          super.deep_merge(validation_options: { greater_than: 18 })
        end

        def configure_validation_matcher(matcher)
          matcher.is_greater_than(18)
        end
      end

      context 'when the attribute is a virtual attribute in an ActiveRecord model' do
        it 'accepts' do
          record = build_record_validating_numericality_of_virtual_attribute(
            greater_than: 18,
          )
          expect(record).to validate_numericality.is_greater_than(18)
        end
      end

      context 'when the column is an integer column' do
        it 'accepts (and does not raise an error)' do
          record = build_record_validating_numericality(
            column_type: :integer,
            greater_than: 18
          )

          expect(record).
            to validate_numericality.
            is_greater_than(18)
        end
      end

      context 'when the column is a float column' do
        it 'accepts (and does not raise an error)' do
          record = build_record_validating_numericality(
            column_type: :float,
            greater_than: 18
          )

          expect(record).
            to validate_numericality.
            is_greater_than(18)
        end
      end

      context 'when the column is a decimal column' do
        it 'accepts (and does not raise an error)' do
          record = build_record_validating_numericality(
            column_type: :decimal,
            greater_than: 18,
          )

          expect(record).
            to validate_numericality.
            is_greater_than(18)
        end
      end
    end

    context 'and not validating with greater_than' do
      it 'rejects since it does not disallow numbers that are less than or equal to the value' do
        record = build_record_validating_numericality

        assertion = lambda do
          expect(record).to validate_numericality.is_greater_than(18)
        end

        message = <<-MESSAGE
Example did not properly validate that :attr looks like a number greater
than 18.
  After setting :attr to ‹"18"›, the matcher expected the Example to be
  invalid, but it was valid instead.
        MESSAGE

        expect(&assertion).to fail_with_message(message)
      end
    end
  end

  context 'qualified with with_message' do
    context 'and validating with the same message' do
      it 'accepts' do
        record = build_record_validating_numericality(message: 'custom')
        expect(record).to validate_numericality.with_message(/custom/)
      end
    end

    context 'and validating with a different message' do
      it 'rejects with the correct failure message' do
        record = build_record_validating_numericality(message: 'custom')

        assertion = lambda do
          expect(record).to validate_numericality.with_message(/wrong/)
        end

        message = <<-MESSAGE
Example did not properly validate that :attr looks like a number,
producing a custom validation error on failure.
  After setting :attr to ‹"abcd"›, the matcher expected the Example to
  be invalid and to produce a validation error matching ‹/wrong/› on
  :attr. The record was indeed invalid, but it produced these validation
  errors instead:

  * attr: ["custom"]
        MESSAGE

        expect(&assertion).to fail_with_message(message)
      end
    end

    context 'and no message is provided' do
      it 'ignores the qualifier' do
        record = build_record_validating_numericality
        expect(record).to validate_numericality.with_message(nil)
      end
    end

    context 'and the validation is missing from the model' do
      it 'rejects with the correct failure message' do
        model = define_model_validating_nothing

        assertion = lambda do
          expect(model.new).to validate_numericality.with_message(/wrong/)
        end

        message = <<-MESSAGE
Example did not properly validate that :attr looks like a number,
producing a custom validation error on failure.
  After setting :attr to ‹"abcd"›, the matcher expected the Example to
  be invalid, but it was valid instead.
        MESSAGE

        expect(&assertion).to fail_with_message(message)
      end
    end
  end

  context 'qualified with strict' do
    context 'and validating strictly' do
      it 'accepts' do
        record = build_record_validating_numericality(strict: true)
        expect(record).to validate_numericality.strict
      end
    end

    context 'and not validating strictly' do
      it 'rejects since ActiveModel::StrictValidationFailed is never raised' do
        record = build_record_validating_numericality(attribute_name: :attr)

        assertion = lambda do
          expect(record).to validate_numericality_of(:attr).strict
        end

        message = <<-MESSAGE
Example did not properly validate that :attr looks like a number,
raising a validation exception on failure.
  After setting :attr to ‹"abcd"›, the matcher expected the Example to
  be invalid and to raise a validation exception, but the record
  produced validation errors instead.
        MESSAGE

        expect(&assertion).to fail_with_message(message)
      end
    end
  end

  context 'qualified with on and validating with on' do
    it 'accepts' do
      record = build_record_validating_numericality(on: :customizable)
      expect(record).to validate_numericality.on(:customizable)
    end
  end

  context 'qualified with on but not validating with on' do
    it 'accepts since the validation never considers a context' do
      record = build_record_validating_numericality
      expect(record).to validate_numericality.on(:customizable)
    end
  end

  context 'not qualified with on but validating with on' do
    it 'rejects since the validation never runs' do
      record = build_record_validating_numericality(on: :customizable)

      assertion = lambda do
        expect(record).to validate_numericality
      end

      message = <<-MESSAGE
Example did not properly validate that :attr looks like a number.
  After setting :attr to ‹"abcd"›, the matcher expected the Example to
  be invalid, but it was valid instead.
      MESSAGE

      expect(&assertion).to fail_with_message(message)
    end
  end

  context 'with combinations of qualifiers together' do
    all_qualifier_combinations.each do |combination|
      if combination.size > 1
        it do
          validation_options = build_validation_options(for: combination)
          record = build_record_validating_numericality(validation_options)
          validate_numericality = self.validate_numericality
          apply_qualifiers!(for: combination, to: validate_numericality)
          expect(record).to validate_numericality
        end
      end
    end

    context 'when the qualifiers do not match the validation options' do
      specify 'such as validating even but testing that only_integer is validated' do
        record = build_record_validating_numericality(
          even: true,
          greater_than: 18
        )

        assertion = lambda do
          expect(record).
            to validate_numericality.
            only_integer.
            is_greater_than(18)
        end

        message = <<-MESSAGE
Example did not properly validate that :attr looks like an integer
greater than 18.
  In checking that Example disallows :attr from being a decimal number,
  after setting :attr to ‹"0.1"›, the matcher expected the Example to be
  invalid and to produce the validation error "must be an integer" on
  :attr. The record was indeed invalid, but it produced these validation
  errors instead:

  * attr: ["must be greater than 18"]
        MESSAGE

        expect(&assertion).to fail_with_message(message)
      end

      specify 'such as not validating only_integer but testing that only_integer is validated' do
        record = build_record_validating_numericality(greater_than: 18)

        assertion = lambda do
          expect(record).
            to validate_numericality.
            only_integer.
            is_greater_than(18)
        end

        message = <<-MESSAGE.strip_heredoc
Example did not properly validate that :attr looks like an integer
greater than 18.
  In checking that Example disallows :attr from being a decimal number,
  after setting :attr to ‹"0.1"›, the matcher expected the Example to be
  invalid and to produce the validation error "must be an integer" on
  :attr. The record was indeed invalid, but it produced these validation
  errors instead:

  * attr: ["must be greater than 18"]
        MESSAGE

        expect(&assertion).to fail_with_message(message)
      end

      specify 'such as validating greater_than_or_equal_to (+ even) but testing that greater_than is validated' do
        record = build_record_validating_numericality(
          even: true,
          greater_than_or_equal_to: 18
        )

        assertion = lambda do
          expect(record).
            to validate_numericality.
            even.
            is_greater_than(18)
        end

        message = <<-MESSAGE
Example did not properly validate that :attr looks like an even number
greater than 18.
  In checking that Example disallows :attr from being a number that is
  not greater than 18, after setting :attr to ‹"18"›, the matcher
  expected the Example to be invalid, but it was valid instead.
        MESSAGE

        expect(&assertion).to fail_with_message(message)
      end

      specify 'such as validating odd (+ greater_than) but testing that even is validated' do
        record = build_record_validating_numericality(
          odd: true,
          greater_than: 18
        )

        assertion = lambda do
          expect(record).
            to validate_numericality.
            even.
            is_greater_than(18)
        end

        message = <<-MESSAGE
Example did not properly validate that :attr looks like an even number
greater than 18.
  In checking that Example disallows :attr from being an odd number,
  after setting :attr to ‹"1"›, the matcher expected the Example to be
  invalid and to produce the validation error "must be even" on :attr.
  The record was indeed invalid, but it produced these validation errors
  instead:

  * attr: ["must be greater than 18"]
        MESSAGE

        expect(&assertion).to fail_with_message(message)
      end

      specify 'such as validating greater_than_or_equal_to (+ odd) but testing that is_less_than_or_equal_to is validated' do
        record = build_record_validating_numericality(
          odd: true,
          greater_than_or_equal_to: 99
        )

        assertion = lambda do
          expect(record).
            to validate_numericality.
            odd.
            is_less_than_or_equal_to(99)
        end

        message = <<-MESSAGE
Example did not properly validate that :attr looks like an odd number
less than or equal to 99.
  In checking that Example disallows :attr from being a number that is
  not less than or equal to 99, after setting :attr to ‹"101"›, the
  matcher expected the Example to be invalid, but it was valid instead.
        MESSAGE

        expect(&assertion).to fail_with_message(message)
      end

      specify 'such as validating greater_than_or_equal_to (+ only_integer + less_than) but testing that greater_than is validated' do
        record = build_record_validating_numericality(
          only_integer: true,
          greater_than_or_equal_to: 18,
          less_than: 99
        )

        assertion = lambda do
          expect(record).
            to validate_numericality.
            only_integer.
            is_greater_than(18).
            is_less_than(99)
        end

        message = <<-MESSAGE
Example did not properly validate that :attr looks like an integer
greater than 18 and less than 99.
  In checking that Example disallows :attr from being a number that is
  not greater than 18, after setting :attr to ‹"18"›, the matcher
  expected the Example to be invalid, but it was valid instead.
        MESSAGE

        expect(&assertion).to fail_with_message(message)
      end
    end

    context 'when qualifiers match the validation options but the values are different' do
      specify 'such as testing greater_than (+ only_integer) with lower value' do
        record = build_record_validating_numericality(
          only_integer: true,
          greater_than: 19
        )

        assertion = lambda do
          expect(record).
            to validate_numericality.
            only_integer.
            is_greater_than(18)
        end

        # why is value "19" here?
        message = <<-MESSAGE
Example did not properly validate that :attr looks like an integer
greater than 18.
  In checking that Example disallows :attr from being a number that is
  not greater than 18, after setting :attr to ‹"18"›, the matcher
  expected the Example to be invalid and to produce the validation error
  "must be greater than 18" on :attr. The record was indeed invalid, but
  it produced these validation errors instead:

  * attr: ["must be greater than 19"]
        MESSAGE

        expect(&assertion).to fail_with_message(message)
      end

      specify 'such as testing greater_than (+ only_integer) with higher value' do
        record = build_record_validating_numericality(
          only_integer: true,
          greater_than: 17
        )

        assertion = lambda do
          expect(record).
            to validate_numericality.
            only_integer.
            is_greater_than(18)
        end

        message = <<-MESSAGE
Example did not properly validate that :attr looks like an integer
greater than 18.
  In checking that Example disallows :attr from being a number that is
  not greater than 18, after setting :attr to ‹"18"›, the matcher
  expected the Example to be invalid, but it was valid instead.
        MESSAGE

        expect(&assertion).to fail_with_message(message)
      end

      specify 'such as testing greater_than (+ even) with lower value' do
        record = build_record_validating_numericality(
          even: true,
          greater_than: 20
        )

        assertion = lambda do
          expect(record).
            to validate_numericality.
            even.
            is_greater_than(18)
        end

         # why is value "20" here?
        message = <<-MESSAGE
Example did not properly validate that :attr looks like an even number
greater than 18.
  In checking that Example disallows :attr from being a number that is
  not greater than 18, after setting :attr to ‹"18"›, the matcher
  expected the Example to be invalid and to produce the validation error
  "must be greater than 18" on :attr. The record was indeed invalid, but
  it produced these validation errors instead:

  * attr: ["must be greater than 20"]
        MESSAGE

        expect(&assertion).to fail_with_message(message)
      end

      specify 'such as testing greater than (+ even) with higher value' do
        record = build_record_validating_numericality(
          even: true,
          greater_than: 16
        )

        assertion = lambda do
          expect(record).
            to validate_numericality.
            even.
            is_greater_than(18)
        end

        message = <<-MESSAGE
Example did not properly validate that :attr looks like an even number
greater than 18.
  In checking that Example disallows :attr from being a number that is
  not greater than 18, after setting :attr to ‹"18"›, the matcher
  expected the Example to be invalid, but it was valid instead.
        MESSAGE

        expect(&assertion).to fail_with_message(message)
      end

      specify 'such as testing less_than_or_equal_to (+ odd) with lower value' do
        record = build_record_validating_numericality(
          odd: true,
          less_than_or_equal_to: 101
        )

        assertion = lambda do
          expect(record).
            to validate_numericality.
            odd.
            is_less_than_or_equal_to(99)
        end

        message = <<-MESSAGE
Example did not properly validate that :attr looks like an odd number
less than or equal to 99.
  In checking that Example disallows :attr from being a number that is
  not less than or equal to 99, after setting :attr to ‹"101"›, the
  matcher expected the Example to be invalid, but it was valid instead.
        MESSAGE

        expect(&assertion).to fail_with_message(message)
      end

      specify 'such as testing less_than_or_equal_to (+ odd) with higher value' do
        record = build_record_validating_numericality(
          odd: true,
          less_than_or_equal_to: 97
        )

        assertion = lambda do
          expect(record).
            to validate_numericality.
            odd.
            is_less_than_or_equal_to(99)
        end

        message = <<-MESSAGE
Example did not properly validate that :attr looks like an odd number
less than or equal to 99.
  In checking that Example disallows :attr from being a number that is
  not less than or equal to 99, after setting :attr to ‹"101"›, the
  matcher expected the Example to be invalid and to produce the
  validation error "must be less than or equal to 99" on :attr. The
  record was indeed invalid, but it produced these validation errors
  instead:

  * attr: ["must be less than or equal to 97"]
        MESSAGE

        expect(&assertion).to fail_with_message(message)
      end

      specify 'such as testing greater_than (+ only_integer + less_than) with lower value' do
        record = build_record_validating_numericality(
          only_integer: true,
          greater_than: 19,
          less_than: 99
        )

        assertion = lambda do
          expect(record).
            to validate_numericality.
            only_integer.
            is_greater_than(18).
            is_less_than(99)
        end

        # why is value "19" here?
        message = <<-MESSAGE
Example did not properly validate that :attr looks like an integer
greater than 18 and less than 99.
  In checking that Example disallows :attr from being a number that is
  not greater than 18, after setting :attr to ‹"18"›, the matcher
  expected the Example to be invalid and to produce the validation error
  "must be greater than 18" on :attr. The record was indeed invalid, but
  it produced these validation errors instead:

  * attr: ["must be greater than 19"]
        MESSAGE

        expect(&assertion).to fail_with_message(message)
      end

      specify 'such as testing less_than (+ only_integer + greater_than) with higher value' do
        record = build_record_validating_numericality(
          only_integer: true,
          greater_than: 18,
          less_than: 100
        )

        assertion = lambda do
          expect(record).
            to validate_numericality.
            only_integer.
            is_greater_than(18).
            is_less_than(99)
        end

        message = <<-MESSAGE
Example did not properly validate that :attr looks like an integer
greater than 18 and less than 99.
  In checking that Example disallows :attr from being a number that is
  not less than 99, after setting :attr to ‹"100"›, the matcher expected
  the Example to be invalid and to produce the validation error "must be
  less than 99" on :attr. The record was indeed invalid, but it produced
  these validation errors instead:

  * attr: ["must be less than 100"]
        MESSAGE

        expect(&assertion).to fail_with_message(message)
      end
    end
  end

  context 'with large numbers' do
    it do
      record = build_record_validating_numericality(greater_than: 100_000)
      expect(record).to validate_numericality.is_greater_than(100_000)
    end

    it do
      record = build_record_validating_numericality(less_than: 100_000)
      expect(record).to validate_numericality.is_less_than(100_000)
    end

    it do
      record = build_record_validating_numericality(
        greater_than_or_equal_to: 100_000
      )
      expect(record).
        to validate_numericality.
        is_greater_than_or_equal_to(100_000)
    end

    it do
      record = build_record_validating_numericality(
        less_than_or_equal_to: 100_000
      )
      expect(record).
        to validate_numericality.
        is_less_than_or_equal_to(100_000)
    end
  end

  context 'when the subject is stubbed' do
    it 'retains that stub while the validate_numericality is matching' do
      model = define_model :example, attr: :string do
        validates_numericality_of :attr, odd: true
        before_validation :set_attr!
        def set_attr!; self.attr = 5 end
      end

      record = model.new
      allow(record).to receive(:set_attr!)

      expect(record).to validate_numericality_of(:attr).odd
    end
  end

  context 'against an ActiveModel model' do
    it 'accepts' do
      model = define_active_model_class :example, accessors: [:attr] do
        validates_numericality_of :attr
      end

      expect(model.new).to validate_numericality_of(:attr)
    end

    it_supports(
      'ignoring_interference_by_writer',
      tests: {
        accept_if_qualified_but_changing_value_does_not_interfere: {
          changing_values_with: :next_value,
        },
        reject_if_qualified_but_changing_value_interferes: {
          model_name: 'Example',
          attribute_name: :attr,
          changing_values_with: :numeric_value,
          expected_message: <<-MESSAGE.strip
Example did not properly validate that :attr looks like a number.
  After setting :attr to ‹"abcd"› -- which was read back as ‹"1"› -- the
  matcher expected the Example to be invalid, but it was valid instead.

  As indicated in the message above, :attr seems to be changing certain
  values as they are set, and this could have something to do with why
  this test is failing. If you've overridden the writer method for this
  attribute, then you may need to change it to make this test pass, or
  do something else entirely.
          MESSAGE
        }
      }
    )

    def validation_matcher_scenario_args
      super.deep_merge(model_creator: :active_model)
    end
  end

  describe '#description' do
    context 'qualified with nothing' do
      it 'describes that it allows numbers' do
        matcher = validate_numericality_of(:attr)
        expect(matcher.description).to eq(
          'validate that :attr looks like a number'
        )
      end
    end

    context 'qualified with only_integer' do
      it 'describes that it allows integers' do
        matcher = validate_numericality_of(:attr).only_integer
        expect(matcher.description).to eq(
          'validate that :attr looks like an integer'
        )
      end
    end

    qualifiers_under(:cardinality).each do |qualifier|
      context "qualified with #{qualifier[:name]}" do
        it "describes that it allows #{qualifier[:name]} numbers" do
          matcher = validate_numericality_of(:attr).__send__(qualifier[:name])
          expect(matcher.description).to eq(
            "validate that :attr looks like an #{qualifier[:name]} number"
          )
        end
      end
    end

    qualifiers_under(:comparison).each do |qualifier|
      comparison_phrase = qualifier[:validation_name].to_s.gsub('_', ' ')

      context "qualified with #{qualifier[:name]}" do
        it "describes that it allows numbers #{comparison_phrase} a certain value" do
          matcher = validate_numericality_of(:attr).
            __send__(qualifier[:name], 18)

          expect(matcher.description).to eq(
            "validate that :attr looks like a number #{comparison_phrase} 18"
          )
        end
      end
    end

    context 'qualified with odd + is_greater_than_or_equal_to' do
      it "describes that it allows odd numbers greater than or equal to a certain value" do
        matcher = validate_numericality_of(:attr).
          odd.
          is_greater_than_or_equal_to(18)

        expect(matcher.description).to eq(
          'validate that :attr looks like an odd number greater than or equal to 18'
        )
      end
    end

    context 'qualified with only integer + is_greater_than + less_than_or_equal_to' do
      it 'describes that it allows integer greater than one value and less than or equal to another' do
        matcher = validate_numericality_of(:attr).
          only_integer.
          is_greater_than(18).
          is_less_than_or_equal_to(100)

        expect(matcher.description).to eq(
          'validate that :attr looks like an integer greater than 18 and less than or equal to 100'
        )
      end
    end

    context 'qualified with strict' do
      it 'describes that it relies upon a strict validation' do
        matcher = validate_numericality_of(:attr).strict
        expect(matcher.description).to eq(
          'validate that :attr looks like a number, raising a validation exception on failure'
        )
      end

      context 'and qualified with a comparison qualifier' do
        it 'places the comparison description after "strictly"' do
          matcher = validate_numericality_of(:attr).is_less_than(18).strict
          expect(matcher.description).to eq(
            'validate that :attr looks like a number less than 18, raising a validation exception on failure'
          )
        end
      end
    end
  end

  def build_validation_options(args)
    combination = args.fetch(:for)

    combination.each_with_object({}) do |qualifier, hash|
      value = self.class.default_validation_values.fetch(qualifier[:validation_name])
      hash[qualifier[:validation_name]] = value
    end
  end

  def apply_qualifiers!(args)
    combination = args.fetch(:for)
    matcher = args.fetch(:to)

    combination.each do |qualifier|
      args = self.class.default_qualifier_arguments.fetch(qualifier[:name])
      matcher.__send__(qualifier[:name], *args)
    end
  end

  def define_model_validating_numericality(options = {})
    attribute_name = options.delete(:attribute_name) { self.attribute_name }
    column_type = options.delete(:column_type) { :string }

    define_model 'Example', attribute_name => { type: column_type } do |model|
      model.validates_numericality_of(attribute_name, options)
    end
  end

  def define_model_validating_numericality_of_virtual_attribute(options = {})
    attribute_name = options.delete(:attribute_name) { self.attribute_name }

    define_model 'Example' do |model|
      model.send(:attr_accessor, attribute_name)
      model.validates_numericality_of(attribute_name, options)
    end
  end

  def build_record_validating_numericality_of_virtual_attribute(options = {})
    define_model_validating_numericality_of_virtual_attribute(options).new
  end

  def build_record_validating_numericality(options = {})
    define_model_validating_numericality(options).new
  end

  def define_model_validating_nothing
    define_model('Example', attribute_name => :string)
  end

  def build_record_validating_nothing
    define_model_validating_nothing.new
  end

  def validate_numericality
    validate_numericality_of(attribute_name)
  end

  def attribute_name
    :attr
  end

  def validation_matcher_scenario_args
    super.deep_merge(
      matcher_name: :validate_numericality_of,
      model_creator: :active_record
    )
  end
end
