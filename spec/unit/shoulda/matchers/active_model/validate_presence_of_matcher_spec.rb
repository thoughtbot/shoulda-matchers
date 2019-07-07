require 'unit_spec_helper'

describe Shoulda::Matchers::ActiveModel::ValidatePresenceOfMatcher, type: :model do
  include UnitTests::ApplicationConfigurationHelpers

  context 'a model with a presence validation' do
    it 'accepts' do
      expect(validating_presence).to matcher
    end

    it 'does not override the default message with a blank' do
      expect(validating_presence).to matcher.with_message(nil)
    end

    it_supports(
      'ignoring_interference_by_writer',
      tests: {
        accept_if_qualified_but_changing_value_does_not_interfere: {
          changing_values_with: :nil_to_blank
        },
        reject_if_qualified_but_changing_value_interferes: {
          model_name: 'Example',
          attribute_name: :attr,
          changing_values_with: :never_falsy,
          expected_message: <<-MESSAGE
Expected Example to validate that :attr cannot be empty/falsy, but this
could not be proved.
  After setting :attr to ‹nil› -- which was read back as ‹"dummy value"›
  -- the matcher expected the Example to be invalid, but it was valid
  instead.

  As indicated in the message above, :attr seems to be changing certain
  values as they are set, and this could have something to do with why
  this test is failing. If you've overridden the writer method for this
  attribute, then you may need to change it to make this test pass, or
  do something else entirely.
          MESSAGE
        }
      }
    )

    it 'fails when used in the negative' do
      assertion = lambda do
        expect(validating_presence).not_to matcher
      end

      message = <<-MESSAGE
Expected Example not to validate that :attr cannot be empty/falsy, but
this could not be proved.
  After setting :attr to ‹nil›, the matcher expected the Example to be
  valid, but it was invalid instead, producing these validation errors:

  * attr: ["can't be blank"]
      MESSAGE

      expect(&assertion).to fail_with_message(message)
    end

    context 'when the attribute is decorated with serialize' do
      context 'and the type is a string' do
        it 'still works' do
          record = record_validating_presence_of(:traits) do
            serialize :traits, String
          end

          expect(record).to validate_presence_of(:traits)
        end
      end

      context 'and the type is not a string' do
        it 'still works' do
          record = record_validating_presence_of(:traits) do
            serialize :traits, Array
          end

          expect(record).to validate_presence_of(:traits)
        end
      end
    end

    context 'when the column backing the attribute is a scalar, but not a string' do
      it 'still works' do
        record = record_validating_presence_of(
          :pinned_on,
          column_options: { type: :date },
        )

        expect(record).to validate_presence_of(:pinned_on)
      end
    end

    context 'when the column backing the attribute is an array' do
      it 'still works' do
        record = record_validating_presence_of(
          :possible_meeting_dates,
          column_options: { type: :date, array: true },
        )

        expect(record).to validate_presence_of(:possible_meeting_dates)
      end
    end
  end

  context 'a model without a presence validation' do
    it 'rejects with the correct failure message' do
      record = define_model(:example, attr: :string).new

      assertion = lambda do
        expect(record).to matcher
      end

      message = <<-MESSAGE
