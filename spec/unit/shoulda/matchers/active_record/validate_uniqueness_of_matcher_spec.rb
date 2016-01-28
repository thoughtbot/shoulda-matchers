require 'unit_spec_helper'

describe Shoulda::Matchers::ActiveRecord::ValidateUniquenessOfMatcher, type: :model do
  shared_context 'it supports scoped attributes of a certain type' do |options = {}|
    column_type = options.fetch(:column_type)
    value_type = options.fetch(:value_type, column_type)
    array = options.fetch(:array, false)

    context 'when the correct scope is specified' do
      context 'when the subject is a new record' do
        it 'accepts' do
          record = build_record_validating_uniqueness(
            scopes: [
              build_attribute(name: :scope1),
              { name: :scope2 }
            ]
          )
          expect(record).to validate_uniqueness.scoped_to(:scope1, :scope2)
        end

        it 'still accepts if the scope is unset beforehand' do
          record = build_record_validating_uniqueness(
            scopes: [ build_attribute(name: :scope, value: nil) ]
          )

          expect(record).to validate_uniqueness.scoped_to(:scope)
        end
      end

      context 'when the subject is an existing record' do
        it 'accepts' do
          record = create_record_validating_uniqueness(
            scopes: [
              build_attribute(name: :scope1),
              { name: :scope2 }
            ]
          )

          expect(record).to validate_uniqueness.scoped_to(:scope1, :scope2)
        end

        it 'still accepts if the scope is unset beforehand' do
          record = create_record_validating_uniqueness(
            scopes: [ build_attribute(name: :scope, value: nil) ]
          )

          expect(record).to validate_uniqueness.scoped_to(:scope)
        end
      end
    end

    context "when more than one record exists that has the next version of the attribute's value" do
      it 'accepts' do
        value1 = dummy_value_for(value_type, array: array)
        value2 = next_version_of(value1, value_type)
        value3 = next_version_of(value2, value_type)
        model = define_model_validating_uniqueness(
          scopes: [ build_attribute(name: :scope) ]
        )
        create_record_from(model, scope: value2)
        create_record_from(model, scope: value3)
        record = build_record_from(model, scope: value1)

        expect(record).to validate_uniqueness.scoped_to(:scope)
      end
    end

    context 'when too narrow of a scope is specified' do
      it 'rejects with an appropriate failure message' do
        record = build_record_validating_uniqueness(
          scopes: [
            build_attribute(name: :scope1),
            build_attribute(name: :scope2)
          ],
          additional_attributes: [:other]
        )

        assertion = lambda do
          expect(record).
            to validate_uniqueness.
            scoped_to(:scope1, :scope2, :other)
        end

        message = <<-MESSAGE
Example did not properly validate that :attr is case-sensitively unique
within the scope of :scope1, :scope2, and :other.
  Expected the validation to be scoped to :scope1, :scope2, and :other,
  but it was scoped to :scope1 and :scope2 instead.
        MESSAGE

        expect(&assertion).to fail_with_message(message)
      end
    end

    context 'when too broad of a scope is specified' do
      it 'rejects with an appropriate failure message' do
        record = build_record_validating_uniqueness(
          scopes: [
            build_attribute(name: :scope1),
            build_attribute(name: :scope2)
          ],
        )

        assertion = lambda do
          expect(record).
            to validate_uniqueness.
            scoped_to(:scope1)
        end

        message = <<-MESSAGE
Example did not properly validate that :attr is case-sensitively unique
within the scope of :scope1.
  Expected the validation to be scoped to :scope1, but it was scoped to
  :scope1 and :scope2 instead.
        MESSAGE

        expect(&assertion).to fail_with_message(message)
      end
    end

    context 'when a different scope is specified' do
      it 'rejects with an appropriate failure message' do
        record = build_record_validating_uniqueness(
          scopes: [ build_attribute(name: :other) ],
          additional_attributes: [:scope]
        )
        assertion = lambda do
          expect(record).
            to validate_uniqueness.
            scoped_to(:scope)
        end

        message = <<-MESSAGE
Example did not properly validate that :attr is case-sensitively unique
within the scope of :scope.
  Expected the validation to be scoped to :scope, but it was scoped to
  :other instead.
        MESSAGE

        expect(&assertion).to fail_with_message(message)
      end
    end

    context 'when no scope is specified' do
      it 'rejects with an appropriate failure message' do
        record = build_record_validating_uniqueness(
          scopes: [ build_attribute(name: :scope) ]
        )

        assertion = lambda do
          expect(record).to validate_uniqueness
        end

        message = <<-MESSAGE
Example did not properly validate that :attr is case-sensitively unique.
  Expected the validation not to be scoped to anything, but it was
  scoped to :scope instead.
        MESSAGE

        expect(&assertion).to fail_with_message(message)
      end

      context 'if the scope attribute is unset in the record given to the matcher' do
        it 'rejects with an appropriate failure message' do
          record = build_record_validating_uniqueness(
            scopes: [ build_attribute(name: :scope, value: nil) ]
          )

          assertion = lambda do
            expect(record).to validate_uniqueness
          end

          message = <<-MESSAGE
Example did not properly validate that :attr is case-sensitively unique.
  Expected the validation not to be scoped to anything, but it was
  scoped to :scope instead.
          MESSAGE

          expect(&assertion).to fail_with_message(message)
        end
      end
    end

    context 'when a non-existent attribute is specified as a scope' do
      context 'when there is more than one scope' do
        it 'rejects with an appropriate failure message (and does not raise an error)' do
          record = build_record_validating_uniqueness(
            scopes: [ build_attribute(name: :scope) ]
          )

          assertion = lambda do
            expect(record).to validate_uniqueness.scoped_to(:non_existent)
          end

          message = <<-MESSAGE.strip
