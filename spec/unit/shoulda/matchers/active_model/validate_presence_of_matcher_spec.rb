require 'unit_spec_helper'

describe Shoulda::Matchers::ActiveModel::ValidatePresenceOfMatcher, type: :model do
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

    def model_creator
      :active_model
    end
  end

  context 'an ActiveModel class without a presence validation' do
    it 'rejects with the correct failure message' do
      assertion = lambda do
        expect(active_model).to matcher
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

  context 'a required has_and_belongs_to_many association' do
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

  context 'an optional has_and_belongs_to_many association' do
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

  def validating_presence(options = {})
    define_model :example, attr: :string do
      validates_presence_of :attr, options
    end.new
  end

  def without_validating_presence
    define_model(:example, attr: :string).new
  end

  def active_model(&block)
    define_active_model_class('Example', accessors: [:attr], &block).new
  end

  def active_model_validating_presence
    active_model { validates_presence_of :attr }
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