Expected Example to validate that :attr cannot be empty/falsy, but this
could not be proved.
  After setting :attr to ‹""›, the matcher expected the Example to be
  invalid, but it was valid instead.
      MESSAGE

      expect(&assertion).to fail_with_message(message)
    end
  end

  context 'an ActiveModel class with a presence validation' do
    it 'accepts' do
      expect(active_model_validating_presence).to matcher
    end

    it 'does not override the default message with a blank' do
      expect(active_model_validating_presence).to matcher.with_message(nil)
    end

    it_supports(
      'ignoring_interference_by_writer',
      tests: {
        accept_if_qualified_but_changing_value_does_not_interfere: {
          changing_values_with: :nil_to_blank
        },
        reject_if_qualified_but_changing_value_interferes: {
          model_name: 'Example',
          attribute_name: :attr,
          changing_values_with: :never_falsy,
          expected_message: <<-MESSAGE
Expected Example to validate that :attr cannot be empty/falsy, but this
could not be proved.
  After setting :attr to ‹nil› -- which was read back as ‹"dummy value"›
  -- the matcher expected the Example to be invalid, but it was valid
  instead.

  As indicated in the message above, :attr seems to be changing certain
  values as they are set, and this could have something to do with why
  this test is failing. If you've overridden the writer method for this
  attribute, then you may need to change it to make this test pass, or
  do something else entirely.
          MESSAGE
        }
      }
    )

    if active_model_supports_full_attributes_api?
      context 'when the attribute has been configured with a type' do
        context 'and it is a string' do
          it 'works' do
            record = active_model_object_validating_presence_of(:age) do
              attribute :age, :string
            end

            expect(record).to validate_presence_of(:age)
          end
        end

        context 'and it is not a string' do
          it 'still works' do
            record = active_model_object_validating_presence_of(:age) do
              attribute :age, :time
            end

            expect(record).to validate_presence_of(:age)
          end
        end
      end
    end

    def model_creator
      :active_model
    end
  end

  context 'an ActiveModel class without a presence validation' do
    it 'rejects with the correct failure message' do
      assertion = lambda do
        record = plain_active_model_object_with(:attr, model_name: 'Example')

        expect(record).to matcher
      end

      message = <<-MESSAGE
