require 'unit_spec_helper'

describe Shoulda::Matchers::ActiveModel::ValidateComparisonOfMatcher, type: :model do
  if rails_version >= 7.0
    context 'with combinations of qualifiers together' do
      context 'when the qualifiers do not match the validation options' do
        specify 'such as validating greater_than_or_equal_to but testing that greater_than is validated' do
          record = build_record_validating_comparison(column_type: :integer, greater_than_or_equal_to: 18)
          assertion = lambda { expect(record).to validate_comparison.is_greater_than(18) }

          message = <<-MESSAGE
Expected Example to validate that :attr looks like a value greater than
18, but this could not be proved.
  After setting :attr to ‹18›, the matcher expected the Example to be
  invalid, but it was valid instead.
          MESSAGE

          expect(&assertion).to fail_with_message(message)
        end

        specify 'such as validating greater_than_or_equal_to but testing that is_less_than_or_equal_to is validated' do
          record = build_record_validating_comparison(column_type: :integer, greater_than_or_equal_to: 18)
          assertion = lambda { expect(record).to validate_comparison.is_less_than_or_equal_to(18) }

          message = <<-MESSAGE
Expected Example to validate that :attr looks like a value less than or
equal to 18, but this could not be proved.
  After setting :attr to ‹19›, the matcher expected the Example to be
  invalid, but it was valid instead.
          MESSAGE

          expect(&assertion).to fail_with_message(message)
        end
      end

      context 'when qualifiers match the validation options but the values are different' do
        specify 'such as testing greater_than with lower value' do
          record = build_record_validating_comparison(column_type: :integer, greater_than: 19)

          assertion = lambda { expect(record).to validate_comparison.is_greater_than(18) }

          message = <<-MESSAGE
Expected Example to validate that :attr looks like a value greater than
18, but this could not be proved.
  After setting :attr to ‹18›, the matcher expected the Example to be
  invalid and to produce the validation error "must be greater than 18"
  on :attr. The record was indeed invalid, but it produced these
  validation errors instead:

  * attr: ["must be greater than 19"]
          MESSAGE

          expect(&assertion).to fail_with_message(message)
        end

        specify 'such as testing greater_than with higher value' do
          record = build_record_validating_comparison(column_type: :integer, greater_than: 18)

          assertion = lambda { expect(record).to validate_comparison.is_greater_than(19) }

          message = <<-MESSAGE
Expected Example to validate that :attr looks like a value greater than
19, but this could not be proved.
  After setting :attr to ‹19›, the matcher expected the Example to be
  invalid, but it was valid instead.
          MESSAGE

          expect(&assertion).to fail_with_message(message)
        end

        specify 'such as testing less_than_or_equal_to with lower value' do
          record = build_record_validating_comparison(column_type: :integer, less_than_or_equal_to: 18)

          assertion = lambda do
            expect(record).
              to validate_comparison.
              is_less_than_or_equal_to(17)
          end

          message = <<-MESSAGE
Expected Example to validate that :attr looks like a value less than or
equal to 17, but this could not be proved.
  After setting :attr to ‹18›, the matcher expected the Example to be
  invalid, but it was valid instead.
          MESSAGE

          expect(&assertion).to fail_with_message(message)
        end

        specify 'such as testing less_than_or_equal_to with higher value' do
          record = build_record_validating_comparison(
            column_type: :integer,
            less_than_or_equal_to: 18,
          )

          assertion = lambda { expect(record).to validate_comparison.is_less_than_or_equal_to(19) }

          message = <<-MESSAGE
Expected Example to validate that :attr looks like a value less than or
equal to 19, but this could not be proved.
  After setting :attr to ‹20›, the matcher expected the Example to be
  invalid and to produce the validation error "must be less than or
  equal to 19" on :attr. The record was indeed invalid, but it produced
  these validation errors instead:

  * attr: ["must be less than or equal to 18"]
          MESSAGE

          expect(&assertion).to fail_with_message(message)
        end

        specify 'such as testing greater_than (+ less_than) with lower value' do
          record = build_record_validating_comparison(
            column_type: :integer,
            greater_than: 19,
            less_than: 99,
          )

          assertion = lambda { expect(record).to validate_comparison.is_greater_than(18).is_less_than(99) }

          message = <<-MESSAGE
Expected Example to validate that :attr looks like a value greater than
18 and less than 99, but this could not be proved.
  After setting :attr to ‹18›, the matcher expected the Example to be
  invalid and to produce the validation error "must be greater than 18"
  on :attr. The record was indeed invalid, but it produced these
  validation errors instead:

  * attr: ["must be greater than 19"]
          MESSAGE

          expect(&assertion).to fail_with_message(message)
        end

        specify 'such as testing less_than (+ only_integer + greater_than) with higher value' do
          record = build_record_validating_comparison(
            column_type: :integer,
            greater_than: 18,
            less_than: 100,
          )

          assertion = lambda { expect(record).to validate_comparison.is_greater_than(18).is_less_than(99) }

          message = <<-MESSAGE
Expected Example to validate that :attr looks like a value greater than
18 and less than 99, but this could not be proved.
  After setting :attr to ‹100›, the matcher expected the Example to be
  invalid and to produce the validation error "must be less than 99" on
  :attr. The record was indeed invalid, but it produced these validation
  errors instead:

  * attr: ["must be less than 100"]
          MESSAGE

          expect(&assertion).to fail_with_message(message)
        end
      end
    end

    context 'when comparing with an integer' do
      context 'qualified with is_other_than' do
        context 'and validating with other_than' do
          it 'accepts' do
            record = build_record_validating_comparison(column_type: :integer, other_than: 10)

            expect(record).to validate_comparison_of(:attr).is_other_than(10)
          end

          it 'rejects when used in the negative' do
            record = build_record_validating_comparison(column_type: :integer, other_than: 10)

            assertion = lambda do
              expect(record).not_to validate_comparison_of(:attr).is_other_than(10)
            end

            expect(&assertion).to fail_with_message(<<~MESSAGE)
Expected Example not to validate that :attr looks like a value other
than 10, but this could not be proved.
  After setting :attr to ‹10›, the matcher expected the Example to be
  valid, but it was invalid instead, producing these validation errors:

  * attr: ["must be other than 10"]
            MESSAGE
          end

          it_supports(
            'ignoring_interference_by_writer',
            column_type: :integer,
            tests: {
              reject_if_qualified_but_changing_value_interferes: {
                model_name: 'Example',
                attribute_name: :attr,
                changing_values_with: :next_value_or_numeric_value,
                expected_message: <<-MESSAGE.strip,
Expected Example to validate that :attr looks like a value other than
10, but this could not be proved.
  After setting :attr to ‹10› -- which was read back as ‹11› -- the
  matcher expected the Example to be invalid, but it was valid instead.

  As indicated in the message above, :attr seems to be changing certain
  values as they are set, and this could have something to do with why
  this test is failing. If you've overridden the writer method for this
  attribute, then you may need to change it to make this test pass, or
  do something else entirely.
                MESSAGE
              },
            },
          ) do
            def validation_matcher_scenario_args
              super.deep_merge(validation_options: { other_than: 10 })
            end

            def configure_validation_matcher(matcher)
              matcher.is_other_than(10)
            end
          end
        end

        context 'when the attribute is a virtual attribute in an ActiveRecord model' do
          it 'accepts' do
            record = build_record_validating_comparison_of_virtual_attribute(column_type: :integer, other_than: 10)

            expect(record).to validate_comparison_of(:attr).is_other_than(10)
          end
        end

        context 'when comparison value is a proc returning an integer' do
          it 'accepts' do
            record = build_record_validating_comparison(column_type: :integer, other_than: -> (_record) { 10 })

            expect(record).to validate_comparison_of(:attr).is_other_than(-> (_record) { 10 })
          end
        end

        context 'when comparison value is a method returning an integer' do
          it 'accepts' do
            record = build_record_validating_comparison(column_type: :integer, other_than: :comparison_value)
            allow(record).to receive(:comparison_value).and_return(10)

            expect(record).to validate_comparison_of(:attr).is_other_than(:comparison_value)
          end
        end

        context 'when the column is an string column' do
          it 'rejects and raise an error' do
            record = build_record_validating_comparison(column_type: :string, other_than: 10)

            assertion = lambda do
              expect(record).to validate_comparison_of(:attr).is_other_than(10)
            end

            expect(&assertion).to fail_with_message(<<~MESSAGE)
Expected Example to validate that :attr looks like a value other than
10, but this could not be proved.
  After setting :attr to ‹"10"›, the matcher expected the Example to be
  invalid, but it was valid instead.
            MESSAGE
          end
        end

        context 'when the column is a date column' do
          it 'rejects and raise an error' do
            record = build_record_validating_comparison(column_type: :date, other_than: 10)

            assertion = lambda do
              expect(record).to validate_comparison_of(:attr).is_other_than(10)
            end

            expect(&assertion).to fail_with_message(<<~MESSAGE)
Expected Example to validate that :attr looks like a value other than
10, but this could not be proved.
  After setting :attr to ‹"10"› -- which was read back as ‹nil› -- the
  matcher expected the Example to be invalid and to produce the
  validation error "must be other than 10" on :attr. The record was
  indeed invalid, but it produced these validation errors instead:

  * attr: ["can't be blank"]

  As indicated in the message above, :attr seems to be changing certain
  values as they are set, and this could have something to do with why
  this test is failing. If you've overridden the writer method for this
  attribute, then you may need to change it to make this test pass, or
  do something else entirely.
            MESSAGE
          end
        end

        context 'when the column is an integer column' do
          it 'accepts (and does not raise an error)' do
            record = build_record_validating_comparison(
              column_type: :integer,
              other_than: 10,
            )

            expect(record).
              to validate_comparison.
              is_other_than(10)
          end
        end

        context 'when the column is a float column' do
          it 'accepts (and does not raise an error)' do
            record = build_record_validating_comparison(
              column_type: :float,
              other_than: 10,
            )

            expect(record).
              to validate_comparison.
              is_other_than(10)
          end
        end

        context 'when the column is a decimal column' do
          it 'accepts (and does not raise an error)' do
            record = build_record_validating_comparison(
              column_type: :decimal,
              other_than: 10,
            )

            expect(record).
              to validate_comparison.
              is_other_than(10)
          end
        end
      end

      context 'qualified with is_equal_to' do
        context 'and validating with equal_to' do
          it 'accepts' do
            record = build_record_validating_comparison(column_type: :integer, equal_to: 10)

            expect(record).to validate_comparison_of(:attr).is_equal_to(10)
          end

          it 'rejects when used in the negative' do
            record = build_record_validating_comparison(column_type: :integer, equal_to: 10)

            assertion = lambda do
              expect(record).not_to validate_comparison_of(:attr).is_equal_to(10)
            end

            expect(&assertion).to fail_with_message(<<~MESSAGE)