Example did not properly validate that :attr is case-sensitively unique
within the scope of :non_existent.
  :non_existent does not seem to be an attribute on Example.
          MESSAGE

          expect(&assertion).to fail_with_message(message)
        end
      end

      context 'when there is more than one scope' do
        it 'rejects with an appropriate failure message (and does not raise an error)' do
          record = build_record_validating_uniqueness(
            scopes: [ build_attribute(name: :scope) ]
          )

          assertion = lambda do
            expect(record).to validate_uniqueness.scoped_to(
              :non_existent1,
              :non_existent2
            )
          end

          message = <<-MESSAGE.strip
Example did not properly validate that :attr is case-sensitively unique
within the scope of :non_existent1 and :non_existent2.
  :non_existent1 and :non_existent2 do not seem to be attributes on
  Example.
          MESSAGE

          expect(&assertion).to fail_with_message(message)
        end
      end
    end

    context 'when there is more than one validation on the same attribute with different scopes' do
      context 'when a record exists beforehand, where all scopes are set' do
        if column_type != :boolean
          context 'when each validation has the same (default) message' do
            it 'accepts' do
              pending 'this needs another qualifier to properly fix'

              model = define_model(
                'Example',
                attribute_name => :string,
                scope1: column_type,
                scope2: column_type
              ) do |m|
                m.validates_uniqueness_of(attribute_name, scope: [:scope1])
                m.validates_uniqueness_of(attribute_name, scope: [:scope2])
              end

              model.create!(
                attribute_name => dummy_value_for(:string),
                scope1: dummy_value_for(column_type),
                scope2: dummy_value_for(column_type)
              )

              expect(model.new).to validate_uniqueness.scoped_to(:scope1)
              expect(model.new).to validate_uniqueness.scoped_to(:scope2)
            end
          end
        end

        context 'when each validation has a different message' do
          it 'accepts' do
            model = define_model(
              'Example',
              attribute_name => :string,
              scope1: column_type,
              scope2: column_type
            ) do |m|
              m.validates_uniqueness_of(
                attribute_name,
                scope: [:scope1],
                message: 'first message'
              )
              m.validates_uniqueness_of(
                attribute_name,
                scope: [:scope2],
                message: 'second message'
              )
            end

            model.create!(
              attribute_name => dummy_value_for(:string),
              scope1: dummy_value_for(column_type),
              scope2: dummy_value_for(column_type)
            )

            expect(model.new).
              to validate_uniqueness.
              scoped_to(:scope1).
              with_message('first message')

            expect(model.new).
              to validate_uniqueness.
              scoped_to(:scope2).
              with_message('second message')
          end
        end
      end

      context 'when no record exists beforehand' do
        it 'accepts' do
          pending 'this needs another qualifier to properly fix'

          model = define_model(
            'Example',
            attribute_name => :string,
            scope1: column_type,
            scope2: column_type
          ) do |m|
            m.validates_uniqueness_of(attribute_name, scope: [:scope1])
            m.validates_uniqueness_of(attribute_name, scope: [:scope2])
          end

          expect(model.new).to validate_uniqueness.scoped_to(:scope1)
          expect(model.new).to validate_uniqueness.scoped_to(:scope2)
        end
      end
    end

    define_method(:build_attribute) do |attribute_options|
      attribute_options.deep_merge(
        column_type: column_type,
        value_type: value_type,
        options: { array: array }
      )
    end
  end

  context 'when the model does not have a uniqueness validation' do
    it 'rejects with an appropriate failure message' do
      model = define_model_without_validation
      model.create!(attribute_name => 'value')

      assertion = lambda do
        expect(model.new).to validate_uniqueness_of(attribute_name)
      end

      message = <<-MESSAGE