Expected Example to validate that :attr cannot be empty/falsy, but this
could not be proved.
  After setting :attr to ‹""›, the matcher expected the Example to be
  invalid, but it was valid instead.
      MESSAGE

      expect(&assertion).to fail_with_message(message)
    end
  end

  if active_record_supports_validate_presence_on_active_storage?
    context 'a has_one_attached association with a presence validation' do
      it 'requires the attribute to be set' do
        expect(has_one_attached_child(presence: true)).to validate_presence_of(:child)
      end

      it_supports(
        'ignoring_interference_by_writer',
        tests: {
          accept_if_qualified_but_changing_value_does_not_interfere: {
            changing_values_with: :nil_to_blank
          },
          reject_if_qualified_but_changing_value_interferes: {
            model_name: 'Example',
            attribute_name: :attr,
            changing_values_with: :never_falsy,
            expected_message: <<-MESSAGE
Expected Example to validate that :attr cannot be empty/falsy, but this
could not be proved.
  After setting :attr to ‹nil› -- which was read back as ‹"dummy value"›
  -- the matcher expected the Example to be invalid, but it was valid
  instead.

  As indicated in the message above, :attr seems to be changing certain
  values as they are set, and this could have something to do with why
  this test is failing. If you've overridden the writer method for this
  attribute, then you may need to change it to make this test pass, or
  do something else entirely.
            MESSAGE
          }
        }
      )
    end

    context 'a has_one_attached association without a presence validation' do
      it 'requires the attribute to be set' do
        expect(has_one_attached_child(presence: false)).
          not_to validate_presence_of(:child)
      end
    end

    context 'a has_many_attached association with a presence validation' do
      it 'requires the attribute to be set' do
        expect(has_many_attached_children(presence: true)).to validate_presence_of(:children)
      end

      it_supports(
        'ignoring_interference_by_writer',
        tests: {
          accept_if_qualified_but_changing_value_does_not_interfere: {
            changing_values_with: :nil_to_blank
          },
          reject_if_qualified_but_changing_value_interferes: {
            model_name: 'Example',
            attribute_name: :attr,
            changing_values_with: :never_falsy,
            expected_message: <<-MESSAGE
Expected Example to validate that :attr cannot be empty/falsy, but this
could not be proved.
  After setting :attr to ‹nil› -- which was read back as ‹"dummy value"›
  -- the matcher expected the Example to be invalid, but it was valid
  instead.

  As indicated in the message above, :attr seems to be changing certain
  values as they are set, and this could have something to do with why
  this test is failing. If you've overridden the writer method for this
  attribute, then you may need to change it to make this test pass, or
  do something else entirely.
            MESSAGE
          }
        }
      )
    end

    context 'a has_many_attached association without a presence validation' do
      it 'does not require the attribute to be set' do
        expect(has_many_attached_children(presence: false)).
          not_to validate_presence_of(:children)
      end
    end
  end

  context 'a has_many association with a presence validation' do
    it 'requires the attribute to be set' do
      expect(has_many_children(presence: true)).to validate_presence_of(:children)
    end

    it_supports(
      'ignoring_interference_by_writer',
      tests: {
        accept_if_qualified_but_changing_value_does_not_interfere: {
          changing_values_with: :nil_to_blank
        },
        reject_if_qualified_but_changing_value_interferes: {
          model_name: 'Example',
          attribute_name: :attr,
          changing_values_with: :never_falsy,
          expected_message: <<-MESSAGE
Expected Example to validate that :attr cannot be empty/falsy, but this
could not be proved.
  After setting :attr to ‹nil› -- which was read back as ‹"dummy value"›
  -- the matcher expected the Example to be invalid, but it was valid
  instead.

  As indicated in the message above, :attr seems to be changing certain
  values as they are set, and this could have something to do with why
  this test is failing. If you've overridden the writer method for this
  attribute, then you may need to change it to make this test pass, or
  do something else entirely.
          MESSAGE
        }
      }
    )

    def model_creator
      :"active_record/has_many"
    end
  end

  context 'a has_many association without a presence validation' do
    it 'does not require the attribute to be set' do
      expect(has_many_children(presence: false)).
        not_to validate_presence_of(:children)
    end
  end

  context 'a has_and_belongs_to_many association with a presence validation on it' do
    it 'accepts' do
      expect(build_record_having_and_belonging_to_many).
        to validate_presence_of(:children)
    end

    def build_record_having_and_belonging_to_many
      create_table 'children_parents', id: false do |t|
        t.integer :child_id
        t.integer :parent_id
      end

      define_model :child

      define_model :parent do
        has_and_belongs_to_many :children
        validates_presence_of :children
      end.new
    end

    it_supports(
      'ignoring_interference_by_writer',
      tests: {
        accept_if_qualified_but_changing_value_does_not_interfere: {
          changing_values_with: :nil_to_blank
        },
        reject_if_qualified_but_changing_value_interferes: {
          model_name: 'Example',
          attribute_name: :attr,
          changing_values_with: :never_falsy,
          expected_message: <<-MESSAGE
Expected Example to validate that :attr cannot be empty/falsy, but this
could not be proved.
  After setting :attr to ‹nil› -- which was read back as ‹"dummy value"›
  -- the matcher expected the Example to be invalid, but it was valid
  instead.

  As indicated in the message above, :attr seems to be changing certain
  values as they are set, and this could have something to do with why
  this test is failing. If you've overridden the writer method for this
  attribute, then you may need to change it to make this test pass, or
  do something else entirely.
          MESSAGE
        }
      }
    )

    def model_creator
      :"active_record/has_and_belongs_to_many"
    end
  end

  context 'a has_and_belongs_to_many association without a presence validation on it' do
    before do
      define_model :child
      @model = define_model :parent do
        has_and_belongs_to_many :children
      end.new
      create_table 'children_parents', id: false do |t|
        t.integer :child_id
        t.integer :parent_id
      end
    end

    it 'rejects with the correct failure message' do
      assertion = lambda do
        expect(@model).to validate_presence_of(:children)
      end

      message = <<-MESSAGE
Expected Parent to validate that :children cannot be empty/falsy, but
this could not be proved.
  After setting :children to ‹[]›, the matcher expected the Parent to be
  invalid, but it was valid instead.
      MESSAGE

      expect(&assertion).to fail_with_message(message)
    end
  end

  context 'against a belongs_to association' do
    if active_record_supports_optional_for_associations?
      context 'declared with optional: true' do
        context 'and an explicit presence validation is on the association' do
          it 'matches' do
            record = record_belonging_to(
              :parent,
              optional: true,
              validate_presence: true,
            )

            expect { validate_presence_of(:parent) }.to match_against(record)
          end
        end

        context 'and an explicit presence validation is not on the association' do
          it 'does not match' do
            record = record_belonging_to(
              :parent,
              optional: true,
              validate_presence: false,
              model_name: 'Child',
              parent_model_name: 'Parent',
            )

            expect { validate_presence_of(:parent) }.
              not_to match_against(record).
              and_fail_with(<<-MESSAGE)
