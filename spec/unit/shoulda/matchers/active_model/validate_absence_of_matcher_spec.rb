require 'unit_spec_helper'

describe Shoulda::Matchers::ActiveModel::ValidateAbsenceOfMatcher, type: :model do
  def self.available_column_types
    [
      :string,
      :text,
      :integer,
      :float,
      :decimal,
      :datetime,
      :timestamp,
      :time,
      :date,
      :binary,
      :uuid,
    ]
  end

  context 'a model with an absence validation' do
    it 'accepts' do
      expect(validating_absence_of(:attr)).to validate_absence_of(:attr)
    end

    it 'does not override the default message with a present' do
      expect(validating_absence_of(:attr)).to validate_absence_of(:attr).with_message(nil)
    end

    available_column_types.each do |type|
      context "when column is of type #{type}" do
        it 'accepts' do
          expect(validating_absence_of(:attr, {}, type: type)).
            to validate_absence_of(:attr)
        end

        it_supports(
          'ignoring_interference_by_writer',
          tests: {
            accept_if_qualified_but_changing_value_does_not_interfere: {
              changing_values_with: :next_value,
            },
          },
        )

        define_method(:validation_matcher_scenario_args) do |*args|
          super(*args).deep_merge(column_type: type)
        end
      end
    end

    if database_supports_array_columns?
      context 'when the column backing the attribute is an array' do
        context 'of varchar' do
          it 'still works' do
            record = validating_absence_of(
              :attr,
              {},
              type: :varchar,
              options: { array: true, default: [], null: false },
            )

            expect(record).to validate_absence_of(:attr)
          end
        end

        context 'of string' do
          it 'still works' do
            record = validating_absence_of(
              :attr,
              {},
              type: :string,
              options: { array: true, default: [], null: false },
            )

            expect(record).to validate_absence_of(:attr)
          end
        end

        context 'of a type other than string' do
          it 'still works' do
            record = validating_absence_of(
              :possible_meeting_dates,
              {},
              type: :date,
              options: { array: true, default: [], null: false },
            )

            expect(record).to validate_absence_of(:possible_meeting_dates)
          end
        end
      end
    end

    context 'when the column backing the attribute is an enum' do
      it 'still works' do
        model = define_model_validating_absence_of(:attr)
        model.enum attr: %w[one two three]

        expect(model.new).to validate_absence_of(:attr)
      end
    end

    context 'when used in the negative' do
      it 'fails' do
        assertion = lambda do
          expect(validating_absence_of(:attr)).
            not_to validate_absence_of(:attr)
        end

        message = <<-MESSAGE
Expected Example not to validate that :attr is empty/falsy, but this
could not be proved.
  After setting :attr to ‹"an arbitrary value"›, the matcher expected
  the Example to be valid, but it was invalid instead, producing these
  validation errors:

  * attr: ["must be blank"]
        MESSAGE

        expect(&assertion).to fail_with_message(message)
      end
    end

    def validation_matcher_scenario_args
      super.deep_merge(model_creator: :active_record)
    end
  end

  context 'a model without an absence validation' do
    it 'rejects with the correct failure message' do
      record = define_model(:example, attr: :string).new

      message = <<-MESSAGE
Expected Example to validate that :attr is empty/falsy, but this could
not be proved.
  After setting :attr to ‹"an arbitrary value"›, the matcher expected
  the Example to be invalid, but it was valid instead.
      MESSAGE

      assertion = lambda do
        expect(record).to validate_absence_of(:attr)
      end

      expect(&assertion).to fail_with_message(message)
    end
  end

  context 'an ActiveModel class with an absence validation' do
    it 'accepts' do
      expect(active_model_validating_absence_of(:attr)).to validate_absence_of(:attr)
    end

    it 'does not override the default message with a blank' do
      expect(active_model_validating_absence_of(:attr)).to validate_absence_of(:attr).with_message(nil)
    end

    it_supports(
      'ignoring_interference_by_writer',
      tests: {
        accept_if_qualified_but_changing_value_does_not_interfere: {
          changing_values_with: :upcase,
        },
      },
    )

    def validation_matcher_scenario_args
      super.deep_merge(model_creator: :active_model)
    end
  end

  context 'an ActiveModel class without an absence validation' do
    it 'rejects with the correct failure message' do
      message = <<-MESSAGE