Expected Example not to validate that :attr looks like a value equal to
10, but this could not be proved.
  After setting :attr to ‹9›, the matcher expected the Example to be
  valid, but it was invalid instead, producing these validation errors:

  * attr: ["must be equal to 10"]
            MESSAGE
          end

          it_supports(
            'ignoring_interference_by_writer',
            column_type: :integer,
            tests: {
              reject_if_qualified_but_changing_value_interferes: {
                model_name: 'Example',
                attribute_name: :attr,
                changing_values_with: :next_value_or_numeric_value,
                expected_message: <<-MESSAGE.strip,
Expected Example to validate that :attr looks like a value equal to 10,
but this could not be proved.
  After setting :attr to ‹10› -- which was read back as ‹11› -- the
  matcher expected the Example to be valid, but it was invalid instead,
  producing these validation errors:

  * attr: ["must be equal to 10"]

  As indicated in the message above, :attr seems to be changing certain
  values as they are set, and this could have something to do with why
  this test is failing. If you've overridden the writer method for this
  attribute, then you may need to change it to make this test pass, or
  do something else entirely.
                MESSAGE
              },
            },
          ) do
            def validation_matcher_scenario_args
              super.deep_merge(validation_options: { equal_to: 10 })
            end

            def configure_validation_matcher(matcher)
              matcher.is_equal_to(10)
            end
          end
        end

        context 'when the attribute is a virtual attribute in an ActiveRecord model' do
          it 'accepts' do
            record = build_record_validating_comparison_of_virtual_attribute(column_type: :integer, equal_to: 10)

            expect(record).to validate_comparison_of(:attr).is_equal_to(10)
          end
        end

        context 'when comparison value is a proc returning an integer' do
          it 'accepts' do
            record = build_record_validating_comparison(column_type: :integer, equal_to: -> (_record) { 10 })

            expect(record).to validate_comparison_of(:attr).is_equal_to(-> (_record) { 10 })
          end
        end

        context 'when comparison value is a method returning an integer' do
          it 'accepts' do
            record = build_record_validating_comparison(column_type: :integer, equal_to: :comparison_value)
            allow(record).to receive(:comparison_value).and_return(10)

            expect(record).to validate_comparison_of(:attr).is_equal_to(:comparison_value)
          end
        end

        context 'when the column is an string column' do
          it 'rejects and raise an error' do
            record = build_record_validating_comparison(column_type: :string, equal_to: 10)

            assertion = lambda do
              expect(record).to validate_comparison_of(:attr).is_equal_to(10)
            end

            expect(&assertion).to fail_with_message(<<~MESSAGE)
Expected Example to validate that :attr looks like a value equal to 10,
but this could not be proved.
  After setting :attr to ‹"10"›, the matcher expected the Example to be
  valid, but it was invalid instead, producing these validation errors:

  * attr: ["must be equal to 10"]
            MESSAGE
          end
        end

        context 'when the column is a date column' do
          it 'rejects and raise an error' do
            record = build_record_validating_comparison(column_type: :date, equal_to: 10)

            assertion = lambda do
              expect(record).to validate_comparison_of(:attr).is_equal_to(10)
            end

            expect(&assertion).to fail_with_message(<<~MESSAGE)
Expected Example to validate that :attr looks like a value equal to 10,
but this could not be proved.
  After setting :attr to ‹"11"› -- which was read back as ‹nil› -- the
  matcher expected the Example to be invalid and to produce the
  validation error "must be equal to 10" on :attr. The record was indeed
  invalid, but it produced these validation errors instead:

  * attr: ["can't be blank"]

  As indicated in the message above, :attr seems to be changing certain
  values as they are set, and this could have something to do with why
  this test is failing. If you've overridden the writer method for this
  attribute, then you may need to change it to make this test pass, or
  do something else entirely.
            MESSAGE
          end
        end

        context 'when the column is an integer column' do
          it 'accepts (and does not raise an error)' do
            record = build_record_validating_comparison(
              column_type: :integer,
              equal_to: 10,
            )

            expect(record).
              to validate_comparison.
              is_equal_to(10)
          end
        end

        context 'when the column is a float column' do
          it 'accepts (and does not raise an error)' do
            record = build_record_validating_comparison(
              column_type: :float,
              equal_to: 10,
            )

            expect(record).
              to validate_comparison.
              is_equal_to(10)
          end
        end

        context 'when the column is a decimal column' do
          it 'accepts (and does not raise an error)' do
            record = build_record_validating_comparison(
              column_type: :decimal,
              equal_to: 10,
            )

            expect(record).
              to validate_comparison.
              is_equal_to(10)
          end
        end
      end

      context 'qualified with less_than_or_equal_to' do
        context 'and validating with is_less_than_or_equal_to' do
          it 'accepts' do
            record = build_record_validating_comparison(column_type: :integer, less_than_or_equal_to: 10)

            expect(record).to validate_comparison_of(:attr).is_less_than_or_equal_to(10)
          end

          it 'rejects when used in the negative' do
            record = build_record_validating_comparison(column_type: :integer, less_than_or_equal_to: 10)

            assertion = lambda do
              expect(record).not_to validate_comparison_of(:attr).is_less_than_or_equal_to(10)
            end

            expect(&assertion).to fail_with_message(<<~MESSAGE)
Expected Example not to validate that :attr looks like a value less than
or equal to 10, but this could not be proved.
  After setting :attr to ‹11›, the matcher expected the Example to be
  valid, but it was invalid instead, producing these validation errors:

  * attr: ["must be less than or equal to 10"]
            MESSAGE
          end

          it_supports(
            'ignoring_interference_by_writer',
            column_type: :integer,
            tests: {
              reject_if_qualified_but_changing_value_interferes: {
                model_name: 'Example',
                attribute_name: :attr,
                changing_values_with: :next_value_or_numeric_value,
                expected_message: <<-MESSAGE.strip,
Expected Example to validate that :attr looks like a value less than or
equal to 10, but this could not be proved.
  After setting :attr to ‹10› -- which was read back as ‹11› -- the
  matcher expected the Example to be valid, but it was invalid instead,
  producing these validation errors:

  * attr: ["must be less than or equal to 10"]

  As indicated in the message above, :attr seems to be changing certain
  values as they are set, and this could have something to do with why
  this test is failing. If you've overridden the writer method for this
  attribute, then you may need to change it to make this test pass, or
  do something else entirely.
                MESSAGE
              },
            },
          ) do
            def validation_matcher_scenario_args
              super.deep_merge(validation_options: { less_than_or_equal_to: 10 })
            end

            def configure_validation_matcher(matcher)
              matcher.is_less_than_or_equal_to(10)
            end
          end
        end

        context 'when the attribute is a virtual attribute in an ActiveRecord model' do
          it 'accepts' do
            record = build_record_validating_comparison_of_virtual_attribute(column_type: :integer, less_than_or_equal_to: 10)

            expect(record).to validate_comparison_of(:attr).is_less_than_or_equal_to(10)
          end
        end

        context 'when comparison value is a proc returning an integer' do
          it 'accepts' do
            record = build_record_validating_comparison(column_type: :integer, less_than_or_equal_to: -> (_record) { 10 })

            expect(record).to validate_comparison_of(:attr).is_less_than_or_equal_to(-> (_record) { 10 })
          end
        end

        context 'when comparison value is a method returning an integer' do
          it 'accepts' do
            record = build_record_validating_comparison(column_type: :integer, less_than_or_equal_to: :comparison_value)
            allow(record).to receive(:comparison_value).and_return(10)

            expect(record).to validate_comparison_of(:attr).is_less_than_or_equal_to(:comparison_value)
          end
        end

        context 'when the column is an string column' do
          it 'rejects and raise an error' do
            record = build_record_validating_comparison(column_type: :string, less_than_or_equal_to: 10)

            assertion = lambda do
              expect(record).to validate_comparison_of(:attr).is_less_than_or_equal_to(10)
            end

            expect(&assertion).to fail_with_message(<<~MESSAGE)
Expected Example to validate that :attr looks like a value less than or
equal to 10, but this could not be proved.
  After setting :attr to ‹"11"›, the matcher expected the Example to be
  invalid and to produce the validation error "must be less than or
  equal to 10" on :attr. The record was indeed invalid, but it produced
  these validation errors instead:

  * attr: ["comparison of String with 10 failed"]
            MESSAGE
          end
        end

        context 'when the column is a date column' do
          it 'rejects and raise an error' do
            record = build_record_validating_comparison(column_type: :date, less_than_or_equal_to: 10)

            assertion = lambda do
              expect(record).to validate_comparison_of(:attr).is_less_than_or_equal_to(10)
            end

            expect(&assertion).to fail_with_message(<<~MESSAGE)
Expected Example to validate that :attr looks like a value less than or
equal to 10, but this could not be proved.
  After setting :attr to ‹"11"› -- which was read back as ‹nil› -- the
  matcher expected the Example to be invalid and to produce the
  validation error "must be less than or equal to 10" on :attr. The
  record was indeed invalid, but it produced these validation errors
  instead:

  * attr: ["can't be blank"]

  As indicated in the message above, :attr seems to be changing certain
  values as they are set, and this could have something to do with why
  this test is failing. If you've overridden the writer method for this
  attribute, then you may need to change it to make this test pass, or
  do something else entirely.
            MESSAGE
          end
        end

        context 'when the column is an integer column' do
          it 'accepts (and does not raise an error)' do
            record = build_record_validating_comparison(
              column_type: :integer,
              less_than_or_equal_to: 10,
            )

            expect(record).
              to validate_comparison.
              is_less_than_or_equal_to(10)
          end
        end

        context 'when the column is a float column' do
          it 'accepts (and does not raise an error)' do
            record = build_record_validating_comparison(
              column_type: :float,
              less_than_or_equal_to: 10,
            )

            expect(record).
              to validate_comparison.
              is_less_than_or_equal_to(10)
          end
        end

        context 'when the column is a decimal column' do
          it 'accepts (and does not raise an error)' do
            record = build_record_validating_comparison(
              column_type: :decimal,
              less_than_or_equal_to: 10,
            )

            expect(record).
              to validate_comparison.
              is_less_than_or_equal_to(10)
          end
        end
      end

      context 'qualified with is_less_than' do
        context 'and validating with less_than' do
          it 'accepts' do
            record = build_record_validating_comparison(column_type: :integer, less_than: 10)

            expect(record).to validate_comparison_of(:attr).is_less_than(10)
          end

          it 'rejects when used in the negative' do
            record = build_record_validating_comparison(column_type: :integer, less_than: 10)

            assertion = lambda do
              expect(record).not_to validate_comparison_of(:attr).is_less_than(10)
            end

            expect(&assertion).to fail_with_message(<<~MESSAGE)
Expected Example not to validate that :attr looks like a value less than
10, but this could not be proved.
  After setting :attr to ‹10›, the matcher expected the Example to be
  valid, but it was invalid instead, producing these validation errors:

  * attr: ["must be less than 10"]
            MESSAGE
          end

          it_supports(
            'ignoring_interference_by_writer',
            column_type: :integer,
            tests: {
              reject_if_qualified_but_changing_value_interferes: {
                model_name: 'Example',
                attribute_name: :attr,
                changing_values_with: :next_value_or_numeric_value,
                expected_message: <<-MESSAGE.strip,
Expected Example to validate that :attr looks like a value less than 10,
but this could not be proved.
  After setting :attr to ‹9› -- which was read back as ‹10› -- the
  matcher expected the Example to be valid, but it was invalid instead,
  producing these validation errors:

  * attr: ["must be less than 10"]

  As indicated in the message above, :attr seems to be changing certain
  values as they are set, and this could have something to do with why
  this test is failing. If you've overridden the writer method for this
  attribute, then you may need to change it to make this test pass, or
  do something else entirely.
                MESSAGE
              },
            },
          ) do
            def validation_matcher_scenario_args
              super.deep_merge(validation_options: { less_than: 10 })
            end

            def configure_validation_matcher(matcher)
              matcher.is_less_than(10)
            end
          end
        end

        context 'when the attribute is a virtual attribute in an ActiveRecord model' do
          it 'accepts' do
            record = build_record_validating_comparison_of_virtual_attribute(column_type: :integer, less_than: 10)

            expect(record).to validate_comparison_of(:attr).is_less_than(10)
          end
        end

        context 'when comparison value is a proc returning an integer' do
          it 'accepts' do
            record = build_record_validating_comparison(column_type: :integer, less_than: -> (_record) { 10 })

            expect(record).to validate_comparison_of(:attr).is_less_than(-> (_record) { 10 })
          end
        end

        context 'when comparison value is a method returning an integer' do
          it 'accepts' do
            record = build_record_validating_comparison(column_type: :integer, less_than: :comparison_value)
            allow(record).to receive(:comparison_value).and_return(10)

            expect(record).to validate_comparison_of(:attr).is_less_than(:comparison_value)
          end
        end

        context 'when the column is an string column' do
          it 'rejects and raise an error' do
            record = build_record_validating_comparison(column_type: :string, less_than: 10)

            assertion = lambda do
              expect(record).to validate_comparison_of(:attr).is_less_than(10)
            end

            expect(&assertion).to fail_with_message(<<~MESSAGE)