Expected Child to validate that :parent cannot be empty/falsy, but this
could not be proved.
  After setting :parent to ‹nil›, the matcher expected the Child to be
  invalid, but it was valid instead.
              MESSAGE
          end
        end
      end

      context 'declared with optional: false' do
        context 'and an explicit presence validation is on the association' do
          it 'matches' do
            record = record_belonging_to(
              :parent,
              optional: false,
              validate_presence: true,
            )

            expect { validate_presence_of(:parent) }.to match_against(record)
          end
        end

        context 'and an explicit presence validation is not on the association' do
          it 'does not match, instructing the user to use belongs_to instead' do
            record = record_belonging_to(
              :parent,
              optional: false,
              validate_presence: false,
              model_name: 'Child',
              parent_model_name: 'Parent',
            )

            expect { validate_presence_of(:parent) }.
              not_to match_against(record).
              and_fail_with(<<-MESSAGE)
Expected Child to validate that :parent cannot be empty/falsy, but this
could not be proved.
  After setting :parent to ‹nil›, the matcher expected the Child to be
  invalid and to produce the validation error "can't be blank" on
  :parent. The record was indeed invalid, but it produced these
  validation errors instead:

  * parent: ["must exist"]

  You're getting this error because you've instructed your `belongs_to`
  association to add a presence validation to the attribute. *This*
  presence validation doesn't use "can't be blank", the usual validation
  message, but "must exist" instead.

  With that said, did you know that the `belong_to` matcher can test
  this validation for you? Instead of using `validate_presence_of`, try
  one of the following instead, depending on your use case:

      it { should belong_to(:parent).optional(false) }
      it { should belong_to(:parent).required(true) }
              MESSAGE
          end
        end
      end

      context 'declared with required: true' do
        context 'and an explicit presence validation is on the association' do
          it 'matches' do
            record = record_belonging_to(
              :parent,
              required: true,
              validate_presence: true,
            )

            expect { validate_presence_of(:parent) }.to match_against(record)
          end
        end

        context 'and an explicit presence validation is not on the association' do
          it 'does not match, instructing the user to use belongs_to instead' do
            record = record_belonging_to(
              :parent,
              required: true,
              validate_presence: false,
              model_name: 'Child',
              parent_model_name: 'Parent',
            )

            expect { validate_presence_of(:parent) }.
              not_to match_against(record).
              and_fail_with(<<-MESSAGE)
Expected Child to validate that :parent cannot be empty/falsy, but this
could not be proved.
  After setting :parent to ‹nil›, the matcher expected the Child to be
  invalid and to produce the validation error "can't be blank" on
  :parent. The record was indeed invalid, but it produced these
  validation errors instead:

  * parent: ["must exist"]

  You're getting this error because you've instructed your `belongs_to`
  association to add a presence validation to the attribute. *This*
  presence validation doesn't use "can't be blank", the usual validation
  message, but "must exist" instead.

  With that said, did you know that the `belong_to` matcher can test
  this validation for you? Instead of using `validate_presence_of`, try
  one of the following instead, depending on your use case:

      it { should belong_to(:parent).optional(false) }
      it { should belong_to(:parent).required(true) }
              MESSAGE
          end
        end
      end

      context 'declared with required: false' do
        context 'and an explicit presence validation is on the association' do
          it 'matches' do
            record = record_belonging_to(
              :parent,
              required: false,
              validate_presence: true,
            )

            expect { validate_presence_of(:parent) }.to match_against(record)
          end
        end

        context 'and an explicit presence validation is not on the association' do
          it 'does not match' do
            record = record_belonging_to(
              :parent,
              required: false,
              validate_presence: false,
              model_name: 'Child',
              parent_model_name: 'Parent',
            )

            expect { validate_presence_of(:parent) }.
              not_to match_against(record).
              and_fail_with(<<-MESSAGE)
