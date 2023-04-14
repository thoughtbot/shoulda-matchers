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
      context 'qualified with other_than' do
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

      context 'qualified with equal_to' do
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

      context 'qualified with is_less_than_or_equal_to' do
        context 'and validating with less_than_or_equal_to' do
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
      context 'qualified with other_than' do
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

      context 'qualified with equal_to' do
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

      context 'qualified with is_less_than_or_equal_to_to' do
        context 'and validating with equal_to' do
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