Expected Example to validate that :attr looks like a value less than 10,
but this could not be proved.
  After setting :attr to ‹"11"›, the matcher expected the Example to be
  invalid and to produce the validation error "must be less than 10" on
  :attr. The record was indeed invalid, but it produced these validation
  errors instead:

  * attr: ["comparison of String with 10 failed"]
            MESSAGE
          end
        end

        context 'when the column is a date column' do
          it 'rejects and raise an error' do
            record = build_record_validating_comparison(column_type: :date, less_than: 10)

            assertion = lambda do
              expect(record).to validate_comparison_of(:attr).is_less_than(10)
            end

            expect(&assertion).to fail_with_message(<<~MESSAGE)
Expected Example to validate that :attr looks like a value less than 10,
but this could not be proved.
  After setting :attr to ‹"11"› -- which was read back as ‹nil› -- the
  matcher expected the Example to be invalid and to produce the
  validation error "must be less than 10" on :attr. The record was
  indeed invalid, but it produced these validation errors instead:

  * attr: ["can't be blank"]

  As indicated in the message above, :attr seems to be changing certain
  values as they are set, and this could have something to do with why
  this test is failing. If you've overridden the writer method for this
  attribute, then you may need to change it to make this test pass, or
  do something else entirely.
            MESSAGE
          end
        end

        context 'when the column is an integer column' do
          it 'accepts (and does not raise an error)' do
            record = build_record_validating_comparison(
              column_type: :integer,
              less_than: 10,
            )

            expect(record).
              to validate_comparison.
              is_less_than(10)
          end
        end

        context 'when the column is a float column' do
          it 'accepts (and does not raise an error)' do
            record = build_record_validating_comparison(
              column_type: :float,
              less_than: 10,
            )

            expect(record).
              to validate_comparison.
              is_less_than(10)
          end
        end

        context 'when the column is a decimal column' do
          it 'accepts (and does not raise an error)' do
            record = build_record_validating_comparison(
              column_type: :decimal,
              less_than: 10,
            )

            expect(record).
              to validate_comparison.
              is_less_than(10)
          end
        end
      end

      context 'qualified with is_greater_than' do
        context 'and validating with greater_than' do
          it 'accepts' do
            record = build_record_validating_comparison(column_type: :integer, greater_than: 10)

            expect(record).to validate_comparison_of(:attr).is_greater_than(10)
          end

          it 'rejects when used in the negative' do
            record = build_record_validating_comparison(column_type: :integer, greater_than: 10)

            assertion = lambda do
              expect(record).not_to validate_comparison_of(:attr).is_greater_than(10)
            end

            expect(&assertion).to fail_with_message(<<~MESSAGE)
Expected Example not to validate that :attr looks like a value greater
than 10, but this could not be proved.
  After setting :attr to ‹9›, the matcher expected the Example to be
  valid, but it was invalid instead, producing these validation errors:

  * attr: ["must be greater than 10"]
            MESSAGE
          end

          it_supports(
            'ignoring_interference_by_writer',
            column_type: :integer,
            tests: {
              reject_if_qualified_but_changing_value_interferes: {
                model_name: 'Example',
                attribute_name: :attr,
                changing_values_with: :numeric_value,
                expected_message: <<-MESSAGE.strip,
Expected Example to validate that :attr looks like a value greater than
10, but this could not be proved.
  After setting :attr to ‹11› -- which was read back as ‹1› -- the
  matcher expected the Example to be valid, but it was invalid instead,
  producing these validation errors:

  * attr: ["must be greater than 10"]

  As indicated in the message above, :attr seems to be changing certain
  values as they are set, and this could have something to do with why
  this test is failing. If you've overridden the writer method for this
  attribute, then you may need to change it to make this test pass, or
  do something else entirely.
                MESSAGE
              },
            },
          ) do
            def validation_matcher_scenario_args
              super.deep_merge(validation_options: { greater_than: 10 })
            end

            def configure_validation_matcher(matcher)
              matcher.is_greater_than(10)
            end
          end
        end

        context 'when the attribute is a virtual attribute in an ActiveRecord model' do
          it 'accepts' do
            record = build_record_validating_comparison_of_virtual_attribute(column_type: :integer, greater_than: 10)

            expect(record).to validate_comparison_of(:attr).is_greater_than(10)
          end
        end

        context 'when comparison value is a proc returning an integer' do
          it 'accepts' do
            record = build_record_validating_comparison(column_type: :integer, greater_than: -> (_record) { 10 })

            expect(record).to validate_comparison_of(:attr).is_greater_than(-> (_record) { 10 })
          end
        end

        context 'when comparison value is a method returning an integer' do
          it 'accepts' do
            record = build_record_validating_comparison(column_type: :integer, greater_than: :comparison_value)
            allow(record).to receive(:comparison_value).and_return(10)

            expect(record).to validate_comparison_of(:attr).is_greater_than(:comparison_value)
          end
        end

        context 'when the column is an string column' do
          it 'rejects and raise an error' do
            record = build_record_validating_comparison(column_type: :string, greater_than: 10)

            assertion = lambda do
              expect(record).to validate_comparison_of(:attr).is_greater_than(10)
            end

            expect(&assertion).to fail_with_message(<<~MESSAGE)
Expected Example to validate that :attr looks like a value greater than
10, but this could not be proved.
  After setting :attr to ‹"10"›, the matcher expected the Example to be
  invalid and to produce the validation error "must be greater than 10"
  on :attr. The record was indeed invalid, but it produced these
  validation errors instead:

  * attr: ["comparison of String with 10 failed"]
            MESSAGE
          end
        end

        context 'when the column is a date column' do
          it 'rejects and raise an error' do
            record = build_record_validating_comparison(column_type: :date, greater_than: 10)

            assertion = lambda do
              expect(record).to validate_comparison_of(:attr).is_greater_than(10)
            end

            expect(&assertion).to fail_with_message(<<~MESSAGE)
Expected Example to validate that :attr looks like a value greater than
10, but this could not be proved.
  After setting :attr to ‹"10"› -- which was read back as ‹nil› -- the
  matcher expected the Example to be invalid and to produce the
  validation error "must be greater than 10" on :attr. The record was
  indeed invalid, but it produced these validation errors instead:

  * attr: ["can't be blank"]

  As indicated in the message above, :attr seems to be changing certain
  values as they are set, and this could have something to do with why
  this test is failing. If you've overridden the writer method for this
  attribute, then you may need to change it to make this test pass, or
  do something else entirely.
            MESSAGE
          end
        end

        context 'when the column is an integer column' do
          it 'accepts (and does not raise an error)' do
            record = build_record_validating_comparison(
              column_type: :integer,
              greater_than: 10,
            )

            expect(record).
              to validate_comparison.
              is_greater_than(10)
          end
        end

        context 'when the column is a float column' do
          it 'accepts (and does not raise an error)' do
            record = build_record_validating_comparison(
              column_type: :float,
              greater_than: 10,
            )

            expect(record).
              to validate_comparison.
              is_greater_than(10)
          end
        end

        context 'when the column is a decimal column' do
          it 'accepts (and does not raise an error)' do
            record = build_record_validating_comparison(
              column_type: :decimal,
              greater_than: 10,
            )

            expect(record).
              to validate_comparison.
              is_greater_than(10)
          end
        end
      end

      context 'qualified with is_greater_than_or_equal_to' do
        context 'and validating with greater_than_or_equal_to' do
          it 'accepts' do
            record = build_record_validating_comparison(column_type: :integer, greater_than_or_equal_to: 10)

            expect(record).to validate_comparison_of(:attr).is_greater_than_or_equal_to(10)
          end

          it 'rejects when used in the negative' do
            record = build_record_validating_comparison(column_type: :integer, greater_than_or_equal_to: 10)

            assertion = lambda do
              expect(record).not_to validate_comparison_of(:attr).is_greater_than_or_equal_to(10)
            end

            expect(&assertion).to fail_with_message(<<~MESSAGE)
Expected Example not to validate that :attr looks like a value greater
than or equal to 10, but this could not be proved.
  After setting :attr to ‹9›, the matcher expected the Example to be
  valid, but it was invalid instead, producing these validation errors:

  * attr: ["must be greater than or equal to 10"]
            MESSAGE
          end

          it_supports(
            'ignoring_interference_by_writer',
            column_type: :integer,
            tests: {
              reject_if_qualified_but_changing_value_interferes: {
                model_name: 'Example',
                attribute_name: :attr,
                changing_values_with: :numeric_value,
                expected_message: <<-MESSAGE.strip,
Expected Example to validate that :attr looks like a value greater than
or equal to 10, but this could not be proved.
  After setting :attr to ‹11› -- which was read back as ‹1› -- the
  matcher expected the Example to be valid, but it was invalid instead,
  producing these validation errors:

  * attr: ["must be greater than or equal to 10"]

  As indicated in the message above, :attr seems to be changing certain
  values as they are set, and this could have something to do with why
  this test is failing. If you've overridden the writer method for this
  attribute, then you may need to change it to make this test pass, or
  do something else entirely.
                MESSAGE
              },
            },
          ) do
            def validation_matcher_scenario_args
              super.deep_merge(validation_options: { greater_than_or_equal_to: 10 })
            end

            def configure_validation_matcher(matcher)
              matcher.is_greater_than_or_equal_to(10)
            end
          end
        end

        context 'when the attribute is a virtual attribute in an ActiveRecord model' do
          it 'accepts' do
            record = build_record_validating_comparison_of_virtual_attribute(column_type: :integer, greater_than_or_equal_to: 10)

            expect(record).to validate_comparison_of(:attr).is_greater_than_or_equal_to(10)
          end
        end

        context 'when comparison value is a proc returning an integer' do
          it 'accepts' do
            record = build_record_validating_comparison(column_type: :integer, greater_than_or_equal_to: -> (_record) { 10 })

            expect(record).to validate_comparison_of(:attr).is_greater_than_or_equal_to(-> (_record) { 10 })
          end
        end

        context 'when comparison value is a method returning an integer' do
          it 'accepts' do
            record = build_record_validating_comparison(column_type: :integer, greater_than_or_equal_to: :comparison_value)
            allow(record).to receive(:comparison_value).and_return(10)

            expect(record).to validate_comparison_of(:attr).is_greater_than_or_equal_to(:comparison_value)
          end
        end

        context 'when the column is an string column' do
          it 'rejects and raise an error' do
            record = build_record_validating_comparison(column_type: :string, greater_than_or_equal_to: 10)

            assertion = lambda do
              expect(record).to validate_comparison_of(:attr).is_greater_than_or_equal_to(10)
            end

            expect(&assertion).to fail_with_message(<<~MESSAGE)
Expected Example to validate that :attr looks like a value greater than
or equal to 10, but this could not be proved.
  After setting :attr to ‹"9"›, the matcher expected the Example to be
  invalid and to produce the validation error "must be greater than or
  equal to 10" on :attr. The record was indeed invalid, but it produced
  these validation errors instead:

  * attr: ["comparison of String with 10 failed"]
            MESSAGE
          end
        end

        context 'when the column is a date column' do
          it 'rejects and raise an error' do
            record = build_record_validating_comparison(column_type: :date, greater_than_or_equal_to: 10)

            assertion = lambda do
              expect(record).to validate_comparison_of(:attr).is_greater_than_or_equal_to(10)
            end

            expect(&assertion).to fail_with_message(<<~MESSAGE)