Expected Child to validate that :parent cannot be empty/falsy, but this
could not be proved.
  After setting :parent to ‹nil›, the matcher expected the Child to be
  invalid, but it was valid instead.
              MESSAGE
          end
        end
      end

      context 'not declared with an optional or required option' do
        context 'when belongs_to is configured to be required by default' do
          context 'and an explicit presence validation is on the association' do
            it 'matches' do
              with_belongs_to_as_required_by_default do
                record = record_belonging_to(
                  :parent,
                  validate_presence: true,
                )

                expect { validate_presence_of(:parent) }.
                  to match_against(record)
              end
            end
          end

          context 'and an explicit presence validation is not on the association' do
            it 'does not match, instructing the user to use belong_to instead' do
              with_belongs_to_as_required_by_default do
                record = record_belonging_to(
                  :parent,
                  validate_presence: false,
                  model_name: 'Child',
                  parent_model_name: 'Parent',
                )

                expect { validate_presence_of(:parent) }.
                  not_to match_against(record).
                  and_fail_with(<<-MESSAGE)
Expected Child to validate that :parent cannot be empty/falsy, but this
could not be proved.
  After setting :parent to ‹nil›, the matcher expected the Child to be
  invalid and to produce the validation error "can't be blank" on
  :parent. The record was indeed invalid, but it produced these
  validation errors instead:

  * parent: ["must exist"]

  You're getting this error because ActiveRecord is configured to add a
  presence validation to all `belongs_to` associations, and this
  includes yours. *This* presence validation doesn't use "can't be
  blank", the usual validation message, but "must exist" instead.

  With that said, did you know that the `belong_to` matcher can test
  this validation for you? Instead of using `validate_presence_of`, try
  the following instead:

      it { should belong_to(:parent) }
                  MESSAGE
              end
            end
          end
        end

        context 'when belongs_to is configured to be optional by default' do
          context 'and an explicit presence validation is on the association' do
            it 'matches' do
              with_belongs_to_as_optional_by_default do
                record = record_belonging_to(
                  :parent,
                  validate_presence: true,
                )

                expect { validate_presence_of(:parent) }.
                  to match_against(record)
              end
            end
          end

          context 'and an explicit presence validation is not on the association' do
            it 'does not match' do
              with_belongs_to_as_optional_by_default do
                record = record_belonging_to(
                  :parent,
                  validate_presence: false,
                  model_name: 'Child',
                  parent_model_name: 'Parent',
                )

                expect { validate_presence_of(:parent) }.
                  not_to match_against(record).
                  and_fail_with(<<-MESSAGE)
Expected Child to validate that :parent cannot be empty/falsy, but this
could not be proved.
  After setting :parent to ‹nil›, the matcher expected the Child to be
  invalid, but it was valid instead.
                  MESSAGE
              end
            end
          end
        end
      end
    else
      context 'declared with required: true' do
        context 'and an explicit presence validation is on the association' do
          it 'matches' do
            record = record_belonging_to(
              :parent,
              required: true,
              validate_presence: true,
            )

            expect { validate_presence_of(:parent) }.to match_against(record)
          end
        end

        context 'and an explicit presence validation is not on the association' do
          it 'still matches' do
            record = record_belonging_to(
              :parent,
              required: true,
              validate_presence: false,
            )

            expect { validate_presence_of(:parent) }.to match_against(record)
          end
        end
      end

      context 'declared with required: false' do
        context 'and an explicit presence validation is on the association' do
          it 'matches' do
            record = record_belonging_to(
              :parent,
              required: false,
              validate_presence: true,
            )

            expect { validate_presence_of(:parent) }.to match_against(record)
          end
        end

        context 'and an explicit presence validation is not on the association' do
          it 'does not match' do
            record = record_belonging_to(
              :parent,
              required: false,
              validate_presence: false,
              model_name: 'Child',
              parent_model_name: 'Parent',
            )

            expect { validate_presence_of(:parent) }.
              not_to match_against(record).
              and_fail_with(<<-MESSAGE)