Example did not properly validate that :attr is case-sensitively unique.
  Given an existing Example whose :attr is ‹"value"›, after making a new
  Example and setting its :attr to ‹"value"› as well, the matcher
  expected the new Example to be invalid, but it was valid instead.
      MESSAGE

      expect(&assertion).to fail_with_message(message)
    end
  end

  context 'when the model has a uniqueness validation' do
    context 'when the attribute has a character limit' do
      it 'accepts' do
        record = build_record_validating_uniqueness(
          attribute_type: :string,
          attribute_options: { limit: 1 }
        )

        expect(record).to validate_uniqueness
      end
    end

    context 'when the existing record was created beforehand' do
      context 'when the subject is a new record' do
        it 'accepts' do
          create_record_validating_uniqueness
          expect(new_record_validating_uniqueness).
            to validate_uniqueness
        end
      end

      context 'when the subject is itself the existing record' do
        it 'accepts' do
          expect(existing_record_validating_uniqueness).to validate_uniqueness
        end
      end
    end

    context 'when the existing record was not created beforehand' do
      context 'and the subject is empty' do
        context 'and the attribute being tested is required' do
          it 'can save the subject without the attribute being set' do
            options = { attribute_name: :attr }
            model = define_model_validating_uniqueness(options) do |m|
              m.validates_presence_of :attr
            end

            record = model.new

            expect(record).to validate_uniqueness
          end
        end

        context 'and the attribute being tested are required along with other attributes' do
          it 'can save the subject without the attributes being set' do
            options = {
              attribute_name: :attr,
              additional_attributes: [:required_attribute]
            }
            model = define_model_validating_uniqueness(options) do |m|
              m.validates_presence_of :attr
              m.validates_presence_of :required_attribute
            end

            expect(model.new).to validate_uniqueness
          end
        end

        context 'and the attribute being tested has other validations on it' do
          it 'can save the subject without it being completely valid' do
            options = { attribute_name: :attr }

            model = define_model_validating_uniqueness(options) do |m|
              m.validates_presence_of :attr
              m.validates_numericality_of :attr
            end

            expect(model.new).to validate_uniqueness
          end
        end

        context 'and the table has non-nullable columns other than the attribute being validated' do
          context 'which are set beforehand' do
            it 'can save the subject' do
              options = {
                additional_attributes: [
                  { name: :required_attribute, options: { null: false } }
                ]
              }
              model = define_model_validating_uniqueness(options)
              record = model.new
              record.required_attribute = 'something'

              expect(record).to validate_uniqueness
            end
          end

          context 'which are not set beforehand' do
            it 'raises a useful exception' do
              options = {
                additional_attributes: [
                  { name: :required_attribute, options: { null: false } }
                ]
              }
              model = define_model_validating_uniqueness(options)

              assertion = lambda do
                expect(model.new).to validate_uniqueness
              end

              expect(&assertion).to raise_error(
                described_class::ExistingRecordInvalid
              )
            end
          end
        end

        context 'and the model has required attributes other than the attribute being validated' do
          it 'can save the subject without the attributes being set' do
            options = {
              additional_attributes: [:required_attribute]
            }
            model = define_model_validating_uniqueness(options) do |m|
              m.validates_presence_of :required_attribute
            end

            expect(model.new).to validate_uniqueness
          end
        end
      end

      context 'and the subject is not empty' do
        it 'creates the record automatically from the subject' do
          model = define_model_validating_uniqueness
          assertion = -> {
            record = build_record_from(model)
            expect(record).to validate_uniqueness
          }
          expect(&assertion).to change(model, :count).from(0).to(1)
        end

        context 'and the table has required attributes other than the attribute being validated, set beforehand' do
          it 'can save the subject' do
            options = {
              additional_attributes: [
                { name: :required_attribute, options: { null: false } }
              ]
            }
            model = define_model_validating_uniqueness(options)

            record = build_record_from(model, required_attribute: 'something')
            expect(record).to validate_uniqueness
          end
        end

        context 'and the model has required attributes other than the attribute being validated, set beforehand' do
          it 'can save the subject' do
            options = {
              additional_attributes: [:required_attribute]
            }
            model = define_model_validating_uniqueness(options) do |m|
              m.validates_presence_of :required_attribute
            end

            record = build_record_from(model, required_attribute: 'something')
            expect(record).to validate_uniqueness
          end
        end
      end
    end

    context 'when the validation has no scope and a scope is specified' do
      it 'rejects with an appropriate failure message' do
        model = define_model_validating_uniqueness(
          additional_attributes: [:other]
        )
        create_record_from(model)
        record = build_record_from(model)

        assertion = lambda do
          expect(record).to validate_uniqueness.scoped_to(:other)
        end

        message = <<-MESSAGE
Example did not properly validate that :attr is case-sensitively unique
within the scope of :other.
  Expected the validation to be scoped to :other, but it was not scoped
  to anything.
        MESSAGE

        expect(&assertion).to fail_with_message(message)
      end
    end

    context 'and the validation has a custom message' do
      context 'when no message is specified' do
        it 'rejects with an appropriate failure message' do
          record = build_record_validating_uniqueness(
            attribute_value: 'some value',
            validation_options: { message: 'bad value' }
          )

          assertion = lambda do
            expect(record).to validate_uniqueness
          end

          message = <<-MESSAGE
Example did not properly validate that :attr is case-sensitively unique.
  After taking the given Example, whose :attr is ‹"some value"›, and
  saving it as the existing record, then making a new Example and
  setting its :attr to ‹"some value"› as well, the matcher expected the
  new Example to be invalid and to produce the validation error "has
  already been taken" on :attr. The record was indeed invalid, but it
  produced these validation errors instead:

  * attr: ["bad value"]
          MESSAGE

          expect(&assertion).to fail_with_message(message)
        end
      end

      context 'given a string' do
        context 'when the given and actual messages do not match' do
          it 'rejects with an appropriate failure message' do
            record = build_record_validating_uniqueness(
              attribute_value: 'some value',
              validation_options: { message: 'something else entirely' }
            )

            assertion = lambda do
              expect(record).
                to validate_uniqueness.
                with_message('some message')
            end

            message = <<-MESSAGE
Example did not properly validate that :attr is case-sensitively unique,
producing a custom validation error on failure.
  After taking the given Example, whose :attr is ‹"some value"›, and
  saving it as the existing record, then making a new Example and
  setting its :attr to ‹"some value"› as well, the matcher expected the
  new Example to be invalid and to produce the validation error "some
  message" on :attr. The record was indeed invalid, but it produced
  these validation errors instead:

  * attr: ["something else entirely"]
            MESSAGE

            expect(&assertion).to fail_with_message(message)
          end
        end

        context 'when the given and actual messages match' do
          it 'accepts' do
            record = build_record_validating_uniqueness(
              validation_options: { message: 'bad value' }
            )
            expect(record).
              to validate_uniqueness.
              with_message('bad value')
          end
        end
      end

      context 'given a regex' do
        context 'when the given and actual messages do not match' do
          it 'rejects with an appropriate failure message' do
            record = build_record_validating_uniqueness(
              attribute_value: 'some value',
              validation_options: { message: 'something else entirely' }
            )

            assertion = lambda do
              expect(record).
                to validate_uniqueness.
                with_message(/some message/)
            end

            message = <<-MESSAGE