Expected Example to validate that :attr looks like a value greater than
or equal to 10, but this could not be proved.
  After setting :attr to ‹"9"› -- which was read back as ‹nil› -- the
  matcher expected the Example to be invalid and to produce the
  validation error "must be greater than or equal to 10" on :attr. The
  record was indeed invalid, but it produced these validation errors
  instead:

  * attr: ["can't be blank"]

  As indicated in the message above, :attr seems to be changing certain
  values as they are set, and this could have something to do with why
  this test is failing. If you've overridden the writer method for this
  attribute, then you may need to change it to make this test pass, or
  do something else entirely.
            MESSAGE
          end
        end

        context 'when the column is an integer column' do
          it 'accepts (and does not raise an error)' do
            record = build_record_validating_comparison(
              column_type: :integer,
              greater_than_or_equal_to: 10,
            )

            expect(record).
              to validate_comparison.
              is_greater_than_or_equal_to(10)
          end
        end

        context 'when the column is a float column' do
          it 'accepts (and does not raise an error)' do
            record = build_record_validating_comparison(
              column_type: :float,
              greater_than_or_equal_to: 10,
            )

            expect(record).
              to validate_comparison.
              is_greater_than_or_equal_to(10)
          end
        end

        context 'when the column is a decimal column' do
          it 'accepts (and does not raise an error)' do
            record = build_record_validating_comparison(
              column_type: :decimal,
              greater_than_or_equal_to: 10,
            )

            expect(record).
              to validate_comparison.
              is_greater_than_or_equal_to(10)
          end
        end
      end
    end

    context 'when comparing with an string' do
      context 'qualified with is_other_than' do
        context 'and validating with other_than' do
          it 'accepts' do
            record = build_record_validating_comparison(column_type: :string, other_than: 'cat')

            expect(record).to validate_comparison_of(:attr).is_other_than('cat')
          end

          it 'rejects when used in the negative' do
            record = build_record_validating_comparison(column_type: :string, other_than: 'cat')

            assertion = lambda do
              expect(record).not_to validate_comparison_of(:attr).is_other_than('cat')
            end

            expect(&assertion).to fail_with_message(<<~MESSAGE)
Expected Example not to validate that :attr looks like a value other
than cat, but this could not be proved.
  After setting :attr to ‹"cat"›, the matcher expected the Example to be
  valid, but it was invalid instead, producing these validation errors:

  * attr: ["must be other than cat"]
            MESSAGE
          end

          it_supports(
            'ignoring_interference_by_writer',
            column_type: :string,
            tests: {
              reject_if_qualified_but_changing_value_interferes: {
                model_name: 'Example',
                attribute_name: :attr,
                changing_values_with: :next_value_or_numeric_value,
                expected_message: <<-MESSAGE.strip,
Expected Example to validate that :attr looks like a value other than
cat, but this could not be proved.
  After setting :attr to ‹"cat"› -- which was read back as ‹"cau"› --
  the matcher expected the Example to be invalid, but it was valid
  instead.

  As indicated in the message above, :attr seems to be changing certain
  values as they are set, and this could have something to do with why
  this test is failing. If you've overridden the writer method for this
  attribute, then you may need to change it to make this test pass, or
  do something else entirely.
                MESSAGE
              },
            },
          ) do
            def validation_matcher_scenario_args
              super.deep_merge(validation_options: { other_than: 'cat' })
            end

            def configure_validation_matcher(matcher)
              matcher.is_other_than('cat')
            end
          end
        end

        context 'when the attribute is a virtual attribute in an ActiveRecord model' do
          it 'accepts' do
            record = build_record_validating_comparison_of_virtual_attribute(column_type: :string, other_than: 'cat')

            expect(record).to validate_comparison_of(:attr).is_other_than('cat')
          end
        end

        context 'when comparison value is a proc returning an string' do
          it 'accepts' do
            record = build_record_validating_comparison(column_type: :string, other_than: -> (_record) { 'cat' })

            expect(record).to validate_comparison_of(:attr).is_other_than(-> (_record) { 'cat' })
          end
        end

        context 'when comparison value is a method returning an string' do
          it 'accepts' do
            record = build_record_validating_comparison(column_type: :string, other_than: :comparison_value)
            allow(record).to receive(:comparison_value).and_return('cat')

            expect(record).to validate_comparison_of(:attr).is_other_than(:comparison_value)
          end
        end

        context 'when the column is an integer column' do
          it 'rejects and raise an error' do
            record = build_record_validating_comparison(column_type: :integer, other_than: 'cat')

            assertion = lambda do
              expect(record).to validate_comparison_of(:attr).is_other_than('cat')
            end

            expect(&assertion).to fail_with_message(<<~MESSAGE)
Expected Example to validate that :attr looks like a value other than
cat, but this could not be proved.
  After setting :attr to ‹"cat"› -- which was read back as ‹0› -- the
  matcher expected the Example to be invalid, but it was valid instead.

  As indicated in the message above, :attr seems to be changing certain
  values as they are set, and this could have something to do with why
  this test is failing. If you've overridden the writer method for this
  attribute, then you may need to change it to make this test pass, or
  do something else entirely.
            MESSAGE
          end
        end

        context 'when the column is a date column' do
          it 'rejects and raise an error' do
            record = build_record_validating_comparison(column_type: :date, other_than: 'cat')

            assertion = lambda do
              expect(record).to validate_comparison_of(:attr).is_other_than('cat')
            end

            expect(&assertion).to fail_with_message(<<~MESSAGE)
Expected Example to validate that :attr looks like a value other than
cat, but this could not be proved.
  After setting :attr to ‹"cat"› -- which was read back as ‹nil› -- the
  matcher expected the Example to be invalid and to produce the
  validation error "must be other than cat" on :attr. The record was
  indeed invalid, but it produced these validation errors instead:

  * attr: ["can't be blank"]

  As indicated in the message above, :attr seems to be changing certain
  values as they are set, and this could have something to do with why
  this test is failing. If you've overridden the writer method for this
  attribute, then you may need to change it to make this test pass, or
  do something else entirely.
            MESSAGE
          end
        end
      end

      context 'qualified with is_equal_to' do
        context 'and validating with equal_to' do
          it 'accepts' do
            record = build_record_validating_comparison(column_type: :string, equal_to: 'cat')

            expect(record).to validate_comparison_of(:attr).is_equal_to('cat')
          end

          it 'rejects when used in the negative' do
            record = build_record_validating_comparison(column_type: :string, equal_to: 'cat')

            assertion = lambda do
              expect(record).not_to validate_comparison_of(:attr).is_equal_to('cat')
            end

            expect(&assertion).to fail_with_message(<<~MESSAGE)
Expected Example not to validate that :attr looks like a value equal to
cat, but this could not be proved.
  After setting :attr to ‹"cas"›, the matcher expected the Example to be
  valid, but it was invalid instead, producing these validation errors:

  * attr: ["must be equal to cat"]
            MESSAGE
          end

          it_supports(
            'ignoring_interference_by_writer',
            column_type: :string,
            tests: {
              reject_if_qualified_but_changing_value_interferes: {
                model_name: 'Example',
                attribute_name: :attr,
                changing_values_with: :next_value_or_numeric_value,
                expected_message: <<-MESSAGE.strip,
Expected Example to validate that :attr looks like a value equal to cat,
but this could not be proved.
  After setting :attr to ‹"cat"› -- which was read back as ‹"cau"› --
  the matcher expected the Example to be valid, but it was invalid
  instead, producing these validation errors:

  * attr: ["must be equal to cat"]

  As indicated in the message above, :attr seems to be changing certain
  values as they are set, and this could have something to do with why
  this test is failing. If you've overridden the writer method for this
  attribute, then you may need to change it to make this test pass, or
  do something else entirely.
                MESSAGE
              },
            },
          ) do
            def validation_matcher_scenario_args
              super.deep_merge(validation_options: { equal_to: 'cat' })
            end

            def configure_validation_matcher(matcher)
              matcher.is_equal_to('cat')
            end
          end
        end

        context 'when the attribute is a virtual attribute in an ActiveRecord model' do
          it 'accepts' do
            record = build_record_validating_comparison_of_virtual_attribute(column_type: :string, equal_to: 'cat')

            expect(record).to validate_comparison_of(:attr).is_equal_to('cat')
          end
        end

        context 'when comparison value is a proc returning an string' do
          it 'accepts' do
            record = build_record_validating_comparison(column_type: :string, equal_to: -> (_record) { 'cat' })

            expect(record).to validate_comparison_of(:attr).is_equal_to(-> (_record) { 'cat' })
          end
        end

        context 'when comparison value is a method returning an string' do
          it 'accepts' do
            record = build_record_validating_comparison(column_type: :string, equal_to: :comparison_value)
            allow(record).to receive(:comparison_value).and_return('cat')

            expect(record).to validate_comparison_of(:attr).is_equal_to(:comparison_value)
          end
        end

        context 'when the column is an integer column' do
          it 'rejects and raise an error' do
            record = build_record_validating_comparison(column_type: :integer, equal_to: 'cat')

            assertion = lambda do
              expect(record).to validate_comparison_of(:attr).is_equal_to('cat')
            end

            expect(&assertion).to fail_with_message(<<~MESSAGE)
Expected Example to validate that :attr looks like a value equal to cat,
but this could not be proved.
  After setting :attr to ‹"cat"› -- which was read back as ‹0› -- the
  matcher expected the Example to be valid, but it was invalid instead,
  producing these validation errors:

  * attr: ["must be equal to cat"]

  As indicated in the message above, :attr seems to be changing certain
  values as they are set, and this could have something to do with why
  this test is failing. If you've overridden the writer method for this
  attribute, then you may need to change it to make this test pass, or
  do something else entirely.
            MESSAGE
          end
        end

        context 'when the column is a date column' do
          it 'rejects and raise an error' do
            record = build_record_validating_comparison(column_type: :date, equal_to: 'cat')

            assertion = lambda do
              expect(record).to validate_comparison_of(:attr).is_equal_to('cat')
            end

            expect(&assertion).to fail_with_message(<<~MESSAGE)
Expected Example to validate that :attr looks like a value equal to cat,
but this could not be proved.
  After setting :attr to ‹"cau"› -- which was read back as ‹nil› -- the
  matcher expected the Example to be invalid and to produce the
  validation error "must be equal to cat" on :attr. The record was
  indeed invalid, but it produced these validation errors instead:

  * attr: ["can't be blank"]

  As indicated in the message above, :attr seems to be changing certain
  values as they are set, and this could have something to do with why
  this test is failing. If you've overridden the writer method for this
  attribute, then you may need to change it to make this test pass, or
  do something else entirely.
            MESSAGE
          end
        end
      end

      context 'qualified with is_less_than_or_equal_to' do
        context 'and validating with less_than_or_equal_to' do
          it 'accepts' do
            record = build_record_validating_comparison(column_type: :string, less_than_or_equal_to: 'cat')

            expect(record).to validate_comparison_of(:attr).is_less_than_or_equal_to('cat')
          end

          it 'rejects when used in the negative' do
            record = build_record_validating_comparison(column_type: :string, less_than_or_equal_to: 'cat')

            assertion = lambda do
              expect(record).not_to validate_comparison_of(:attr).is_less_than_or_equal_to('cat')
            end

            expect(&assertion).to fail_with_message(<<~MESSAGE)