Expected Example to validate that :attr is empty/falsy, but this could
not be proved.
  After setting :attr to ‹"an arbitrary value"›, the matcher expected
  the Example to be invalid, but it was valid instead.
      MESSAGE

      assertion = lambda do
        expect(active_model_with(:attr)).to validate_absence_of(:attr)
      end

      expect(&assertion).to fail_with_message(message)
    end
  end

  context 'a has_many association with an absence validation' do
    it 'requires the attribute to not be set' do
      expect(having_many(:children, absence: true)).to validate_absence_of(:children)
    end

    it_supports(
      'ignoring_interference_by_writer',
      tests: {
        accept_if_qualified_but_changing_value_does_not_interfere: {
          changing_values_with: :next_value,
        },
      },
    )

    def validation_matcher_scenario_args
      super.deep_merge(model_creator: :"active_record/has_many")
    end
  end

  context 'a has_many association without an absence validation' do
    it 'does not require the attribute to not be set' do
      expect(having_many(:children, absence: false)).
        not_to validate_absence_of(:children)
    end
  end

  context 'an absent has_and_belongs_to_many association' do
    it 'accepts' do
      model = having_and_belonging_to_many(:children, absence: true)
      expect(model).to validate_absence_of(:children)
    end

    it_supports(
      'ignoring_interference_by_writer',
      tests: {
        accept_if_qualified_but_changing_value_does_not_interfere: {
          changing_values_with: :next_value,
        },
      },
    )

    def validation_matcher_scenario_args
      super.deep_merge(model_creator: :"active_record/habtm")
    end
  end

  context 'a non-absent has_and_belongs_to_many association' do
    it 'rejects with the correct failure message' do
      model = having_and_belonging_to_many(:children, absence: false)

      message = <<-MESSAGE
Expected Parent to validate that :children is empty/falsy, but this
could not be proved.
  After setting :children to ‹[#<Child id: nil>]›, the matcher expected
  the Parent to be invalid, but it was valid instead.
      MESSAGE

      assertion = lambda do
        expect(model).to validate_absence_of(:children)
      end

      expect(&assertion).to fail_with_message(message)
    end
  end

  context 'an i18n translation containing %{attribute} and %{model}' do
    after { I18n.backend.reload! }

    it 'does not raise an exception' do
      stub_translation('activerecord.errors.messages.present',
        '%{attribute} must be blank in a %{model}',)

      expect {
        expect(validating_absence_of(:attr)).to validate_absence_of(:attr)
      }.to_not raise_exception
    end
  end

  context 'an attribute with a context-dependent validation' do
    context 'without the validation context' do
      it 'does not match' do
        expect(validating_absence_of(:attr, on: :customisable)).not_to validate_absence_of(:attr)
      end
    end

    context 'with the validation context' do
      it 'matches' do
        expect(validating_absence_of(:attr, on: :customisable)).to validate_absence_of(:attr).on(:customisable)
      end
    end
  end

  def define_model_validating_absence_of(attr, validation_options = {}, given_column_options = {})
    column_options = { type: :string, options: {} }.merge!(given_column_options)

    define_model :example, attr => column_options do |model|
      model.validates_absence_of(attr, validation_options)

      if block_given?
        yield model
      end
    end
  end

  def validating_absence_of(attr, validation_options = {}, given_column_options = {})
    model = define_model_validating_absence_of(
      attr,
      validation_options,
      given_column_options,
    )
    model.new
  end
  alias_method :build_record_validating_absence_of, :validating_absence_of

  def active_model_with(attr, &block)
    define_active_model_class('Example', accessors: [attr], &block).new
  end

  def active_model_validating_absence_of(attr)
    active_model_with(attr) do
      validates_absence_of attr
    end
  end

  def having_many(plural_name, options = {})
    define_model plural_name.to_s.singularize
    define_model :parent do
      has_many plural_name
      if options[:absence]
        validates_absence_of plural_name
      end
    end.new
  end

  def having_and_belonging_to_many(plural_name, options = {})
    create_table 'children_parents', id: false do |t|
      t.integer "#{plural_name.to_s.singularize}_id"
      t.integer :parent_id
    end

    define_model plural_name.to_s.singularize
    define_model :parent do
      has_and_belongs_to_many plural_name
      if options[:absence]
        validates_absence_of plural_name
      end
    end.new
  end

  def validation_matcher_scenario_args
    super.deep_merge(matcher_name: :validate_absence_of)
  end
end