Example did not properly validate that :attr is case-sensitively unique,
producing a custom validation error on failure.
  After taking the given Example, whose :attr is ‹"some value"›, and
  saving it as the existing record, then making a new Example and
  setting its :attr to ‹"some value"› as well, the matcher expected the
  new Example to be invalid and to produce a validation error matching
  ‹/some message/› on :attr. The record was indeed invalid, but it
  produced these validation errors instead:

  * attr: ["something else entirely"]
            MESSAGE

            expect(&assertion).to fail_with_message(message)
          end
        end

        context 'when the given and actual messages match' do
          it 'accepts' do
            record = build_record_validating_uniqueness(
              validation_options: { message: 'bad value' }
            )
            expect(record).
              to validate_uniqueness.
              with_message(/bad/)
          end
        end
      end
    end

    it_supports(
      'ignoring_interference_by_writer',
      tests: {
        reject_if_qualified_but_changing_value_interferes: {
          model_name: 'Example',
          attribute_name: :attr,
          default_value: 'some value',
          changing_values_with: :next_value,
          expected_message: <<-MESSAGE.strip
Example did not properly validate that :attr is case-sensitively unique.
  After taking the given Example, whose :attr is ‹"some valuf"›, and
  saving it as the existing record, then making a new Example and
  setting its :attr to ‹"some valuf"› (read back as ‹"some valug"›) as
  well, the matcher expected the new Example to be invalid, but it was
  valid instead.

  As indicated in the message above, :attr seems to be changing certain
  values as they are set, and this could have something to do with why
  this test is failing. If you or something else has overridden the
  writer method for this attribute to normalize values by changing their
  case in any way (for instance, ensuring that the attribute is always
  downcased), then try adding `ignoring_case_sensitivity` onto the end
  of the uniqueness matcher. Otherwise, you may need to write the test
  yourself, or do something different altogether.

          MESSAGE
        }
      }
    )
  end

  context 'when the model has a scoped uniqueness validation' do
    context 'when one of the scoped attributes is a string column' do
      include_context 'it supports scoped attributes of a certain type',
        column_type: :string
    end

    context 'when one of the scoped attributes is a boolean column' do
      include_context 'it supports scoped attributes of a certain type',
        column_type: :boolean
    end

    context 'when there is more than one scoped attribute and all are boolean columns' do
      it 'accepts when all of the scoped attributes are true' do
        record = build_record_validating_uniqueness(
          scopes: [
            { type: :boolean, name: :scope1, value: true },
            { type: :boolean, name: :scope2, value: true }
          ]
        )
        expect(record).to validate_uniqueness.scoped_to(:scope1, :scope2)
      end

      it 'accepts when all the scoped attributes are false' do
        record = build_record_validating_uniqueness(
          scopes: [
            { type: :boolean, name: :scope1, value: false },
            { type: :boolean, name: :scope2, value: false }
          ]
        )
        expect(record).to validate_uniqueness.scoped_to(:scope1, :scope2)
      end

      it 'accepts when one of the scoped attributes is true and the other is false' do
        record = build_record_validating_uniqueness(
          scopes: [
            { type: :boolean, name: :scope1, value: true },
            { type: :boolean, name: :scope2, value: false }
          ]
        )
        expect(record).to validate_uniqueness.scoped_to(:scope1, :scope2)
      end
    end

    context 'when one of the scoped attributes is an integer column' do
      include_context 'it supports scoped attributes of a certain type',
        column_type: :integer

      if active_record_supports_enum?
        context 'when one of the scoped attributes is an enum' do
          it 'accepts' do
            record = build_record_validating_scoped_uniqueness_with_enum(
              enum_scope: :scope
            )
            expect(record).to validate_uniqueness.scoped_to(:scope)
          end

          context 'when too narrow of a scope is specified' do
            it 'rejects with an appropriate failure message' do
              record = build_record_validating_scoped_uniqueness_with_enum(
                enum_scope: :scope1,
                additional_scopes: [:scope2],
                additional_attributes: [:other]
              )

              assertion = lambda do
                expect(record).
                  to validate_uniqueness.
                  scoped_to(:scope1, :scope2, :other)
              end

              message = <<-MESSAGE
Example did not properly validate that :attr is case-sensitively unique
within the scope of :scope1, :scope2, and :other.
  Expected the validation to be scoped to :scope1, :scope2, and :other,
  but it was scoped to :scope1 and :scope2 instead.
              MESSAGE

              expect(&assertion).to fail_with_message(message)
            end
          end

          context 'when too broad of a scope is specified' do
            it 'rejects with an appropriate failure message' do
              record = build_record_validating_scoped_uniqueness_with_enum(
                enum_scope: :scope1,
                additional_scopes: [:scope2]
              )

              assertion = lambda do
                expect(record).to validate_uniqueness.scoped_to(:scope1)
              end

              message = <<-MESSAGE