Expected Example not to validate that :attr looks like a value less than
or equal to cat, but this could not be proved.
  After setting :attr to ‹"cau"›, the matcher expected the Example to be
  valid, but it was invalid instead, producing these validation errors:

  * attr: ["must be less than or equal to cat"]
            MESSAGE
          end

          it_supports(
            'ignoring_interference_by_writer',
            column_type: :string,
            tests: {
              reject_if_qualified_but_changing_value_interferes: {
                model_name: 'Example',
                attribute_name: :attr,
                changing_values_with: :next_value_or_numeric_value,
                expected_message: <<-MESSAGE.strip,
Expected Example to validate that :attr looks like a value less than or
equal to cat, but this could not be proved.
  After setting :attr to ‹"cat"› -- which was read back as ‹"cau"› --
  the matcher expected the Example to be valid, but it was invalid
  instead, producing these validation errors:

  * attr: ["must be less than or equal to cat"]

  As indicated in the message above, :attr seems to be changing certain
  values as they are set, and this could have something to do with why
  this test is failing. If you've overridden the writer method for this
  attribute, then you may need to change it to make this test pass, or
  do something else entirely.
                MESSAGE
              },
            },
          ) do
            def validation_matcher_scenario_args
              super.deep_merge(validation_options: { less_than_or_equal_to: 'cat' })
            end

            def configure_validation_matcher(matcher)
              matcher.is_less_than_or_equal_to('cat')
            end
          end
        end

        context 'when the attribute is a virtual attribute in an ActiveRecord model' do
          it 'accepts' do
            record = build_record_validating_comparison_of_virtual_attribute(column_type: :string, less_than_or_equal_to: 'cat')

            expect(record).to validate_comparison_of(:attr).is_less_than_or_equal_to('cat')
          end
        end

        context 'when comparison value is a proc returning an string' do
          it 'accepts' do
            record = build_record_validating_comparison(column_type: :string, less_than_or_equal_to: -> (_record) { 'cat' })

            expect(record).to validate_comparison_of(:attr).is_less_than_or_equal_to(-> (_record) { 'cat' })
          end
        end

        context 'when comparison value is a method returning an string' do
          it 'accepts' do
            record = build_record_validating_comparison(column_type: :string, less_than_or_equal_to: :comparison_value)
            allow(record).to receive(:comparison_value).and_return('cat')

            expect(record).to validate_comparison_of(:attr).is_less_than_or_equal_to(:comparison_value)
          end
        end

        context 'when the column is a date column' do
          it 'rejects and raise an error' do
            record = build_record_validating_comparison(column_type: :date, less_than_or_equal_to: 'cat')

            assertion = lambda do
              expect(record).to validate_comparison_of(:attr).is_less_than_or_equal_to('cat')
            end

            expect(&assertion).to fail_with_message(<<~MESSAGE)
Expected Example to validate that :attr looks like a value less than or
equal to cat, but this could not be proved.
  After setting :attr to ‹"cau"› -- which was read back as ‹nil› -- the
  matcher expected the Example to be invalid and to produce the
  validation error "must be less than or equal to cat" on :attr. The
  record was indeed invalid, but it produced these validation errors
  instead:

  * attr: ["can't be blank"]

  As indicated in the message above, :attr seems to be changing certain
  values as they are set, and this could have something to do with why
  this test is failing. If you've overridden the writer method for this
  attribute, then you may need to change it to make this test pass, or
  do something else entirely.
            MESSAGE
          end
        end
      end

      context 'qualified with is_less_than' do
        context 'and validating with less_than' do
          it 'accepts' do
            record = build_record_validating_comparison(column_type: :string, less_than: 'cat')

            expect(record).to validate_comparison_of(:attr).is_less_than('cat')
          end

          it 'rejects when used in the negative' do
            record = build_record_validating_comparison(column_type: :string, less_than: 'cat')

            assertion = lambda do
              expect(record).not_to validate_comparison_of(:attr).is_less_than('cat')
            end

            expect(&assertion).to fail_with_message(<<~MESSAGE)
Expected Example not to validate that :attr looks like a value less than
cat, but this could not be proved.
  After setting :attr to ‹"cat"›, the matcher expected the Example to be
  valid, but it was invalid instead, producing these validation errors:

  * attr: ["must be less than cat"]
            MESSAGE
          end

          it_supports(
            'ignoring_interference_by_writer',
            column_type: :string,
            tests: {
              reject_if_qualified_but_changing_value_interferes: {
                model_name: 'Example',
                attribute_name: :attr,
                changing_values_with: :next_value_or_numeric_value,
                expected_message: <<-MESSAGE.strip,
Expected Example to validate that :attr looks like a value less than
cat, but this could not be proved.
  After setting :attr to ‹"cas"› -- which was read back as ‹"cat"› --
  the matcher expected the Example to be valid, but it was invalid
  instead, producing these validation errors:

  * attr: ["must be less than cat"]

  As indicated in the message above, :attr seems to be changing certain
  values as they are set, and this could have something to do with why
  this test is failing. If you've overridden the writer method for this
  attribute, then you may need to change it to make this test pass, or
  do something else entirely.
                MESSAGE
              },
            },
          ) do
            def validation_matcher_scenario_args
              super.deep_merge(validation_options: { less_than: 'cat' })
            end

            def configure_validation_matcher(matcher)
              matcher.is_less_than('cat')
            end
          end
        end

        context 'when the attribute is a virtual attribute in an ActiveRecord model' do
          it 'accepts' do
            record = build_record_validating_comparison_of_virtual_attribute(column_type: :string, less_than: 'cat')

            expect(record).to validate_comparison_of(:attr).is_less_than('cat')
          end
        end

        context 'when comparison value is a proc returning an string' do
          it 'accepts' do
            record = build_record_validating_comparison(column_type: :string, less_than: -> (_record) { 'cat' })

            expect(record).to validate_comparison_of(:attr).is_less_than(-> (_record) { 'cat' })
          end
        end

        context 'when comparison value is a method returning an string' do
          it 'accepts' do
            record = build_record_validating_comparison(column_type: :string, less_than: :comparison_value)
            allow(record).to receive(:comparison_value).and_return('cat')

            expect(record).to validate_comparison_of(:attr).is_less_than(:comparison_value)
          end
        end

        context 'when the column is a date column' do
          it 'rejects and raise an error' do
            record = build_record_validating_comparison(column_type: :date, less_than: 'cat')

            assertion = lambda do
              expect(record).to validate_comparison_of(:attr).is_less_than('cat')
            end

            expect(&assertion).to fail_with_message(<<~MESSAGE)
Expected Example to validate that :attr looks like a value less than
cat, but this could not be proved.
  After setting :attr to ‹"cau"› -- which was read back as ‹nil› -- the
  matcher expected the Example to be invalid and to produce the
  validation error "must be less than cat" on :attr. The record was
  indeed invalid, but it produced these validation errors instead:

  * attr: ["can't be blank"]

  As indicated in the message above, :attr seems to be changing certain
  values as they are set, and this could have something to do with why
  this test is failing. If you've overridden the writer method for this
  attribute, then you may need to change it to make this test pass, or
  do something else entirely.
            MESSAGE
          end
        end
      end

      context 'qualified with is_greater_than' do
        context 'and validating with greater_than' do
          it 'accepts' do
            record = build_record_validating_comparison(column_type: :string, greater_than: 'cat')

            expect(record).to validate_comparison_of(:attr).is_greater_than('cat')
          end

          it 'rejects when used in the negative' do
            record = build_record_validating_comparison(column_type: :string, greater_than: 'cat')

            assertion = lambda do
              expect(record).not_to validate_comparison_of(:attr).is_greater_than('cat')
            end

            expect(&assertion).to fail_with_message(<<~MESSAGE)
Expected Example not to validate that :attr looks like a value greater
than cat, but this could not be proved.
  After setting :attr to ‹"cas"›, the matcher expected the Example to be
  valid, but it was invalid instead, producing these validation errors:

  * attr: ["must be greater than cat"]
            MESSAGE
          end

          it_supports(
            'ignoring_interference_by_writer',
            column_type: :string,
            tests: {
              reject_if_qualified_but_changing_value_interferes: {
                model_name: 'Example',
                attribute_name: :attr,
                changing_values_with: :previous_value,
                expected_message: <<-MESSAGE.strip,
Expected Example to validate that :attr looks like a value greater than
cat, but this could not be proved.
  After setting :attr to ‹"cau"› -- which was read back as ‹"cat"› --
  the matcher expected the Example to be valid, but it was invalid
  instead, producing these validation errors:

  * attr: ["must be greater than cat"]

  As indicated in the message above, :attr seems to be changing certain
  values as they are set, and this could have something to do with why
  this test is failing. If you've overridden the writer method for this
  attribute, then you may need to change it to make this test pass, or
  do something else entirely.
                MESSAGE
              },
            },
          ) do
            def validation_matcher_scenario_args
              super.deep_merge(validation_options: { greater_than: 'cat' })
            end

            def configure_validation_matcher(matcher)
              matcher.is_greater_than('cat')
            end
          end
        end

        context 'when the attribute is a virtual attribute in an ActiveRecord model' do
          it 'accepts' do
            record = build_record_validating_comparison_of_virtual_attribute(column_type: :string, greater_than: 'cat')

            expect(record).to validate_comparison_of(:attr).is_greater_than('cat')
          end
        end

        context 'when comparison value is a proc returning an string' do
          it 'accepts' do
            record = build_record_validating_comparison(column_type: :string, greater_than: -> (_record) { 'cat' })

            expect(record).to validate_comparison_of(:attr).is_greater_than(-> (_record) { 'cat' })
          end
        end

        context 'when comparison value is a method returning an string' do
          it 'accepts' do
            record = build_record_validating_comparison(column_type: :string, greater_than: :comparison_value)
            allow(record).to receive(:comparison_value).and_return('cat')

            expect(record).to validate_comparison_of(:attr).is_greater_than(:comparison_value)
          end
        end

        context 'when the column is a date column' do
          it 'rejects and raise an error' do
            record = build_record_validating_comparison(column_type: :date, greater_than: 'cat')

            assertion = lambda do
              expect(record).to validate_comparison_of(:attr).is_greater_than('cat')
            end

            expect(&assertion).to fail_with_message(<<~MESSAGE)
Expected Example to validate that :attr looks like a value greater than
cat, but this could not be proved.
  After setting :attr to ‹"cat"› -- which was read back as ‹nil› -- the
  matcher expected the Example to be invalid and to produce the
  validation error "must be greater than cat" on :attr. The record was
  indeed invalid, but it produced these validation errors instead:

  * attr: ["can't be blank"]

  As indicated in the message above, :attr seems to be changing certain
  values as they are set, and this could have something to do with why
  this test is failing. If you've overridden the writer method for this
  attribute, then you may need to change it to make this test pass, or
  do something else entirely.
            MESSAGE
          end
        end
      end

      context 'qualified with is_greater_than_or_equal_to' do
        context 'and validating with greater_than_or_equal_to' do
          it 'accepts' do
            record = build_record_validating_comparison(column_type: :string, greater_than_or_equal_to: 'cat')

            expect(record).to validate_comparison_of(:attr).is_greater_than_or_equal_to('cat')
          end

          it 'rejects when used in the negative' do
            record = build_record_validating_comparison(column_type: :string, greater_than_or_equal_to: 'cat')

            assertion = lambda do
              expect(record).not_to validate_comparison_of(:attr).is_greater_than_or_equal_to('cat')
            end

            expect(&assertion).to fail_with_message(<<~MESSAGE)