Expected Child to validate that :parent cannot be empty/falsy, but this
could not be proved.
  After setting :parent to ‹nil›, the matcher expected the Child to be
  invalid, but it was valid instead.
              MESSAGE
          end
        end
      end

      context 'not declared with a required option' do
        context 'and an explicit presence validation is on the association' do
          it 'matches' do
            record = record_belonging_to(:parent, validate_presence: true)

            expect { validate_presence_of(:parent) }.to match_against(record)
          end
        end

        context 'and an explicit presence validation is not on the association' do
          it 'does not match' do
            record = record_belonging_to(:parent, validate_presence: false)

            expect { validate_presence_of(:parent) }.
              not_to match_against(record).
              and_fail_with(<<-MESSAGE)
Expected Child to validate that :parent cannot be empty/falsy, but this
could not be proved.
  After setting :parent to ‹nil›, the matcher expected the Child to be
  invalid, but it was valid instead.
              MESSAGE
          end
        end
      end
    end

    def record_belonging_to(
      attribute_name,
      model_name: 'Child',
      parent_model_name: 'Parent',
      column_name: "#{attribute_name}_id",
      validate_presence: false,
      **association_options,
      &block
    )
      define_model(parent_model_name)

      child_model = define_model(model_name, column_name => :integer) do
        belongs_to(attribute_name, **association_options)

        if validate_presence
          validates_presence_of(attribute_name)
        end

        if block
          instance_eval(&block)
        end
      end

      child_model.new
    end
  end

  context "an i18n translation containing %{attribute} and %{model}" do
    before do
      stub_translation(
        "activerecord.errors.messages.blank",
        "Please enter a %{attribute} for your %{model}")
    end

    after { I18n.backend.reload! }

    it "does not raise an exception" do
      expect {
        expect(validating_presence).to validate_presence_of(:attr)
      }.to_not raise_exception
    end
  end

  context 'a strictly required attribute' do
    it 'accepts when the :strict options match' do
      expect(validating_presence(strict: true)).to matcher.strict
    end

    it 'rejects with the correct failure message when the :strict options do not match' do
      assertion = lambda do
        expect(validating_presence(strict: false)).to matcher.strict
      end

      message = <<-MESSAGE
Expected Example to validate that :attr cannot be empty/falsy, raising a
validation exception on failure, but this could not be proved.
  After setting :attr to ‹""›, the matcher expected the Example to be
  invalid and to raise a validation exception, but the record produced
  validation errors instead.
      MESSAGE

      expect(&assertion).to fail_with_message(message)
    end

    it 'does not override the default message with a blank' do
      expect(validating_presence(strict: true)).
        to matcher.strict.with_message(nil)
    end
  end

  context "an attribute with a context-dependent validation" do
    context "without the validation context" do
      it "does not match" do
        expect(validating_presence(on: :customisable)).not_to matcher
      end
    end

    context "with the validation context" do
      it "matches" do
        expect(validating_presence(on: :customisable)).to matcher.on(:customisable)
      end
    end
  end

  if rails_lte_4?
    context 'an active_resource model' do
      context 'with the validation context' do
        it 'does not raise an exception' do
          expect do
            expect(active_resource_model).to validate_presence_of(:attr)
          end.to_not raise_exception
        end
      end
    end
  end

  if rails_4_x?
    context 'against a pre-set password in a model that has_secure_password' do
      it 'raises a CouldNotSetPasswordError' do
        user_class = define_model :user, password_digest: :string do
          has_secure_password validations: false
          validates_presence_of :password
        end

        user = user_class.new
        user.password = 'something'

        assertion = lambda do
          expect(user).to validate_presence_of(:password)
        end

        expect(&assertion).to raise_error(
          Shoulda::Matchers::ActiveModel::CouldNotSetPasswordError
        )
      end
    end
  end

  context 'when the attribute typecasts nil to another blank value, such as an empty array' do
    it 'accepts (and does not raise an AttributeChangedValueError)' do
      model = define_active_model_class :example, accessors: [:foo] do
        validates_presence_of :foo

        def foo=(value)
          super([])
        end
      end

      expect(model.new).to validate_presence_of(:foo)
    end
  end

  context 'qualified with allow_nil' do
    context 'when validating a model with a presence validator' do
      context 'and it is specified with allow_nil: true' do
        it 'matches in the positive' do
          record = validating_presence(allow_nil: true)
          expect(record).to matcher.allow_nil
        end

        it 'does not match in the negative' do
          record = validating_presence(allow_nil: true)

          assertion = -> { expect(record).not_to matcher.allow_nil }

          expect(&assertion).to fail_with_message(<<-MESSAGE)