Example did not properly validate that :attr is case-sensitively unique
within the scope of :scope1.
  Expected the validation to be scoped to :scope1, but it was scoped to
  :scope1 and :scope2 instead.
              MESSAGE

              expect(&assertion).to fail_with_message(message)
            end
          end
        end
      end
    end

    context 'when one of the scoped attributes is a date column' do
      include_context 'it supports scoped attributes of a certain type',
        column_type: :date
    end

    context 'when one of the scoped attributes is a datetime column (using DateTime)' do
      include_context 'it supports scoped attributes of a certain type',
        column_type: :datetime
    end

    context 'when one of the scoped attributes is a datetime column (using Time)' do
      include_context 'it supports scoped attributes of a certain type',
        column_type: :datetime,
        value_type: :time
    end

    context 'when one of the scoped attributes is a text column' do
      include_context 'it supports scoped attributes of a certain type',
        column_type: :text
    end

    if database_supports_uuid_columns?
      context 'when one of the scoped attributes is a UUID column' do
        include_context 'it supports scoped attributes of a certain type',
          column_type: :uuid
      end
    end

    if database_supports_array_columns? && active_record_supports_array_columns?
      context 'when one of the scoped attributes is a array-of-string column' do
        include_examples 'it supports scoped attributes of a certain type',
          column_type: :string,
          array: true
      end

      context 'when one of the scoped attributes is an array-of-integer column' do
        include_examples 'it supports scoped attributes of a certain type',
          column_type: :integer,
          array: true
      end

      context 'when one of the scoped attributes is an array-of-date column' do
        include_examples 'it supports scoped attributes of a certain type',
          column_type: :date,
          array: true
      end

      context 'when one of the scoped attributes is an array-of-datetime column (using DateTime)' do
        include_examples 'it supports scoped attributes of a certain type',
          column_type: :datetime,
          array: true
      end

      context 'when one of the scoped attributes is an array-of-datetime column (using Time)' do
        include_examples 'it supports scoped attributes of a certain type',
          column_type: :datetime,
          value_type: :time,
          array: true
      end

      context 'when one of the scoped attributes is an array-of-text column' do
        include_examples 'it supports scoped attributes of a certain type',
          column_type: :text,
          array: true
      end
    end

    context "when an existing record that is not the first has a nil value for the scoped attribute" do
      it 'still works' do
        model = define_model_validating_uniqueness(scopes: [:scope])
        create_record_from(model, scope: 'some value')
        create_record_from(model, scope: nil)
        record = build_record_from(model, scope: 'a different value')

        expect(record).to validate_uniqueness.scoped_to(:scope)
      end
    end
  end

  context 'when the model has a case-sensitive validation' do
    context 'when the matcher is not qualified with case_insensitive' do
      it 'accepts' do
        record = build_record_validating_uniqueness(
          attribute_type: :string,
          validation_options: { case_sensitive: true }
        )

        expect(record).to validate_uniqueness
      end

      context 'given an existing record where the value of the attribute under test is not case-swappable' do
        it 'raises a NonCaseSwappableValueError' do
          model = define_model_validating_uniqueness(
            attribute_type: :string,
            validation_options: { case_sensitive: true },
          )
          record = create_record_from(model, attribute_name => '123')
          running_matcher = -> { validate_uniqueness.matches?(record) }

          expect(&running_matcher).
            to raise_error(described_class::NonCaseSwappableValueError)
        end
      end
    end

    context 'when the matcher is qualified with case_insensitive' do
      it 'rejects with an appropriate failure message' do
        record = build_record_validating_uniqueness(
          attribute_type: :string,
          attribute_value: 'some value',
          validation_options: { case_sensitive: true }
        )

        assertion = lambda do
          expect(record).to validate_uniqueness.case_insensitive
        end

        message = <<-MESSAGE
Example did not properly validate that :attr is case-insensitively
unique.
  After taking the given Example, whose :attr is ‹"some value"›, and
  saving it as the existing record, then making a new Example and
  setting its :attr to a different value, ‹"SOME VALUE"›, the matcher
  expected the new Example to be invalid, but it was valid instead.
        MESSAGE

        expect(&assertion).to fail_with_message(message)
      end
    end
  end

  context 'when the model has a case-insensitive validation' do
    context 'when case_insensitive is not specified' do
      it 'rejects with an appropriate failure message' do
        record = build_record_validating_uniqueness(
          attribute_type: :string,
          validation_options: { case_sensitive: false }
        )

        assertion = lambda do
          expect(record).to validate_uniqueness
        end

        message = <<-MESSAGE
Example did not properly validate that :attr is case-sensitively unique.
  After taking the given Example, setting its :attr to ‹"an arbitrary
  value"›, and saving it as the existing record, then making a new
  Example and setting its :attr to a different value, ‹"AN ARBITRARY
  VALUE"›, the matcher expected the new Example to be valid, but it was
  invalid instead, producing these validation errors:

  * attr: ["has already been taken"]
        MESSAGE

        expect(&assertion).to fail_with_message(message)
      end
    end

    context 'when case_insensitive is specified' do
      it 'accepts' do
        record = build_record_validating_uniqueness(
          attribute_type: :string,
          validation_options: { case_sensitive: false }
        )

        expect(record).to validate_uniqueness.case_insensitive
      end

      it_supports(
        'ignoring_interference_by_writer',
        tests: {
          reject_if_qualified_but_changing_value_interferes: {
            model_name: 'Example',
            attribute_name: :attr,
            default_value: 'some value',
            changing_values_with: :next_value,
            expected_message: <<-MESSAGE.strip
Example did not properly validate that :attr is case-insensitively
unique.
  After taking the given Example, whose :attr is ‹"some valuf"›, and
  saving it as the existing record, then making a new Example and
  setting its :attr to ‹"some valuf"› (read back as ‹"some valug"›) as
  well, the matcher expected the new Example to be invalid, but it was
  valid instead.

  As indicated in the message above, :attr seems to be changing certain
  values as they are set, and this could have something to do with why
  this test is failing. If you or something else has overridden the
  writer method for this attribute to normalize values by changing their
  case in any way (for instance, ensuring that the attribute is always
  downcased), then try adding `ignoring_case_sensitivity` onto the end
  of the uniqueness matcher. Otherwise, you may need to write the test
  yourself, or do something different altogether.
            MESSAGE
          }
        }
      )

      def validation_matcher_scenario_args
        super.deep_merge(validation_options: { case_sensitive: false })
      end

      def configure_validation_matcher(matcher)
        super(matcher).case_insensitive
      end
    end
  end

  context 'when the validation is declared with allow_nil' do
    context 'given a new record whose attribute is nil' do
      it 'accepts' do
        model = define_model_validating_uniqueness(
          validation_options: { allow_nil: true }
        )
        record = build_record_from(model, attribute_name => nil)
        expect(record).to validate_uniqueness.allow_nil
      end
    end

    context 'given an existing record whose attribute is nil' do
      it 'accepts' do
        model = define_model_validating_uniqueness(
          validation_options: { allow_nil: true }
        )
        record = create_record_from(model, attribute_name => nil)
        expect(record).to validate_uniqueness.allow_nil
      end
    end

    if active_record_supports_has_secure_password?
      context 'when the model is declared with has_secure_password' do
        it 'accepts' do
          model = define_model_validating_uniqueness(
            validation_options: { allow_nil: true },
            additional_attributes: [{ name: :password_digest, type: :string }]
          ) do |m|
            m.has_secure_password
          end

          record = build_record_from(model, attribute_name => nil)

          expect(record).to validate_uniqueness.allow_nil
        end
      end
    end
  end

  context 'when the validation is not declared with allow_nil' do
    context 'given a new record whose attribute is nil' do
      it 'rejects with an appropriate failure message' do
        model = define_model_validating_uniqueness
        record = build_record_from(model, attribute_name => nil)

        assertion = lambda do
          expect(record).to validate_uniqueness.allow_nil
        end

        message = <<-MESSAGE
