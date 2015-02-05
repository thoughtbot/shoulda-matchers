require 'unit_spec_helper'

describe Shoulda::Matchers::ActiveRecord::ValidateUniquenessOfMatcher, type: :model do
  context 'a model without a a uniqueness validation' do
    it 'rejects' do
      model = define_model(:example, attr: :string) { attr_accessible :attr } .new
      Example.create!(attr: 'value')
      expect(model).not_to matcher
    end
  end

  context 'a model with a uniqueness validation' do
    context 'where the subject has a character limit' do
      it 'tests with values within the character limit' do
        model = define_model(:example, attr: { type: :string, options: { limit: 1 } }) do
         attr_accessible :attr
         validates_uniqueness_of :attr
        end.new
        expect(model).to matcher
      end
    end

    context 'with an existing record' do
      it 'requires a unique value for that attribute' do
        create_existing
        expect(validating_uniqueness_with_other).to matcher
      end

      it 'accepts when the subject is an existing record' do
        expect(create_existing).to matcher
      end

      it 'rejects when a scope is specified' do
        create_existing
        expect(validating_uniqueness_with_other).not_to matcher.scoped_to(:other)
      end

      def create_existing
        define_model_with_other
        Example.create!(attr: 'value', other: 1)
      end
    end

    context 'without an existing record' do
      it 'does not require a created instance' do
        define_model_with_other
        expect(Example.count).to eq 0
        expect(validating_uniqueness_with_other).to matcher
      end

      context "and the table uses non-nullable columns, set beforehand" do
        it "does not require the record to be persisted" do
          model = define_model_with_non_nullable_column
          record = model.new(required_attribute_name => "some value")
          expect(record).to validate_uniqueness_of(unique_attribute_name)
        end

        def define_model_with_non_nullable_column
          model = define_model(:example,
            unique_attribute_name => :string,
            required_attribute_name => {
              type: :string,
              options: { null: false }
            }
          )

          model.tap do
            model.attr_accessible(
              required_attribute_name,
              unique_attribute_name
            )
            model.validates_presence_of(required_attribute_name)
            model.validates_uniqueness_of(unique_attribute_name)
          end
        end

        def required_attribute_name
          :required_attribute_name
        end

        def unique_attribute_name
          :unique_attribute_name
        end
      end
    end

    def define_model_with_other(options = {})
      @model ||= define_model(:example, attr: :string, other: :integer) do
        attr_accessible :attr, :other
        validates_uniqueness_of :attr, options
      end
    end

    def validating_uniqueness_with_other(options = {})
      define_model_with_other.new
    end
  end

  context 'a model with a uniqueness validation, a custom error, and an existing record' do
    it 'rejects when the actual message does not match the default message' do
      expect(validating_uniqueness_with_existing_record(message: 'Bad value')).
        not_to matcher
    end

    it 'rejects when the messages do not match' do
      expect(validating_uniqueness_with_existing_record(message: 'Bad value')).
        not_to matcher.with_message(/abc/)
    end

    it 'accepts when the messages match' do
      expect(validating_uniqueness_with_existing_record(message: 'Bad value')).
        to matcher.with_message(/Bad/)
    end

    def validating_uniqueness_with_existing_record(options = {})
      model = define_model(:example, attr: :string) do
        attr_accessible :attr
        validates_uniqueness_of :attr, options
      end.new
      Example.create!(attr: 'value')
      model
    end
  end

  context 'a model with a scoped uniqueness validation with an existing value' do
    it 'accepts when the correct scope is specified' do
      expect(validating_scoped_uniqueness([:scope1, :scope2])).
        to matcher.scoped_to(:scope1, :scope2)
    end

    it 'accepts when the subject is an existing record' do
      define_scoped_model([:scope1, :scope2])
      expect(create_existing_record).to matcher.scoped_to(:scope1, :scope2)
    end

    it 'rejects when too narrow of a scope is specified' do
      expect(validating_scoped_uniqueness([:scope1, :scope2])).
        not_to matcher.scoped_to(:scope1, :scope2, :other)
    end

    it 'rejects when too broad of a scope is specified' do
      expect(validating_scoped_uniqueness([:scope1, :scope2])).
        not_to matcher.scoped_to(:scope1)
    end

    it 'rejects when a different scope is specified' do
      expect(validating_scoped_uniqueness([:scope1])).
        not_to matcher.scoped_to(:other)
    end

    it 'rejects when no scope is specified' do
      expect(validating_scoped_uniqueness([:scope1])).not_to matcher
    end

    it 'rejects when a non-existent attribute is specified as a scope' do
      expect(validating_scoped_uniqueness([:scope1])).
        not_to matcher.scoped_to(:fake)
    end

    if rails_gte_4_1?
      context 'when the scoped attribute is an enum' do
        it 'accepts' do
          expect(validating_scoped_uniqueness_with_enum([:scope1], scope1: 0)).
            to matcher.scoped_to(:scope1)
        end

        context 'with a nil value' do
          it 'accepts' do
            expect(validating_scoped_uniqueness_with_enum([:scope1], scope1: nil)).
              to matcher.scoped_to(:scope1)
          end
        end

        context 'when too narrow of a scope is specified' do
          it 'rejects' do
            expect(validating_scoped_uniqueness_with_enum_with_two_scopes).
              not_to matcher.scoped_to(:scope1, :scope2, :other)
          end
        end

        context 'when too broad of a scope is specified' do
          it 'rejects' do
            expect(validating_scoped_uniqueness_with_enum_with_two_scopes).
              not_to matcher.scoped_to(:scope1)
          end
        end

        def validating_scoped_uniqueness_with_enum_with_two_scopes
          validating_scoped_uniqueness_with_enum([:scope1, :scope2], scope1: 0, scope2: 0)
        end
      end
    end

    context 'when the scoped attribute is a date' do
      it "accepts" do
        expect(validating_scoped_uniqueness([:scope1], :date, scope1: Date.today)).
          to matcher.scoped_to(:scope1)
      end

      context 'with an existing record that conflicts with scope.next' do
        it 'accepts' do
          expect(validating_scoped_uniqueness_with_conflicting_next(:scope1, :date, scope1: Date.today)).
            to matcher.scoped_to(:scope1)
        end
      end

      context 'when too narrow of a scope is specified' do
        it 'rejects' do
          expect(validating_scoped_uniqueness([:scope1, :scope2], :date, scope1: Date.today, scope2: Date.today)).
            not_to matcher.scoped_to(:scope1, :scope2, :other)
        end
      end

      context 'when too broad of a scope is specified' do
        it 'rejects' do
          expect(validating_scoped_uniqueness([:scope1, :scope2], :date, scope1: Date.today, scope2: Date.today)).
            not_to matcher.scoped_to(:scope1)
        end
      end
    end

    context 'when the scoped attribute is a datetime' do
      it 'accepts' do
        expect(validating_scoped_uniqueness([:scope1], :datetime, scope1: DateTime.now)).
          to matcher.scoped_to(:scope1)
      end

      context 'with an existing record that conflicts with scope.next' do
        it 'accepts' do
          expect(validating_scoped_uniqueness_with_conflicting_next(:scope1, :datetime, scope1: DateTime.now)).
            to matcher.scoped_to(:scope1)
        end
      end

      context 'with a nil value' do
        it 'accepts' do
          expect(validating_scoped_uniqueness([:scope1], :datetime, scope1: nil)).
            to matcher.scoped_to(:scope1)
        end
      end

      context 'when too narrow of a scope is specified' do
        it 'rejects' do
          expect(validating_scoped_uniqueness([:scope1, :scope2], :datetime, scope1: DateTime.now, scope2: DateTime.now)).
            not_to matcher.scoped_to(:scope1, :scope2, :other)
        end
      end

      context 'when too broad of a scope is specified' do
        it 'rejects' do
          expect(validating_scoped_uniqueness([:scope1, :scope2], :datetime, scope1: DateTime.now, scope2: DateTime.now)).
            not_to matcher.scoped_to(:scope1)
        end
      end
    end

    context 'when the scoped attribute is a uuid' do
      it 'accepts' do
        expect(validating_scoped_uniqueness([:scope1], :uuid, scope1: SecureRandom.uuid)).
          to matcher.scoped_to(:scope1)
      end

      context 'with an existing record that conflicts with scope.next' do
        it 'accepts' do
          expect(validating_scoped_uniqueness_with_conflicting_next(:scope1, :uuid, scope1: SecureRandom.uuid)).
            to matcher.scoped_to(:scope1)
        end
      end

      context 'with a nil value' do
        it 'accepts' do
          expect(validating_scoped_uniqueness([:scope1], :uuid, scope1: nil)).
            to matcher.scoped_to(:scope1)
        end
      end

      context 'when too narrow of a scope is specified' do
        it 'rejects' do
          record = validating_scoped_uniqueness([:scope1, :scope2], :uuid,
            scope1: SecureRandom.uuid,
            scope2: SecureRandom.uuid
          )
          expect(record).not_to matcher.scoped_to(:scope1, :scope2, :other)
        end
      end

      context 'when too broad of a scope is specified' do
        it 'rejects' do
          record = validating_scoped_uniqueness([:scope1, :scope2], :uuid,
            scope1: SecureRandom.uuid,
            scope2: SecureRandom.uuid
          )
          expect(record).not_to matcher.scoped_to(:scope1)
        end
      end
    end

    def create_existing_record(attributes = {})
      @existing ||= create_record(attributes)
    end

    def create_record(attributes = {})
      default_attributes = {attr: 'value', scope1: 1, scope2: 2, other: 3}
      Example.create!(default_attributes.merge(attributes))
    end

    def define_scoped_model(scope, scope_attr_type = :integer)
      define_model(:example, attr: :string, scope1: scope_attr_type,
                   scope2: scope_attr_type, other: :integer) do
        attr_accessible :attr, :scope1, :scope2, :other
        validates_uniqueness_of :attr, scope: scope
      end
    end

    def validating_scoped_uniqueness(*args)
      attributes = args.extract_options!
      model = define_scoped_model(*args).new
      create_existing_record(attributes)
      model
    end

    def validating_scoped_uniqueness_with_enum(*args)
      attributes = args.extract_options!
      model = define_scoped_model(*args)
      model.enum scope1: [:foo, :bar]
      create_existing_record(attributes)
      model.new
    end

    def validating_scoped_uniqueness_with_conflicting_next(*args)
      attributes = args.extract_options!
      model = define_scoped_model(*args).new
      2.times do
        attributes[:scope1] = attributes[:scope1].next
        create_record(attributes)
      end
      model
    end
  end

  context 'a model with a case-sensitive uniqueness validation on a string attribute and an existing record' do
    it 'accepts a case-sensitive value for that attribute' do
      expect(case_sensitive_validation_with_existing_value(:string)).
        to matcher
    end

    it 'rejects a case-insensitive value for that attribute' do
      expect(case_sensitive_validation_with_existing_value(:string)).
        not_to matcher.case_insensitive
    end
  end

  context 'a model with a case-sensitive uniqueness validation on an integer attribute with an existing value' do
    it 'accepts a case-insensitive value for that attribute' do
      expect(case_sensitive_validation_with_existing_value(:integer)).
        to matcher.case_insensitive
    end

    it 'accepts a case-sensitive value for that attribute' do
      expect(case_sensitive_validation_with_existing_value(:integer)).to matcher
    end
  end

  context "when the validation allows nil" do
    context "when there is an existing entry with a nil" do
      it "should allow_nil" do
        model = define_model_with_allow_nil
        Example.create!(attr: nil)
        expect(model).to matcher.allow_nil
      end
    end

    if active_model_3_1?
      context 'when the subject has a secure password' do
        it 'allows nil on the attribute' do
          model = define_model(:example, attr: :string, password_digest: :string) do |m|
            validates_uniqueness_of :attr, allow_nil: true
            has_secure_password
          end.new
          expect(model).to matcher.allow_nil
        end
      end
    end

    it "should create a nil and verify that it is allowed" do
      model = define_model_with_allow_nil
      expect(model).to matcher.allow_nil
      Example.all.any?{ |instance| instance.attr.nil? }
    end

    def define_model_with_allow_nil
      define_model(:example, attr: :integer) do
        attr_accessible :attr
        validates_uniqueness_of :attr, allow_nil: true
      end.new
    end
  end

  context "when the validation does not allow a nil" do
    context "when there is an existing entry with a nil" do
      it "should not allow_nil" do
        model = define_model_without_allow_nil
        Example.create!(attr: nil)
        expect(model).not_to matcher.allow_nil
      end
    end

    it "should not allow_nil" do
      model = define_model_without_allow_nil
      expect(model).not_to matcher.allow_nil
    end

    def define_model_without_allow_nil
      define_model(:example, attr: :integer) do
        attr_accessible :attr
        validates_uniqueness_of :attr
      end.new
    end
  end

  context 'when the validation allows blank' do
    context 'when there is an existing record with a blank value' do
      it 'accepts' do
        model = model_allowing_blank
        model.create!(attribute_name => '')
        expect(model.new).to matcher.allow_blank
      end
    end

    context 'when there is not an an existing record with a blank value' do
      it 'still accepts' do
        expect(record_allowing_blank).to matcher.allow_blank
      end

      it 'automatically creates a record' do
        model = model_allowing_blank
        matcher.allow_blank.matches?(model.new)

        record_created = model.all.any? do |instance|
          instance.__send__(attribute_name).blank?
        end

        expect(record_created).to be true
      end
    end

    def attribute_name
      :attr
    end

    def model_allowing_blank
      _attribute_name = attribute_name

      define_model(:example, attribute_name => :string) do
        attr_accessible _attribute_name
        validates_uniqueness_of _attribute_name, allow_blank: true
      end
    end

    def record_allowing_blank
      model_allowing_blank.new
    end
  end

  context 'when the validation does not allow blank' do
    context 'when there is an existing entry with a blank value' do
      it 'rejects' do
        model = model_disallowing_blank
        model.create!(attribute_name => '')
        expect(model.new).not_to matcher.allow_blank
      end
    end

    it 'should not allow_blank' do
      expect(record_disallowing_blank).not_to matcher.allow_blank
    end

    def attribute_name
      :attr
    end

    def model_disallowing_blank
      _attribute_name = attribute_name

      define_model(:example, attribute_name => :string) do
        attr_accessible _attribute_name
        validates_uniqueness_of _attribute_name, allow_blank: false
      end
    end

    def record_disallowing_blank
      model_disallowing_blank.new
    end
  end

  context "when testing that a polymorphic *_type column is one of the validation scopes" do
    it "sets that column to a meaningful value that works with other validations on the same column" do
      user_model = define_model :user
      favorite_columns = {
        favoriteable_id: { type: :integer, options: { null: false } },
        favoriteable_type: { type: :string, options: { null: false } }
      }
      favorite_model = define_model :favorite, favorite_columns do
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

    context "if the model the *_type column refers to is namespaced, and shares the last part of its name with an existing model" do
      it "still works" do
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

  def case_sensitive_validation_with_existing_value(attr_type)
    model = define_model(:example, attr: attr_type) do
      attr_accessible :attr
      validates_uniqueness_of :attr, case_sensitive: true
    end.new
    if attr_type == :string
      Example.create!(attr: 'value')
    elsif attr_type == :integer
      Example.create!(attr: 1)
    else
      raise 'Must be :string or :integer'
    end
    model
  end

  def matcher
    validate_uniqueness_of(:attr)
  end
end