Expected Example not to validate that :attr cannot be empty/falsy, but
this could not be proved.
  After setting :attr to ‹""›, the matcher expected the Example to be
  valid, but it was invalid instead, producing these validation errors:

  * attr: ["can't be blank"]
          MESSAGE
        end
      end

      context 'and it is not specified with allow_nil: true' do
        it 'does not match in the positive' do
          record = validating_presence

          assertion = lambda do
            expect(record).to matcher.allow_nil
          end

          message = <<-MESSAGE
Expected Example to validate that :attr cannot be empty/falsy, but this
could not be proved.
  After setting :attr to ‹nil›, the matcher expected the Example to be
  valid, but it was invalid instead, producing these validation errors:

  * attr: ["can't be blank"]
          MESSAGE

          expect(&assertion).to fail_with_message(message)
        end
      end

      it 'matches in the negative' do
        record = validating_presence

        expect(record).not_to matcher.allow_nil
      end
    end

    context 'when validating a model without a presence validator' do
      it 'does not match in the positive' do
        record = without_validating_presence

        assertion = lambda do
          expect(record).to matcher.allow_nil
        end

        message = <<-MESSAGE
Expected Example to validate that :attr cannot be empty/falsy, but this
could not be proved.
  After setting :attr to ‹""›, the matcher expected the Example to be
  invalid, but it was valid instead.
        MESSAGE

        expect(&assertion).to fail_with_message(message)
      end

      it 'matches in the negative' do
        record = without_validating_presence

        expect(record).not_to matcher.allow_nil
      end
    end
  end

  def matcher
    validate_presence_of(:attr)
  end

  def record_validating_presence_of(
    attribute_name = :attr,
    column_options: { type: :string },
    **options,
    &block
  )
    model = define_model 'Example', attribute_name => column_options do
      validates_presence_of(attribute_name, options)

      if block
        class_eval(&block)
      end
    end

    model.new
  end
  alias_method :validating_presence, :record_validating_presence_of

  def without_validating_presence
    define_model(:example, attr: :string).new
  end

  def active_model_object_validating_presence_of(
    attribute_name = :attr,
    **options,
    &block
  )
    plain_active_model_object_with(attribute_name, **options) do
      validates_presence_of(attribute_name)

      if block
        class_eval(&block)
      end
    end
  end
  alias_method :active_model_validating_presence,
    :active_model_object_validating_presence_of

  def plain_active_model_object_with(
    attribute_name = :attr,
    model_name: 'Example',
    **options,
    &block
  )
    model = define_active_model_class(
      model_name,
      accessors: [attribute_name],
      **options,
      &block
    )

    model.new
  end

  def has_many_children(options = {})
    define_model :child
    define_model :parent do
      has_many :children
      if options[:presence]
        validates_presence_of :children
      end
    end.new
  end

  def has_one_attached_child(options = {})
    define_model :child
    define_model :parent do
      has_one_attached :child
      if options[:presence]
        validates_presence_of :child
      end
    end.new
  end

  def has_many_attached_children(options = {})
    define_model :child
    define_model :parent do
      has_many_attached :children
      if options[:presence]
        validates_presence_of :children
      end
    end.new
  end

  def active_resource_model
    define_active_resource_class :foo, attr: :string do
      validates_presence_of :attr
    end.new
  end

  def validation_matcher_scenario_args
    super.deep_merge(
      matcher_name: :validate_presence_of,
      model_creator: :active_record
    )
  end
end