Example did not properly validate that :attr is case-sensitively unique,
but only if it is not nil.
  After taking the given Example, setting its :attr to ‹nil›, and saving
  it as the existing record, then making a new Example and setting its
  :attr to ‹nil› as well, the matcher expected the new Example to be
  valid, but it was invalid instead, producing these validation errors:

  * attr: ["has already been taken"]
        MESSAGE

        expect(&assertion).to fail_with_message(message)
      end
    end

    context 'given an existing record whose attribute is nil' do
      it 'rejects with an appropriate failure message' do
        model = define_model_validating_uniqueness
        record = create_record_from(model, attribute_name => nil)

        assertion = lambda do
          expect(record).to validate_uniqueness.allow_nil
        end

        message = <<-MESSAGE
Example did not properly validate that :attr is case-sensitively unique,
but only if it is not nil.
  Given an existing Example, after setting its :attr to ‹nil›, then
  making a new Example and setting its :attr to ‹nil› as well, the
  matcher expected the new Example to be valid, but it was invalid
  instead, producing these validation errors:

  * attr: ["has already been taken"]
        MESSAGE

        expect(&assertion).to fail_with_message(message)
      end
    end
  end

  context 'when the validation is declared with allow_blank' do
    context 'given a new record whose attribute is nil' do
      it 'accepts' do
        model = define_model_validating_uniqueness(
          validation_options: { allow_blank: true }
        )
        record = build_record_from(model, attribute_name => nil)
        expect(record).to validate_uniqueness.allow_blank
      end
    end

    context 'given an existing record whose attribute is nil' do
      it 'accepts' do
        model = define_model_validating_uniqueness(
          validation_options: { allow_blank: true }
        )
        record = create_record_from(model, attribute_name => nil)
        expect(record).to validate_uniqueness.allow_blank
      end
    end

    context 'given a new record whose attribute is empty' do
      it 'accepts' do
        model = define_model_validating_uniqueness(
          attribute_type: :string,
          validation_options: { allow_blank: true }
        )
        record = build_record_from(model, attribute_name => '')
        expect(record).to validate_uniqueness.allow_blank
      end
    end

    context 'given an existing record whose attribute is empty' do
      it 'accepts' do
        model = define_model_validating_uniqueness(
          attribute_type: :string,
          validation_options: { allow_blank: true }
        )
        record = create_record_from(model, attribute_name => '')
        expect(record).to validate_uniqueness.allow_blank
      end
    end

    if active_record_supports_has_secure_password?
      context 'when the model is declared with has_secure_password' do
        context 'given a record whose attribute is nil' do
          it 'accepts' do
            model = define_model_validating_uniqueness(
              validation_options: { allow_blank: true },
              additional_attributes: [{ name: :password_digest, type: :string }]
            ) do |m|
              m.has_secure_password
            end

            record = build_record_from(model, attribute_name => nil)

            expect(record).to validate_uniqueness.allow_blank
          end
        end

        context 'given a record whose attribute is empty' do
          it 'accepts' do
            model = define_model_validating_uniqueness(
              attribute_type: :string,
              validation_options: { allow_blank: true },
              additional_attributes: [{ name: :password_digest, type: :string }]
            ) do |m|
              m.has_secure_password
            end

            record = build_record_from(model, attribute_name => '')

            expect(record).to validate_uniqueness.allow_blank
          end
        end
      end
    end
  end

  context 'when the validation is not declared with allow_blank' do
    context 'given a new record whose attribute is nil' do
      it 'rejects with an appropriate failure message' do
        model = define_model_validating_uniqueness
        record = build_record_from(model, attribute_name => nil)

        assertion = lambda do
          expect(record).to validate_uniqueness.allow_blank
        end

        message = <<-MESSAGE
Example did not properly validate that :attr is case-sensitively unique,
but only if it is not blank.
  After taking the given Example, setting its :attr to ‹""›, and saving
  it as the existing record, then making a new Example and setting its
  :attr to ‹""› as well, the matcher expected the new Example to be
  valid, but it was invalid instead, producing these validation errors:

  * attr: ["has already been taken"]
        MESSAGE

        expect(&assertion).to fail_with_message(message)
      end
    end

    context 'given an existing record whose attribute is nil' do
      it 'rejects with an appropriate failure message' do
        model = define_model_validating_uniqueness
        record = create_record_from(model, attribute_name => nil)

        assertion = lambda do
          expect(record).to validate_uniqueness.allow_blank
        end

        message = <<-MESSAGE
