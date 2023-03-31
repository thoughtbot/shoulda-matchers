require 'unit_spec_helper'

describe Shoulda::Matchers::ActiveModel::ValidateComparisonOfMatcher, type: :model do
  context 'when comparing with an integer' do
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
Expected Example not to validate that :attr looks like a number less
than 10, but this could not be proved.
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
Expected Example to validate that :attr looks like a number less than
10, but this could not be proved.
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

      context 'when the column is an string column' do
        it 'rejects and raise an error' do
          record = build_record_validating_comparison(column_type: :string, less_than: 10)

          assertion = lambda do
            expect(record).to validate_comparison_of(:attr).is_less_than(10)
          end

          expect(&assertion).to fail_with_message(<<~MESSAGE)
Expected Example to validate that :attr looks like a number less than
10, but this could not be proved.
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
Expected Example to validate that :attr looks like a number less than
10, but this could not be proved.
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
Expected Example not to validate that :attr looks like a number greater
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
Expected Example to validate that :attr looks like a number greater than
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

      context 'when the column is an string column' do
        it 'rejects and raise an error' do
          record = build_record_validating_comparison(column_type: :string, greater_than: 10)

          assertion = lambda do
            expect(record).to validate_comparison_of(:attr).is_greater_than(10)
          end

          expect(&assertion).to fail_with_message(<<~MESSAGE)
Expected Example to validate that :attr looks like a number greater than
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
Expected Example to validate that :attr looks like a number greater than
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
Expected Example not to validate that :attr looks like a number greater
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
Expected Example to validate that :attr looks like a number greater than
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

      context 'when the column is an string column' do
        it 'rejects and raise an error' do
          record = build_record_validating_comparison(column_type: :string, greater_than_or_equal_to: 10)

          assertion = lambda do
            expect(record).to validate_comparison_of(:attr).is_greater_than_or_equal_to(10)
          end

          expect(&assertion).to fail_with_message(<<~MESSAGE)
Expected Example to validate that :attr looks like a number greater than
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
Expected Example to validate that :attr looks like a number greater than
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
