require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::ValidateUniquenessOfMatcher do
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

  context "a model with non-nullable attribute" do
    context "of type" do
      [:string, :text, :integer, :float, :decimal, :datetime, :timestamp, :time, :date, :binary, :boolean].each do |type|
        context type do
          it "does not raise an error" do
            model = define_model_with_non_nullable(type)
            expect { expect(model).to matcher }.not_to raise_error
          end
        end
      end
    end

    context "that is a primary key" do
      it "does not cause duplicate entry errors by re-using default values for primary keys" do
        create_table :examples, id: false do |t|
          t.string :attr
          t.integer :non_nullable, primary: true
        end
        model_class = define_model(:example, attr: :string) do
          validates_uniqueness_of :attr
        end
        model_1 = model_class.new
        model_2 = model_class.new
        expect(model_1).to matcher
        expect { expect(model_2).to matcher }.not_to raise_error 
      end
    end

    def define_model_with_non_nullable(type)
      define_model(:example, attr: :string, non_nullable: { type: type, options: { null: false } }) do
        attr_accessible :attr, :non_nullable
        validates_uniqueness_of :attr
      end.new
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
