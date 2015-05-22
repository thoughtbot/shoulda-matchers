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
      it 'rejects' do
        record = build_record_validating_uniqueness(
          scopes: [
            build_attribute(name: :scope1),
            { name: :scope2 }
          ],
        )
        expect(record).
          not_to validate_uniqueness.
          scoped_to(:scope1, :scope2, :other)
      end
    end

    context 'when too broad of a scope is specified' do
      it 'rejects' do
        record = build_record_validating_uniqueness(
          scopes: [
            build_attribute(name: :scope1),
            { name: :scope2 }
          ],
        )
        expect(record).
          not_to validate_uniqueness.
          scoped_to(:scope1)
      end
    end

    context 'when a different scope is specified' do
      it 'rejects' do
        record = build_record_validating_uniqueness(
          scopes: [ build_attribute(name: :scope) ],
          additional_attributes: [:other]
        )
        expect(record).
          not_to validate_uniqueness.
          scoped_to(:other)
      end
    end

    context 'when no scope is specified' do
      it 'rejects' do
        record = build_record_validating_uniqueness(
          scopes: [ build_attribute(name: :scope) ]
        )
        expect(record).not_to validate_uniqueness
      end

      it 'rejects if the scope is unset beforehand' do
        record = build_record_validating_uniqueness(
          scopes: [ build_attribute(name: :scope, value: nil) ]
        )
        expect(record).not_to validate_uniqueness
      end
    end

    context 'when a non-existent attribute is specified as a scope' do
      it 'rejects' do
        record = build_record_validating_uniqueness(
          scopes: [ build_attribute(name: :scope) ]
        )
        expect(record).not_to validate_uniqueness.scoped_to(:non_existent)
      end
    end

    define_method(:build_attribute) do |attribute_options|
      attribute_options.merge(
        column_type: column_type,
        value_type: value_type,
        array: array
      )
    end
  end

  context 'when the model does not have a uniqueness validation' do
    it 'rejects' do
      model = define_model(:example, attribute_name => :string) do |m|
        m.attr_accessible attribute_name
      end

      model.create!(attr: 'value')

      expect(model.new).not_to validate_uniqueness_of(attribute_name)
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

    context 'when the record is created beforehand' do
      context 'when the subject is a new record' do
        it 'accepts' do
          create_record_validating_uniqueness
          expect(new_record_validating_uniqueness).
            to validate_uniqueness
        end
      end

      context 'when the subject is an existing record' do
        it 'accepts' do
          expect(existing_record_validating_uniqueness).to validate_uniqueness
        end
      end

      context 'when the validation has no scope and a scope is specified' do
        it 'rejects' do
          model = define_model_validating_uniqueness(
            additional_attributes: [:other]
          )
          create_record_from(model)
          record = build_record_from(model)
          expect(record).not_to validate_uniqueness.scoped_to(:other)
        end
      end
    end

    context 'when the record is not created beforehand' do
      it 'creates the record automatically' do
        model = define_model_validating_uniqueness
        assertion = -> {
          record = build_record_from(model)
          expect(record).to validate_uniqueness
        }
        expect(&assertion).to change(model, :count).from(0).to(1)
      end

      context 'and the table has required attributes other than the attribute being validated, set beforehand' do
        it 'does not require the record to be persisted' do
          options = {
            additional_attributes: [
              { name: :required_attribute, options: { null: false } }
            ]
          }
          model = define_model_validating_uniqueness(options) do |m|
            m.validates_presence_of :required_attribute
          end

          record = build_record_from(model, required_attribute: 'something')
          expect(record).to validate_uniqueness
        end
      end
    end

    context 'and the validation has a custom message' do
      context 'when no message is specified' do
        it 'rejects' do
          record = build_record_validating_uniqueness(
            validation_options: { message: 'bad value' }
          )
          expect(record).not_to validate_uniqueness
        end
      end

      context 'given a string' do
        context 'when the given and actual messages do not match' do
          it 'rejects' do
            record = build_record_validating_uniqueness(
              validation_options: { message: 'bad value' }
            )
            expect(record).
              not_to validate_uniqueness.
              with_message('something else entirely')
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
          it 'rejects' do
            record = build_record_validating_uniqueness(
              validation_options: { message: 'Bad value' }
            )
            expect(record).
              not_to validate_uniqueness.
              with_message(/something else entirely/)
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
            it 'rejects' do
              record = build_record_validating_scoped_uniqueness_with_enum(
                enum_scope: :scope1,
                additional_scopes: [:scope2],
                additional_attributes: [:other]
              )
              expect(record).
                not_to validate_uniqueness.
                scoped_to(:scope1, :scope2, :other)
            end
          end

          context 'when too broad of a scope is specified' do
            it 'rejects' do
              record = build_record_validating_scoped_uniqueness_with_enum(
                enum_scope: :scope1,
                additional_scopes: [:scope2]
              )
              expect(record).
                not_to validate_uniqueness.
                scoped_to(:scope1)
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
    context 'when case_insensitive is not specified' do
      it 'accepts' do
        record = build_record_validating_uniqueness(
          attribute_type: :string,
          validation_options: { case_sensitive: true }
        )

        expect(record).to validate_uniqueness
      end
    end

    context 'when case_insensitive is specified' do
      it 'rejects' do
        record = build_record_validating_uniqueness(
          attribute_type: :string,
          validation_options: { case_sensitive: true }
        )

        expect(record).not_to validate_uniqueness.case_insensitive
      end
    end
  end

  context 'when the model has a case-insensitive validation' do
    context 'when case_insensitive is not specified' do
      it 'rejects' do
        record = build_record_validating_uniqueness(
          attribute_type: :string,
          validation_options: { case_sensitive: false }
        )

        expect(record).not_to validate_uniqueness
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
      it 'rejects' do
        model = define_model_validating_uniqueness
        record = build_record_from(model, attribute_name => nil)
        expect(record).not_to validate_uniqueness.allow_nil
      end
    end

    context 'given an existing record whose attribute is nil' do
      it 'rejects' do
        model = define_model_validating_uniqueness
        record = create_record_from(model, attribute_name => nil)
        expect(record).not_to validate_uniqueness.allow_nil
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
      it 'rejects' do
        model = define_model_validating_uniqueness
        record = build_record_from(model, attribute_name => nil)
        expect(record).not_to validate_uniqueness.allow_blank
      end
    end

    context 'given an existing record whose attribute is nil' do
      it 'rejects' do
        model = define_model_validating_uniqueness
        record = create_record_from(model, attribute_name => nil)
        expect(record).not_to validate_uniqueness.allow_blank
      end
    end

    context 'given a new record whose attribute is empty' do
      it 'rejects' do
        model = define_model_validating_uniqueness(
          attribute_type: :string
        )
        record = build_record_from(model, attribute_name => '')
        expect(record).not_to validate_uniqueness.allow_blank
      end
    end

    context 'given an existing record whose attribute is empty' do
      it 'rejects' do
        model = define_model_validating_uniqueness(
          attribute_type: :string
        )
        record = create_record_from(model, attribute_name => '')
        expect(record).not_to validate_uniqueness.allow_blank
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

  let(:model_attributes) { {} }

  def default_attribute
    {
      value_type: :string,
      column_type: :string,
      array: false
    }
  end

  def normalize_attribute(attribute)
    if attribute.is_a?(Hash)
      if attribute.key?(:type)
        attribute[:value_type] = attribute[:type]
        attribute[:column_type] = attribute[:type]
      end

      default_attribute.merge(attribute)
    else
      default_attribute.merge(name: attribute)
    end
  end

  def normalize_attributes(attributes)
    attributes.map do |attribute|
      normalize_attribute(attribute)
    end
  end

  def column_options_from(attributes)
    attributes.inject({}) do |options, attribute|
      options_for_attribute = options[attribute[:name]] = {
        type: attribute[:column_type],
        options: attribute.fetch(:options, {})
      }

      if attribute[:array]
        options_for_attribute[:options][:array] = attribute[:array]
      end

      options
    end
  end

  def attributes_with_values_for(model)
    model_attributes[model].each_with_object({}) do |attribute, attrs|
      attrs[attribute[:name]] = attribute.fetch(:value) do
        dummy_value_for(
          attribute[:value_type],
          array: attribute[:array]
        )
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
    elsif value.in?([true, false])
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

  def determine_scope_attribute_names_from(scope_attributes)
    scope_attributes.map do |attribute|
      if attribute.is_a?(Hash)
        attribute[:name]
      else
        attribute
      end
    end
  end

  def define_model_validating_uniqueness(options = {}, &block)
    attribute_type = options.fetch(:attribute_type, :string)
    attribute_options = options.fetch(:attribute_options, {})
    attribute = {
      name: attribute_name,
      value_type: attribute_type,
      column_type: attribute_type,
      options: attribute_options
    }
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

  def validate_uniqueness
    validate_uniqueness_of(attribute_name)
  end

  def attribute_name
    :attr
  end
end