Example did not properly validate that :attr is case-sensitively unique,
but only if it is not blank.
  Given an existing Example, after setting its :attr to ‹""›, then
  making a new Example and setting its :attr to ‹""› as well, the
  matcher expected the new Example to be valid, but it was invalid
  instead, producing these validation errors:

  * attr: ["has already been taken"]
        MESSAGE

        expect(&assertion).to fail_with_message(message)
      end
    end

    context 'given a new record whose attribute is empty' do
      it 'rejects with an appropriate failure message' do
        model = define_model_validating_uniqueness(
          attribute_type: :string
        )
        record = build_record_from(model, attribute_name => '')

        assertion = lambda do
          expect(record).to validate_uniqueness.allow_blank
        end

        message = <<-MESSAGE
Example did not properly validate that :attr is case-sensitively unique,
but only if it is not blank.
  After taking the given Example, setting its :attr to ‹""›, and saving
  it as the existing record, then making a new Example and setting its
  :attr to ‹""› as well, the matcher expected the new Example to be
  valid, but it was invalid instead, producing these validation errors:

  * attr: ["has already been taken"]
        MESSAGE

        expect(&assertion).to fail_with_message(message)
      end
    end

    context 'given an existing record whose attribute is empty' do
      it 'rejects with an appropriate failure message' do
        model = define_model_validating_uniqueness(
          attribute_type: :string
        )
        record = create_record_from(model, attribute_name => '')

        assertion = lambda do
          expect(record).to validate_uniqueness.allow_blank
        end

        message = <<-MESSAGE
Example did not properly validate that :attr is case-sensitively unique,
but only if it is not blank.
  Given an existing Example, after setting its :attr to ‹""›, then
  making a new Example and setting its :attr to ‹""› as well, the
  matcher expected the new Example to be valid, but it was invalid
  instead, producing these validation errors:

  * attr: ["has already been taken"]
        MESSAGE

        expect(&assertion).to fail_with_message(message)
      end
    end
  end

  context 'when testing that a polymorphic *_type column is one of the validation scopes' do
    it 'sets that column to a meaningful value that works with other validations on the same column' do
      user_model = define_model 'User'
      favorite_columns = {
        favoriteable_id: { type: :integer, options: { null: false } },
        favoriteable_type: { type: :string, options: { null: false } }
      }
      favorite_model = define_model 'Favorite', favorite_columns do
        attr_accessible :favoriteable
        belongs_to :favoriteable, polymorphic: true
        validates :favoriteable, presence: true
        validates :favoriteable_id, uniqueness: { scope: :favoriteable_type }
      end

      user = user_model.create!
      favorite_model.create!(favoriteable: user)
      new_favorite = favorite_model.new

      expect(new_favorite).
        to validate_uniqueness_of(:favoriteable_id).
        scoped_to(:favoriteable_type)
    end

    context 'if the model the *_type column refers to is namespaced, and shares the last part of its name with an existing model' do
      it 'still works' do
        define_class 'User'
        define_module 'Models'
        user_model = define_model 'Models::User'
        favorite_columns = {
          favoriteable_id: { type: :integer, options: { null: false } },
          favoriteable_type: { type: :string, options: { null: false } }
        }
        favorite_model = define_model 'Models::Favorite', favorite_columns do
          attr_accessible :favoriteable
          belongs_to :favoriteable, polymorphic: true
          validates :favoriteable, presence: true
          validates :favoriteable_id, uniqueness: { scope: :favoriteable_type }
        end

        user = user_model.create!
        favorite_model.create!(favoriteable: user)
        new_favorite = favorite_model.new

        expect(new_favorite).
          to validate_uniqueness_of(:favoriteable_id).
          scoped_to(:favoriteable_type)
      end
    end
  end

  context 'when the model does not have the attribute being tested' do
    it 'fails with an appropriate failure message' do
      model = define_model(:example)

      assertion = lambda do
        expect(model.new).to validate_uniqueness_of(:attr)
      end

      message = <<-MESSAGE.strip
Example did not properly validate that :attr is case-sensitively unique.
  :attr does not seem to be an attribute on Example.
      MESSAGE

      expect(&assertion).to fail_with_message(message)
    end
  end

  context 'when the writer method for the attribute changes the case of incoming values' do
    context 'when the validation is case-sensitive' do
      context 'and the matcher is ensuring that the validation is case-sensitive' do
        it 'rejects with an appropriate failure message' do
          model = define_model_validating_uniqueness(
            attribute_name: :name
          )

          model.class_eval do
            def name=(name)
              super(name.upcase)
            end
          end

          assertion = lambda do
            expect(model.new).to validate_uniqueness_of(:name)
          end

          message = <<-MESSAGE.strip