Expected Example not to validate that :attr looks like a value greater
than or equal to cat, but this could not be proved.
  After setting :attr to ‹"cas"›, the matcher expected the Example to be
  valid, but it was invalid instead, producing these validation errors:

  * attr: ["must be greater than or equal to cat"]
            MESSAGE
          end

          it_supports(
            'ignoring_interference_by_writer',
            column_type: :string,
            tests: {
              reject_if_qualified_but_changing_value_interferes: {
                model_name: 'Example',
                attribute_name: :attr,
                changing_values_with: :previous_value,
                expected_message: <<-MESSAGE.strip,
Expected Example to validate that :attr looks like a value greater than
or equal to cat, but this could not be proved.
  After setting :attr to ‹"cat"› -- which was read back as ‹"cas"› --
  the matcher expected the Example to be valid, but it was invalid
  instead, producing these validation errors:

  * attr: ["must be greater than or equal to cat"]

  As indicated in the message above, :attr seems to be changing certain
  values as they are set, and this could have something to do with why
  this test is failing. If you've overridden the writer method for this
  attribute, then you may need to change it to make this test pass, or
  do something else entirely.
                MESSAGE
              },
            },
          ) do
            def validation_matcher_scenario_args
              super.deep_merge(validation_options: { greater_than_or_equal_to: 'cat' })
            end

            def configure_validation_matcher(matcher)
              matcher.is_greater_than_or_equal_to('cat')
            end
          end
        end

        context 'when the attribute is a virtual attribute in an ActiveRecord model' do
          it 'accepts' do
            record = build_record_validating_comparison_of_virtual_attribute(column_type: :string, greater_than_or_equal_to: 'cat')

            expect(record).to validate_comparison_of(:attr).is_greater_than_or_equal_to('cat')
          end
        end

        context 'when comparison value is a proc returning an string' do
          it 'accepts' do
            record = build_record_validating_comparison(column_type: :string, greater_than_or_equal_to: -> (_record) { 'cat' })

            expect(record).to validate_comparison_of(:attr).is_greater_than_or_equal_to(-> (_record) { 'cat' })
          end
        end

        context 'when comparison value is a method returning an string' do
          it 'accepts' do
            record = build_record_validating_comparison(column_type: :string, greater_than_or_equal_to: :comparison_value)
            allow(record).to receive(:comparison_value).and_return('cat')

            expect(record).to validate_comparison_of(:attr).is_greater_than_or_equal_to(:comparison_value)
          end
        end

        context 'when the column is a date column' do
          it 'rejects and raise an error' do
            record = build_record_validating_comparison(column_type: :date, greater_than_or_equal_to: 'cat')

            assertion = lambda do
              expect(record).to validate_comparison_of(:attr).is_greater_than_or_equal_to('cat')
            end

            expect(&assertion).to fail_with_message(<<~MESSAGE)
Expected Example to validate that :attr looks like a value greater than
or equal to cat, but this could not be proved.
  After setting :attr to ‹"cas"› -- which was read back as ‹nil› -- the
  matcher expected the Example to be invalid and to produce the
  validation error "must be greater than or equal to cat" on :attr. The
  record was indeed invalid, but it produced these validation errors
  instead:

  * attr: ["can't be blank"]

  As indicated in the message above, :attr seems to be changing certain
  values as they are set, and this could have something to do with why
  this test is failing. If you've overridden the writer method for this
  attribute, then you may need to change it to make this test pass, or
  do something else entirely.
            MESSAGE
          end
        end
      end
    end

    context 'when comparing with an date' do
      context 'qualified with is_other_than' do
        context 'and validating with other_than' do
          it 'accepts' do
            date = Date.new(2023, 1, 1)
            record = build_record_validating_comparison(column_type: :date, other_than: date)

            expect(record).to validate_comparison_of(:attr).is_other_than(date)
          end

          it 'rejects when used in the negative' do
            date = Date.new(2023, 1, 1)
            record = build_record_validating_comparison(column_type: :date, other_than: date)

            assertion = lambda do
              expect(record).not_to validate_comparison_of(:attr).is_other_than(date)
            end

            expect(&assertion).to fail_with_message(<<~MESSAGE)
Expected Example not to validate that :attr looks like a value other
than 2023-01-01, but this could not be proved.
  After setting :attr to ‹"2023-01-01"› -- which was read back as ‹Sun,
  01 Jan 2023› -- the matcher expected the Example to be valid, but it
  was invalid instead, producing these validation errors:

  * attr: ["must be other than 2023-01-01"]

  As indicated in the message above, :attr seems to be changing certain
  values as they are set, and this could have something to do with why
  this test is failing. If you've overridden the writer method for this
  attribute, then you may need to change it to make this test pass, or
  do something else entirely.
            MESSAGE
          end

          it_supports(
            'ignoring_interference_by_writer',
            column_type: :date,
            tests: {
              reject_if_qualified_but_changing_value_interferes: {
                model_name: 'Example',
                attribute_name: :attr,
                changing_values_with: :previous_value,
                expected_message: <<-MESSAGE.strip,
Expected Example to validate that :attr looks like a value other than
2023-01-01, but this could not be proved.
  After setting :attr to ‹"2023-01-02"› -- which was read back as ‹Sun,
  01 Jan 2023› -- the matcher expected the Example to be valid, but it
  was invalid instead, producing these validation errors:

  * attr: ["must be other than 2023-01-01"]

  As indicated in the message above, :attr seems to be changing certain
  values as they are set, and this could have something to do with why
  this test is failing. If you've overridden the writer method for this
  attribute, then you may need to change it to make this test pass, or
  do something else entirely.
                MESSAGE
              },
            },
          ) do
            def validation_matcher_scenario_args
              super.deep_merge(validation_options: { other_than: Date.new(2023, 1, 1) })
            end

            def configure_validation_matcher(matcher)
              matcher.is_other_than(Date.new(2023, 1, 1))
            end
          end
        end

        context 'when the attribute is a virtual attribute in an ActiveRecord model' do
          it 'accepts' do
            date = Date.new(2023, 1, 1)
            record = build_record_validating_comparison_of_virtual_attribute(column_type: :date, other_than: date)

            expect(record).to validate_comparison_of(:attr).is_other_than(date)
          end
        end

        context 'when comparison value is a proc returning an Date' do
          it 'accepts' do
            date = Date.new(2023, 1, 1)
            record = build_record_validating_comparison(column_type: :date, other_than: -> (_record) { date })

            expect(record).to validate_comparison_of(:attr).is_other_than(-> (_record) { date })
          end
        end

        context 'when comparison value is a method returning an Date' do
          it 'accepts' do
            date = Date.new(2023, 1, 1)
            record = build_record_validating_comparison(column_type: :date, other_than: :comparison_value)
            allow(record).to receive(:comparison_value).and_return(date)

            expect(record).to validate_comparison_of(:attr).is_other_than(:comparison_value)
          end
        end

        context 'when the column is an integer column' do
          it 'rejects and raise an error' do
            date = Date.new(2023, 1, 1)
            record = build_record_validating_comparison(column_type: :integer, other_than: date)

            assertion = lambda do
              expect(record).to validate_comparison_of(:attr).is_other_than(date)
            end

            expect(&assertion).to fail_with_message(<<~MESSAGE)
Expected Example to validate that :attr looks like a value other than
2023-01-01, but this could not be proved.
  After setting :attr to ‹Sun, 01 Jan 2023› -- which was read back as
  ‹nil› -- the matcher expected the Example to be invalid and to produce
  the validation error "must be other than 2023-01-01" on :attr. The
  record was indeed invalid, but it produced these validation errors
  instead:

  * attr: ["can't be blank"]

  As indicated in the message above, :attr seems to be changing certain
  values as they are set, and this could have something to do with why
  this test is failing. If you've overridden the writer method for this
  attribute, then you may need to change it to make this test pass, or
  do something else entirely.
            MESSAGE
          end
        end
      end

      context 'qualified with is_equal_to' do
        context 'and validating with is_equal_to' do
          it 'accepts' do
            date = Date.new(2023, 1, 1)
            record = build_record_validating_comparison(column_type: :date, equal_to: date)

            expect(record).to validate_comparison_of(:attr).is_equal_to(date)
          end

          it 'rejects when used in the negative' do
            date = Date.new(2023, 1, 1)
            record = build_record_validating_comparison(column_type: :date, equal_to: date)

            assertion = lambda do
              expect(record).not_to validate_comparison_of(:attr).is_equal_to(date)
            end

            expect(&assertion).to fail_with_message(<<~MESSAGE)
Expected Example not to validate that :attr looks like a value equal to
2023-01-01, but this could not be proved.
  After setting :attr to ‹"2022-12-31"› -- which was read back as ‹Sat,
  31 Dec 2022› -- the matcher expected the Example to be valid, but it
  was invalid instead, producing these validation errors:

  * attr: ["must be equal to 2023-01-01"]

  As indicated in the message above, :attr seems to be changing certain
  values as they are set, and this could have something to do with why
  this test is failing. If you've overridden the writer method for this
  attribute, then you may need to change it to make this test pass, or
  do something else entirely.
            MESSAGE
          end

          it_supports(
            'ignoring_interference_by_writer',
            column_type: :date,
            tests: {
              reject_if_qualified_but_changing_value_interferes: {
                model_name: 'Example',
                attribute_name: :attr,
                changing_values_with: :next_value_or_numeric_value,
                expected_message: <<-MESSAGE.strip,
Expected Example to validate that :attr looks like a value equal to
2023-01-01, but this could not be proved.
  After setting :attr to ‹"2023-01-01"› -- which was read back as ‹Mon,
  02 Jan 2023› -- the matcher expected the Example to be valid, but it
  was invalid instead, producing these validation errors:

  * attr: ["must be equal to 2023-01-01"]

  As indicated in the message above, :attr seems to be changing certain
  values as they are set, and this could have something to do with why
  this test is failing. If you've overridden the writer method for this
  attribute, then you may need to change it to make this test pass, or
  do something else entirely.
                MESSAGE
              },
            },
          ) do
            def validation_matcher_scenario_args
              super.deep_merge(validation_options: { equal_to: Date.new(2023, 1, 1) })
            end

            def configure_validation_matcher(matcher)
              matcher.is_equal_to(Date.new(2023, 1, 1))
            end
          end
        end

        context 'when the attribute is a virtual attribute in an ActiveRecord model' do
          it 'accepts' do
            date = Date.new(2023, 1, 1)
            record = build_record_validating_comparison_of_virtual_attribute(column_type: :date, equal_to: date)

            expect(record).to validate_comparison_of(:attr).is_equal_to(date)
          end
        end

        context 'when comparison value is a proc returning an Date' do
          it 'accepts' do
            date = Date.new(2023, 1, 1)
            record = build_record_validating_comparison(column_type: :date, equal_to: -> (_record) { date })

            expect(record).to validate_comparison_of(:attr).is_equal_to(-> (_record) { date })
          end
        end

        context 'when comparison value is a method returning an Date' do
          it 'accepts' do
            date = Date.new(2023, 1, 1)
            record = build_record_validating_comparison(column_type: :date, equal_to: :comparison_value)
            allow(record).to receive(:comparison_value).and_return(date)

            expect(record).to validate_comparison_of(:attr).is_equal_to(:comparison_value)
          end
        end

        context 'when the column is an integer column' do
          it 'rejects and raise an error' do
            date = Date.new(2023, 1, 1)
            record = build_record_validating_comparison(column_type: :integer, equal_to: date)

            assertion = lambda do
              expect(record).to validate_comparison_of(:attr).is_equal_to(date)
            end

            expect(&assertion).to fail_with_message(<<~MESSAGE)
Expected Example to validate that :attr looks like a value equal to
2023-01-01, but this could not be proved.
  After setting :attr to ‹Mon, 02 Jan 2023› -- which was read back as
  ‹nil› -- the matcher expected the Example to be invalid and to produce
  the validation error "must be equal to 2023-01-01" on :attr. The
  record was indeed invalid, but it produced these validation errors
  instead:

  * attr: ["can't be blank"]

  As indicated in the message above, :attr seems to be changing certain
  values as they are set, and this could have something to do with why
  this test is failing. If you've overridden the writer method for this
  attribute, then you may need to change it to make this test pass, or
  do something else entirely.
            MESSAGE
          end
        end
      end

      context 'qualified with less_than_or_equal_to' do
        context 'and validating with is_less_than_or_equal_to' do
          it 'accepts' do
            date = Date.new(2023, 1, 1)
            record = build_record_validating_comparison(column_type: :date, less_than_or_equal_to: date)

            expect(record).to validate_comparison_of(:attr).is_less_than_or_equal_to(date)
          end

          it 'rejects when used in the negative' do
            date = Date.new(2023, 1, 1)
            record = build_record_validating_comparison(column_type: :date, less_than_or_equal_to: date)

            assertion = lambda do
              expect(record).not_to validate_comparison_of(:attr).is_less_than_or_equal_to(date)
            end

            expect(&assertion).to fail_with_message(<<~MESSAGE)
