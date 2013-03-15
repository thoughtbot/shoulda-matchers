require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::ValidateUniquenessOfMatcher do
  context 'a model without a a uniqueness validation' do
    it 'rejects' do
      model = define_model(:example, :attr => :string) { attr_accessible :attr } .new
      Example.create!(:attr => 'value')
      model.should_not matcher
    end
  end

  context 'a model with a uniqueness validation' do
    context 'with an existing record' do
      it 'requires a unique value for that attribute' do
        create_existing
        validating_uniqueness_with_other.should matcher
      end

      it 'accepts when the subject is an existing record' do
        create_existing.should matcher
      end

      it 'rejects when a scope is specified' do
        create_existing
        validating_uniqueness_with_other.should_not matcher.scoped_to(:other)
      end

      def create_existing
        define_model_with_other
        Example.create!(:attr => 'value', :other => 1)
      end
    end

    context 'without an existing record' do
      it 'does not require a created instance' do
        define_model_with_other
        Example.count.should == 0
        validating_uniqueness_with_other.should matcher
      end
    end

    def define_model_with_other(options = {})
      @model ||= define_model(:example, :attr => :string, :other => :integer) do
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
      validating_uniqueness_with_existing_record(:message => 'Bad value').
        should_not matcher
    end

    it 'rejects when the messages do not match' do
      validating_uniqueness_with_existing_record(:message => 'Bad value').
        should_not matcher.with_message(/abc/)
    end

    it 'accepts when the messages match' do
      validating_uniqueness_with_existing_record(:message => 'Bad value').
        should matcher.with_message(/Bad/)
    end

    def validating_uniqueness_with_existing_record(options = {})
      model = define_model(:example, :attr => :string) do
        attr_accessible :attr
        validates_uniqueness_of :attr, options
      end.new
      Example.create!(:attr => 'value')
      model
    end
  end

  context 'a model with a scoped uniqueness validation with an existing value' do
    it 'accepts when the correct scope is specified' do
      validating_scoped_uniqueness([:scope1, :scope2]).
        should matcher.scoped_to(:scope1, :scope2)
    end

    it 'accepts when the subject is an existing record' do
      define_scoped_model([:scope1, :scope2])
      create_existing_record.should matcher.scoped_to(:scope1, :scope2)
    end

    it 'rejects when too narrow of a scope is specified' do
      validating_scoped_uniqueness([:scope1, :scope2]).
        should_not matcher.scoped_to(:scope1, :scope2, :other)
    end

    it 'rejects when too broad of a scope is specified' do
      validating_scoped_uniqueness([:scope1, :scope2]).
        should_not matcher.scoped_to(:scope1)
    end

    it 'rejects when a different scope is specified' do
      validating_scoped_uniqueness([:scope1]).
        should_not matcher.scoped_to(:other)
    end

    it 'rejects when no scope is specified' do
      validating_scoped_uniqueness([:scope1]).should_not matcher
    end

    it 'rejects when a non-existent attribute is specified as a scope' do
      validating_scoped_uniqueness([:scope1]).
        should_not matcher.scoped_to(:fake)
    end

    def create_existing_record
      @existing ||= Example.create!(:attr => 'value', :scope1 => 1, :scope2 => 2, :other => 3)
    end

    def define_scoped_model(scope)
      define_model(:example, :attr => :string, :scope1 => :integer,
        :scope2 => :integer, :other => :integer) do
        attr_accessible :attr, :scope1, :scope2, :other
        validates_uniqueness_of :attr, :scope => scope
      end
    end

    def validating_scoped_uniqueness(scope)
      model = define_scoped_model(scope).new
      create_existing_record
      model
    end
  end

  context 'a model with a case-sensitive uniqueness validation on a string attribute and an existing record' do
    it 'accepts a case-sensitive value for that attribute' do
      case_sensitive_validation_with_existing_value(:string).
        should matcher
    end

    it 'rejects a case-insensitive value for that attribute' do
      case_sensitive_validation_with_existing_value(:string).
        should_not matcher.case_insensitive
    end
  end

  context 'a model with a case-sensitive uniqueness validation on an integer attribute with an existing value' do
    it 'accepts a case-insensitive value for that attribute' do
      case_sensitive_validation_with_existing_value(:integer).
        should matcher.case_insensitive
    end

    it 'accepts a case-sensitive value for that attribute' do
      case_sensitive_validation_with_existing_value(:integer).should matcher
    end
  end

  def case_sensitive_validation_with_existing_value(attr_type)
    model = define_model(:example, :attr => attr_type) do
      attr_accessible :attr
      validates_uniqueness_of :attr, :case_sensitive => true
    end.new
    if attr_type == :string
      Example.create!(:attr => 'value')
    elsif attr_type == :integer
      Example.create!(:attr => 1)
    else
      raise 'Must be :string or :integer'
    end
    model
  end

  def matcher
    validate_uniqueness_of(:attr)
  end
end