Example did not properly validate that :name is case-sensitively unique.
  After taking the given Example, setting its :name to ‹"an arbitrary
  value"› (read back as ‹"AN ARBITRARY VALUE"›), and saving it as the
  existing record, then making a new Example and setting its :name to
  ‹"an arbitrary value"› (read back as ‹"AN ARBITRARY VALUE"›) as well,
  the matcher expected the new Example to be valid, but it was invalid
  instead, producing these validation errors:

  * name: ["has already been taken"]

  As indicated in the message above, :name seems to be changing certain
  values as they are set, and this could have something to do with why
  this test is failing. If you or something else has overridden the
  writer method for this attribute to normalize values by changing their
  case in any way (for instance, ensuring that the attribute is always
  downcased), then try adding `ignoring_case_sensitivity` onto the end
  of the uniqueness matcher. Otherwise, you may need to write the test
  yourself, or do something different altogether.
          MESSAGE

          expect(&assertion).to fail_with_message(message)
        end
      end

      context 'and the matcher is ignoring case sensitivity' do
        it 'accepts (and not raise an error)' do
          model = define_model_validating_uniqueness(
            attribute_name: :name
          )

          model.class_eval do
            def name=(name)
              super(name.upcase)
            end
          end

          expect(model.new).
            to validate_uniqueness_of(:name).
            ignoring_case_sensitivity
        end
      end
    end

    context 'when the validation is case-insensitive' do
      context 'and the matcher is ensuring that the validation is case-insensitive' do
        it 'accepts (and does not raise an error)' do
          model = define_model_validating_uniqueness(
            attribute_name: :name,
            validation_options: { case_sensitive: false },
          )

          model.class_eval do
            def name=(name)
              super(name.downcase)
            end
          end

          expect(model.new).
            to validate_uniqueness_of(:name).
            case_insensitive
        end
      end
    end
  end

  let(:model_attributes) { {} }

  def default_attribute
    {
      value_type: :string,
      column_type: :string,
      options: { array: false, null: true }
    }
  end

  def normalize_attribute(attribute)
    if attribute.is_a?(Hash)
      attribute_copy = attribute.dup

      if attribute_copy.key?(:type)
        attribute_copy[:value_type] = attribute_copy[:type]
        attribute_copy[:column_type] = attribute_copy[:type]
      end

      default_attribute.deep_merge(attribute_copy)
    else
      default_attribute.deep_merge(name: attribute)
    end
  end

  def normalize_attributes(attributes)
    attributes.map do |attribute|
      normalize_attribute(attribute)
    end
  end

  def column_options_from(attributes)
    attributes.inject({}) do |options, attribute|
      options[attribute[:name]] = {
        type: attribute[:column_type],
        options: attribute.fetch(:options, {})
      }
      options
    end
  end

  def attributes_with_values_for(model)
    model_attributes[model].each_with_object({}) do |attribute, attrs|
      attrs[attribute[:name]] = attribute.fetch(:value) do
        if attribute[:options][:null]
          nil
        else
          dummy_value_for(
            attribute[:value_type],
            array: attribute[:options][:array]
          )
        end
      end
    end
  end

  def dummy_value_for(attribute_type, array: false)
    if array
      [ dummy_scalar_value_for(attribute_type) ]
    else
      dummy_scalar_value_for(attribute_type)
    end
  end

  def dummy_scalar_value_for(attribute_type)
    case attribute_type
    when :string, :text
      'dummy value'
    when :integer
      1
    when :date
      Date.today
    when :datetime
      Date.today.to_datetime
    when :time
      Time.now
    when :uuid
      SecureRandom.uuid
    when :boolean
      true
    else
      raise ArgumentError, "Unknown type '#{attribute_type}'"
    end
  end

  def next_version_of(value, value_type)
    if value.is_a?(Array)
      [ next_version_of(value[0], value_type) ]
    elsif value_type == :uuid
      SecureRandom.uuid
    elsif value.is_a?(Time)
      value + 1
    elsif [true, false].include?(value)
      !value
    elsif value.respond_to?(:next)
      value.next
    end
  end

  def build_record_from(model, extra_attributes = {})
    attributes = attributes_with_values_for(model)
    model.new(attributes.merge(extra_attributes))
  end

  def create_record_from(model, extra_attributes = {})
    build_record_from(model, extra_attributes).tap do |record|
      record.save!
    end
  end

  def define_model_validating_uniqueness(options = {}, &block)
    attribute_name = options.fetch(:attribute_name) { self.attribute_name }
    attribute_type = options.fetch(:attribute_type, :string)
    attribute_options = options.fetch(:attribute_options, {})
    attribute = normalize_attribute(
      name: attribute_name,
      value_type: attribute_type,
      column_type: attribute_type,
      options: attribute_options
    )

    if options.key?(:attribute_value)
      attribute[:value] = options[:attribute_value]
    end

    scope_attributes = normalize_attributes(options.fetch(:scopes, []))
    scope_attribute_names = scope_attributes.map { |attr| attr[:name] }
    additional_attributes = normalize_attributes(
      options.fetch(:additional_attributes, [])
    )
    attributes = [attribute] + scope_attributes + additional_attributes
    validation_options = options.fetch(:validation_options, {})
    column_options = column_options_from(attributes)

    model = define_model(:example, column_options) do |m|
      m.validates_uniqueness_of attribute_name,
        validation_options.merge(scope: scope_attribute_names)

      attributes.each do |attr|
        m.attr_accessible(attr[:name])
      end

      block.call(m) if block
    end

    model_attributes[model] = attributes

    model
  end

  def build_record_validating_uniqueness(options = {}, &block)
    model = define_model_validating_uniqueness(options, &block)
    build_record_from(model)
  end
  alias_method :new_record_validating_uniqueness,
    :build_record_validating_uniqueness

  def create_record_validating_uniqueness(options = {}, &block)
    build_record_validating_uniqueness(options, &block).tap do |record|
      record.save!
    end
  end
  alias_method :existing_record_validating_uniqueness,
    :create_record_validating_uniqueness

  def build_record_validating_scoped_uniqueness_with_enum(options = {})
    options = options.dup
    enum_scope_attribute =
      normalize_attribute(options.delete(:enum_scope)).
      merge(value_type: :integer, column_type: :integer)
    additional_scopes = options.delete(:additional_scopes) { [] }
    options[:scopes] = [enum_scope_attribute] + additional_scopes
    dummy_enum_values = [:foo, :bar]

    model = define_model_validating_uniqueness(options)
    model.enum(enum_scope_attribute[:name] => dummy_enum_values)

    build_record_from(model)
  end

  def define_model_without_validation
    define_model(:example, attribute_name => :string) do |model|
      model.attr_accessible(attribute_name)
    end
  end

  def validate_uniqueness
    validate_uniqueness_of(attribute_name)
  end

  def attribute_name
    :attr
  end

  def validation_matcher_scenario_args
    super.deep_merge(
      matcher_name: :validate_uniqueness_of,
      model_creator: :"active_record/uniqueness_matcher"
    )
  end
end