Expected Example not to validate that :attr looks like a value less than
or equal to 2023-01-01, but this could not be proved.
  After setting :attr to ‹"2023-01-02"› -- which was read back as ‹Mon,
  02 Jan 2023› -- the matcher expected the Example to be valid, but it
  was invalid instead, producing these validation errors:

  * attr: ["must be less than or equal to 2023-01-01"]

  As indicated in the message above, :attr seems to be changing certain
  values as they are set, and this could have something to do with why
  this test is failing. If you've overridden the writer method for this
  attribute, then you may need to change it to make this test pass, or
  do something else entirely.
            MESSAGE
          end

          it_supports(
            'ignoring_interference_by_writer',
            column_type: :date,
            tests: {
              reject_if_qualified_but_changing_value_interferes: {
                model_name: 'Example',
                attribute_name: :attr,
                changing_values_with: :next_value_or_numeric_value,
                expected_message: <<-MESSAGE.strip,
Expected Example to validate that :attr looks like a value less than or
equal to 2023-01-01, but this could not be proved.
  After setting :attr to ‹"2023-01-01"› -- which was read back as ‹Mon,
  02 Jan 2023› -- the matcher expected the Example to be valid, but it
  was invalid instead, producing these validation errors:

  * attr: ["must be less than or equal to 2023-01-01"]

  As indicated in the message above, :attr seems to be changing certain
  values as they are set, and this could have something to do with why
  this test is failing. If you've overridden the writer method for this
  attribute, then you may need to change it to make this test pass, or
  do something else entirely.
                MESSAGE
              },
            },
          ) do
            def validation_matcher_scenario_args
              super.deep_merge(validation_options: { less_than_or_equal_to: Date.new(2023, 1, 1) })
            end

            def configure_validation_matcher(matcher)
              matcher.is_less_than_or_equal_to(Date.new(2023, 1, 1))
            end
          end
        end

        context 'when the attribute is a virtual attribute in an ActiveRecord model' do
          it 'accepts' do
            date = Date.new(2023, 1, 1)
            record = build_record_validating_comparison_of_virtual_attribute(column_type: :date, less_than_or_equal_to: date)

            expect(record).to validate_comparison_of(:attr).is_less_than_or_equal_to(date)
          end
        end

        context 'when comparison value is a proc returning an Date' do
          it 'accepts' do
            date = Date.new(2023, 1, 1)
            record = build_record_validating_comparison(column_type: :date, less_than_or_equal_to: -> (_record) { date })

            expect(record).to validate_comparison_of(:attr).is_less_than_or_equal_to(-> (_record) { date })
          end
        end

        context 'when comparison value is a method returning an Date' do
          it 'accepts' do
            date = Date.new(2023, 1, 1)
            record = build_record_validating_comparison(column_type: :date, less_than_or_equal_to: :comparison_value)
            allow(record).to receive(:comparison_value).and_return(date)

            expect(record).to validate_comparison_of(:attr).is_less_than_or_equal_to(:comparison_value)
          end
        end

        context 'when the column is an integer column' do
          it 'rejects and raise an error' do
            date = Date.new(2023, 1, 1)
            record = build_record_validating_comparison(column_type: :integer, less_than_or_equal_to: date)

            assertion = lambda do
              expect(record).to validate_comparison_of(:attr).is_less_than_or_equal_to(date)
            end

            expect(&assertion).to fail_with_message(<<~MESSAGE)
Expected Example to validate that :attr looks like a value less than or
equal to 2023-01-01, but this could not be proved.
  After setting :attr to ‹Mon, 02 Jan 2023› -- which was read back as
  ‹nil› -- the matcher expected the Example to be invalid and to produce
  the validation error "must be less than or equal to 2023-01-01" on
  :attr. The record was indeed invalid, but it produced these validation
  errors instead:

  * attr: ["can't be blank"]

  As indicated in the message above, :attr seems to be changing certain
  values as they are set, and this could have something to do with why
  this test is failing. If you've overridden the writer method for this
  attribute, then you may need to change it to make this test pass, or
  do something else entirely.
            MESSAGE
          end
        end
      end

      context 'qualified with less_than' do
        context 'and validating with is_less' do
          it 'accepts' do
            date = Date.new(2023, 1, 1)
            record = build_record_validating_comparison(column_type: :date, less_than: date)

            expect(record).to validate_comparison_of(:attr).is_less_than(date)
          end

          it 'rejects when used in the negative' do
            date = Date.new(2023, 1, 1)
            record = build_record_validating_comparison(column_type: :date, less_than: date)

            assertion = lambda do
              expect(record).not_to validate_comparison_of(:attr).is_less_than(date)
            end

            expect(&assertion).to fail_with_message(<<~MESSAGE)
Expected Example not to validate that :attr looks like a value less than
2023-01-01, but this could not be proved.
  After setting :attr to ‹"2023-01-01"› -- which was read back as ‹Sun,
  01 Jan 2023› -- the matcher expected the Example to be valid, but it
  was invalid instead, producing these validation errors:

  * attr: ["must be less than 2023-01-01"]

  As indicated in the message above, :attr seems to be changing certain
  values as they are set, and this could have something to do with why
  this test is failing. If you've overridden the writer method for this
  attribute, then you may need to change it to make this test pass, or
  do something else entirely.
            MESSAGE
          end

          it_supports(
            'ignoring_interference_by_writer',
            column_type: :date,
            tests: {
              reject_if_qualified_but_changing_value_interferes: {
                model_name: 'Example',
                attribute_name: :attr,
                changing_values_with: :next_value,
                expected_message: <<-MESSAGE.strip,
Expected Example to validate that :attr looks like a value less than
2023-01-01, but this could not be proved.
  After setting :attr to ‹"2022-12-31"› -- which was read back as ‹Sun,
  01 Jan 2023› -- the matcher expected the Example to be valid, but it
  was invalid instead, producing these validation errors:

  * attr: ["must be less than 2023-01-01"]

  As indicated in the message above, :attr seems to be changing certain
  values as they are set, and this could have something to do with why
  this test is failing. If you've overridden the writer method for this
  attribute, then you may need to change it to make this test pass, or
  do something else entirely.
                MESSAGE
              },
            },
          ) do
            def validation_matcher_scenario_args
              super.deep_merge(validation_options: { less_than: Date.new(2023, 1, 1) })
            end

            def configure_validation_matcher(matcher)
              matcher.is_less_than(Date.new(2023, 1, 1))
            end
          end
        end

        context 'when the attribute is a virtual attribute in an ActiveRecord model' do
          it 'accepts' do
            date = Date.new(2023, 1, 1)
            record = build_record_validating_comparison_of_virtual_attribute(column_type: :date, less_than: date)

            expect(record).to validate_comparison_of(:attr).is_less_than(date)
          end
        end

        context 'when comparison value is a proc returning an Date' do
          it 'accepts' do
            date = Date.new(2023, 1, 1)
            record = build_record_validating_comparison(column_type: :date, less_than: -> (_record) { date })

            expect(record).to validate_comparison_of(:attr).is_less_than(-> (_record) { date })
          end
        end

        context 'when comparison value is a method returning an Date' do
          it 'accepts' do
            date = Date.new(2023, 1, 1)
            record = build_record_validating_comparison(column_type: :date, less_than: :comparison_value)
            allow(record).to receive(:comparison_value).and_return(date)

            expect(record).to validate_comparison_of(:attr).is_less_than(:comparison_value)
          end
        end

        context 'when the column is an integer column' do
          it 'rejects and raise an error' do
            date = Date.new(2023, 1, 1)
            record = build_record_validating_comparison(column_type: :integer, less_than: date)

            assertion = lambda do
              expect(record).to validate_comparison_of(:attr).is_less_than(date)
            end

            expect(&assertion).to fail_with_message(<<~MESSAGE)
Expected Example to validate that :attr looks like a value less than
2023-01-01, but this could not be proved.
  After setting :attr to ‹Mon, 02 Jan 2023› -- which was read back as
  ‹nil› -- the matcher expected the Example to be invalid and to produce
  the validation error "must be less than 2023-01-01" on :attr. The
  record was indeed invalid, but it produced these validation errors
  instead:

  * attr: ["can't be blank"]

  As indicated in the message above, :attr seems to be changing certain
  values as they are set, and this could have something to do with why
  this test is failing. If you've overridden the writer method for this
  attribute, then you may need to change it to make this test pass, or
  do something else entirely.
            MESSAGE
          end
        end
      end

      context 'qualified with greater_than' do
        context 'and validating with is_greater_than' do
          it 'accepts' do
            date = Date.new(2023, 1, 1)
            record = build_record_validating_comparison(column_type: :date, greater_than: date)

            expect(record).to validate_comparison_of(:attr).is_greater_than(date)
          end

          it 'rejects when used in the negative' do
            date = Date.new(2023, 1, 1)
            record = build_record_validating_comparison(column_type: :date, greater_than: date)

            assertion = lambda do
              expect(record).not_to validate_comparison_of(:attr).is_greater_than(date)
            end

            expect(&assertion).to fail_with_message(<<~MESSAGE)
Expected Example not to validate that :attr looks like a value greater
than 2023-01-01, but this could not be proved.
  After setting :attr to ‹"2022-12-31"› -- which was read back as ‹Sat,
  31 Dec 2022› -- the matcher expected the Example to be valid, but it
  was invalid instead, producing these validation errors:

  * attr: ["must be greater than 2023-01-01"]

  As indicated in the message above, :attr seems to be changing certain
  values as they are set, and this could have something to do with why
  this test is failing. If you've overridden the writer method for this
  attribute, then you may need to change it to make this test pass, or
  do something else entirely.
            MESSAGE
          end

          it_supports(
            'ignoring_interference_by_writer',
            column_type: :date,
            tests: {
              reject_if_qualified_but_changing_value_interferes: {
                model_name: 'Example',
                attribute_name: :attr,
                changing_values_with: :previous_value,
                expected_message: <<-MESSAGE.strip,
Expected Example to validate that :attr looks like a value greater than
2023-01-01, but this could not be proved.
  After setting :attr to ‹"2023-01-02"› -- which was read back as ‹Sun,
  01 Jan 2023› -- the matcher expected the Example to be valid, but it
  was invalid instead, producing these validation errors:

  * attr: ["must be greater than 2023-01-01"]

  As indicated in the message above, :attr seems to be changing certain
  values as they are set, and this could have something to do with why
  this test is failing. If you've overridden the writer method for this
  attribute, then you may need to change it to make this test pass, or
  do something else entirely.
                MESSAGE
              },
            },
          ) do
            def validation_matcher_scenario_args
              super.deep_merge(validation_options: { greater_than: Date.new(2023, 1, 1) })
            end

            def configure_validation_matcher(matcher)
              matcher.is_greater_than(Date.new(2023, 1, 1))
            end
          end
        end

        context 'when the attribute is a virtual attribute in an ActiveRecord model' do
          it 'accepts' do
            date = Date.new(2023, 1, 1)
            record = build_record_validating_comparison_of_virtual_attribute(column_type: :date, greater_than: date)

            expect(record).to validate_comparison_of(:attr).is_greater_than(date)
          end
        end

        context 'when comparison value is a proc returning an Date' do
          it 'accepts' do
            date = Date.new(2023, 1, 1)
            record = build_record_validating_comparison(column_type: :date, greater_than: -> (_record) { date })

            expect(record).to validate_comparison_of(:attr).is_greater_than(-> (_record) { date })
          end
        end

        context 'when comparison value is a method returning an Date' do
          it 'accepts' do
            date = Date.new(2023, 1, 1)
            record = build_record_validating_comparison(column_type: :date, greater_than: :comparison_value)
            allow(record).to receive(:comparison_value).and_return(date)

            expect(record).to validate_comparison_of(:attr).is_greater_than(:comparison_value)
          end
        end

        context 'when the column is an integer column' do
          it 'rejects and raise an error' do
            date = Date.new(2023, 1, 1)
            record = build_record_validating_comparison(column_type: :integer, greater_than: date)

            assertion = lambda do
              expect(record).to validate_comparison_of(:attr).is_greater_than(date)
            end

            expect(&assertion).to fail_with_message(<<~MESSAGE)
Expected Example to validate that :attr looks like a value greater than
2023-01-01, but this could not be proved.
  After setting :attr to ‹Sun, 01 Jan 2023› -- which was read back as
  ‹nil› -- the matcher expected the Example to be invalid and to produce
  the validation error "must be greater than 2023-01-01" on :attr. The
  record was indeed invalid, but it produced these validation errors
  instead:

  * attr: ["can't be blank"]

  As indicated in the message above, :attr seems to be changing certain
  values as they are set, and this could have something to do with why
  this test is failing. If you've overridden the writer method for this
  attribute, then you may need to change it to make this test pass, or
  do something else entirely.
            MESSAGE
          end
        end
      end

      context 'qualified with greater_than_or_equal_to' do
        context 'and validating with is_greater_than_or_equal_to' do
          it 'accepts' do
            date = Date.new(2023, 1, 1)
            record = build_record_validating_comparison(column_type: :date, greater_than_or_equal_to: date)

            expect(record).to validate_comparison_of(:attr).is_greater_than_or_equal_to(date)
          end

          it 'rejects when used in the negative' do
            date = Date.new(2023, 1, 1)
            record = build_record_validating_comparison(column_type: :date, greater_than_or_equal_to: date)

            assertion = lambda do
              expect(record).not_to validate_comparison_of(:attr).is_greater_than_or_equal_to(date)
            end

            expect(&assertion).to fail_with_message(<<~MESSAGE)
Expected Example not to validate that :attr looks like a value greater
than or equal to 2023-01-01, but this could not be proved.
  After setting :attr to ‹"2022-12-31"› -- which was read back as ‹Sat,
  31 Dec 2022› -- the matcher expected the Example to be valid, but it
  was invalid instead, producing these validation errors:

  * attr: ["must be greater than or equal to 2023-01-01"]

  As indicated in the message above, :attr seems to be changing certain
  values as they are set, and this could have something to do with why
  this test is failing. If you've overridden the writer method for this
  attribute, then you may need to change it to make this test pass, or
  do something else entirely.
            MESSAGE
          end

          it_supports(
            'ignoring_interference_by_writer',
            column_type: :date,
            tests: {
              reject_if_qualified_but_changing_value_interferes: {
                model_name: 'Example',
                attribute_name: :attr,
                changing_values_with: :previous_value,
                expected_message: <<-MESSAGE.strip,
Expected Example to validate that :attr looks like a value greater than
or equal to 2023-01-01, but this could not be proved.
  After setting :attr to ‹"2023-01-01"› -- which was read back as ‹Sat,
  31 Dec 2022› -- the matcher expected the Example to be valid, but it
  was invalid instead, producing these validation errors:

  * attr: ["must be greater than or equal to 2023-01-01"]

  As indicated in the message above, :attr seems to be changing certain
  values as they are set, and this could have something to do with why
  this test is failing. If you've overridden the writer method for this
  attribute, then you may need to change it to make this test pass, or
  do something else entirely.
                MESSAGE
              },
            },
          ) do
            def validation_matcher_scenario_args
              super.deep_merge(validation_options: { greater_than_or_equal_to: Date.new(2023, 1, 1) })
            end

            def configure_validation_matcher(matcher)
              matcher.is_greater_than_or_equal_to(Date.new(2023, 1, 1))
            end
          end
        end

        context 'when the attribute is a virtual attribute in an ActiveRecord model' do
          it 'accepts' do
            date = Date.new(2023, 1, 1)
            record = build_record_validating_comparison_of_virtual_attribute(column_type: :date, greater_than_or_equal_to: date)

            expect(record).to validate_comparison_of(:attr).is_greater_than_or_equal_to(date)
          end
        end

        context 'when comparison value is a proc returning an Date' do
          it 'accepts' do
            date = Date.new(2023, 1, 1)
            record = build_record_validating_comparison(column_type: :date, greater_than_or_equal_to: -> (_record) { date })

            expect(record).to validate_comparison_of(:attr).is_greater_than_or_equal_to(-> (_record) { date })
          end
        end

        context 'when comparison value is a method returning an Date' do
          it 'accepts' do
            date = Date.new(2023, 1, 1)
            record = build_record_validating_comparison(column_type: :date, greater_than_or_equal_to: :comparison_value)
            allow(record).to receive(:comparison_value).and_return(date)

            expect(record).to validate_comparison_of(:attr).is_greater_than_or_equal_to(:comparison_value)
          end
        end

        context 'when the column is an integer column' do
          it 'rejects and raise an error' do
            date = Date.new(2023, 1, 1)
            record = build_record_validating_comparison(column_type: :integer, greater_than_or_equal_to: date)

            assertion = lambda do
              expect(record).to validate_comparison_of(:attr).is_greater_than_or_equal_to(date)
            end

            expect(&assertion).to fail_with_message(<<~MESSAGE)
Expected Example to validate that :attr looks like a value greater than
or equal to 2023-01-01, but this could not be proved.
  After setting :attr to ‹Sat, 31 Dec 2022› -- which was read back as
  ‹nil› -- the matcher expected the Example to be invalid and to produce
  the validation error "must be greater than or equal to 2023-01-01" on
  :attr. The record was indeed invalid, but it produced these validation
  errors instead:

  * attr: ["can't be blank"]

  As indicated in the message above, :attr seems to be changing certain
  values as they are set, and this could have something to do with why
  this test is failing. If you've overridden the writer method for this
  attribute, then you may need to change it to make this test pass, or
  do something else entirely.
            MESSAGE
          end
        end
      end
    end

    context 'qualified with allow_nil' do
      context 'and validating with allow_nil' do
        it 'accepts' do
          record = build_record_validating_comparison(column_type: :integer, greater_than: 10, allow_nil: true)
          expect(record).to validate_comparison.is_greater_than(10).allow_nil
        end

        context 'and not validating with allow_nil' do
          it 'rejects since it tries to treat nil as a number' do
            record = build_record_validating_comparison(column_type: :integer, greater_than: 10)

            assertion = lambda do
              expect(record).to validate_comparison.is_greater_than(10).allow_nil
            end

            message = <<-MESSAGE
Expected Example to validate that :attr looks like a value greater than
10 and as long as it is not nil, but this could not be proved.
  After setting :attr to ‹nil›, the matcher expected the Example to be
  valid, but it was invalid instead, producing these validation errors:

  * attr: ["can't be blank"]
            MESSAGE

            expect(&assertion).to fail_with_message(message)
          end
        end
      end
    end

    context 'qualified with strict' do
      context 'and validating strictly' do
        it 'accepts' do
          record = build_record_validating_comparison(column_type: :integer, greater_than: 10, strict: true)

          expect(record).to validate_comparison.is_greater_than(10).strict
        end
      end

      context 'and not validating strictly' do
        it 'rejects since ActiveModel::StrictValidationFailed is never raised' do
          record = build_record_validating_comparison(column_type: :integer, greater_than: 10)

          assertion = lambda do
            expect(record).to validate_comparison.is_greater_than(10).strict
          end

          message = <<-MESSAGE
Expected Example to validate that :attr looks like a value greater than
10, raising a validation exception on failure, but this could not be
proved.
  After setting :attr to ‹10›, the matcher expected the Example to be
  invalid and to raise a validation exception, but the record produced
  validation errors instead.
          MESSAGE

          expect(&assertion).to fail_with_message(message)
        end
      end
    end

    context 'qualified with on' do
      context 'qualified with on and validating with on' do
        it 'accepts' do
          record = build_record_validating_comparison(column_type: :integer, greater_than: 10, on: :customizable)
          expect(record).to validate_comparison.is_greater_than(10).on(:customizable)
        end
      end

      context 'qualified with on but not validating with on' do
        it 'accepts since the validation never considers a context' do
          record = build_record_validating_comparison(column_type: :integer, greater_than: 10)
          expect(record).to validate_comparison.is_greater_than(10).on(:customizable)
        end
      end

      context 'not qualified with on but validating with on' do
        it 'rejects since the validation never runs' do
          record = build_record_validating_comparison(column_type: :integer, greater_than: 10, on: :customizable)

          assertion = lambda do
            expect(record).to validate_comparison.is_greater_than(10)
          end

          message = <<-MESSAGE
Expected Example to validate that :attr looks like a value greater than
10, but this could not be proved.
  After setting :attr to ‹10›, the matcher expected the Example to be
  invalid, but it was valid instead.
          MESSAGE

          expect(&assertion).to fail_with_message(message)
        end
      end

      context 'qualified with on but without another qualifier' do
        it 'rejects since the validation never runs' do
          record = build_record_validating_comparison(column_type: :integer, greater_than: 10, on: :customizable)

          assertion = lambda do
            expect(record).to validate_comparison.is_greater_than(10)
          end

          message = <<-MESSAGE
Expected Example to validate that :attr looks like a value greater than
10, but this could not be proved.
  After setting :attr to ‹10›, the matcher expected the Example to be
  invalid, but it was valid instead.
          MESSAGE

          expect(&assertion).to fail_with_message(message)
        end
      end
    end

    context 'qualified with with_message' do
      context 'and validating with the same message' do
        it 'accepts' do
          record = build_record_validating_comparison(column_type: :integer, greater_than: 10, message: 'custom')
          expect(record).to validate_comparison.is_greater_than(10).with_message(/custom/)
        end
      end

      context 'and validating with a different message' do
        it 'rejects with the correct failure message' do
          record = build_record_validating_comparison(column_type: :integer, greater_than: 10, message: 'custom')

          assertion = lambda do
            expect(record).to validate_comparison.is_greater_than(10).with_message(/wrong/)
          end

          message = <<-MESSAGE
Expected Example to validate that :attr looks like a value greater than
10, producing a custom validation error on failure, but this could not
be proved.
  After setting :attr to ‹10›, the matcher expected the Example to be
  invalid and to produce a validation error matching ‹/wrong/› on :attr.
  The record was indeed invalid, but it produced these validation errors
  instead:

  * attr: ["custom"]
          MESSAGE

          expect(&assertion).to fail_with_message(message)
        end
      end

      context 'and no message is provided' do
        it 'ignores the qualifier' do
          record = build_record_validating_comparison(column_type: :integer, greater_than: 10)
          expect(record).to validate_comparison.is_greater_than(10).with_message(nil)
        end
      end
    end

    context 'when no comparison qualified is provided' do
      it 'raises error' do
        record = define_model_validating_nothing

        assertion = lambda do
          expect(record).to validate_comparison
        end

        expect(&assertion).to raise_error(ArgumentError, "matcher isn't qualified with any comparison matcher")
      end
    end

    def build_record_validating_comparison(options = {})
      define_model_validating_comparison_of_attribute(options).new
    end

    def build_record_validating_comparison_of_virtual_attribute(options = {})
      define_model_validating_comparison_of_virtual_attribute(options).new
    end

    def define_model_validating_comparison_of_virtual_attribute(options = {})
      attribute_name = options.delete(:attribute_name) { self.attribute_name }
      column_type = options.delete(:column_type) { :string }

      define_model 'Example' do |model|
        model.send(:attribute, attribute_name, column_type)
        model.validates_comparison_of(attribute_name, options)
      end
    end

    def define_model_validating_comparison_of_attribute(options = {})
      attribute_name = options.delete(:attribute_name) { self.attribute_name }
      column_type = options.delete(:column_type) { :string }

      define_model 'Example', attribute_name => { type: column_type } do |model|
        model.validates_comparison_of(attribute_name, options)
      end
    end

    def define_model_validating_nothing
      define_model('Example', attribute_name => :string)
    end

    def validate_comparison
      validate_comparison_of(attribute_name)
    end

    def attribute_name
      :attr
    end

    def validation_matcher_scenario_args
      super.deep_merge(
        matcher_name: :validate_comparison_of,
        model_creator: :active_record,
      )
    end
  end
end
