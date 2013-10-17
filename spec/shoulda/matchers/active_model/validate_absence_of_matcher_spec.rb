require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::ValidateAbsenceOfMatcher do
  context 'a model with an absence validation' do
    it 'accepts' do
      validating_absence.should matcher
    end

    it 'does not override the default message with a blank' do
      validating_absence.should matcher.with_message(nil)
    end
  end

  context 'a model without an absence validation' do
    it 'accepts' do
      define_model(:example, :attr => :string).new.should matcher
    end
  end

  context 'an ActiveModel class with an absence validation' do
    it 'accepts' do
      active_model_validating_absence.should matcher
    end

    it 'does not override the default message with a blank' do
      active_model_validating_absence.should matcher.with_message(nil)
    end
  end

  context 'an ActiveModel class without an absence validation' do
    it 'accepts' do
      active_model.should matcher
    end

    it 'does not raise an exception' do
      expect { active_model.should matcher }.to_not raise_exception
    end
  end

  context 'a has_many association with an absence validation' do
    it 'does not require the attribute to be set' do
      has_many_children(:absence => true).should validate_absence_of(:children)
    end
  end

  context 'a has_many association without an absence validation' do
    it 'does not require the attribute to be set' do
      has_many_children.should validate_absence_of(:children)
    end
  end

  context 'a required has_and_belongs_to_many association' do
    before do
      define_model :child
      @model = define_model :parent do
        has_and_belongs_to_many :children
        validates_absence_of :children
      end.new
      create_table 'children_parents', :id => false do |t|
        t.integer :child_id
        t.integer :parent_id
      end
    end

    it 'accepts' do
      @model.should validate_absence_of(:children)
    end
  end

  context 'an optional has_and_belongs_to_many association' do
    before do
      define_model :child
      @model = define_model :parent do
        has_and_belongs_to_many :children
      end.new
      create_table 'children_parents', :id => false do |t|
        t.integer :child_id
        t.integer :parent_id
      end
    end

    it 'accepts' do
      @model.should validate_absence_of(:children)
    end
  end

  context "an i18n translation containing %{attribute} and %{model}" do
    before do
      stub_translation(
        "activerecord.errors.messages.present",
        "Please enter a %{attribute} for your %{model}")
    end

    after { I18n.backend.reload! }

    it "does not raise an exception" do
      expect {
        validating_absence.should validate_absence_of(:attr)
      }.to_not raise_exception
    end
  end

  context 'an active_resource model' do
    context 'with the validation context' do
      it 'does not raise an exception' do
        expect {
          active_resource_model.should validate_absence_of(:attr)
        }.to_not raise_exception
      end
    end
  end

  def matcher
    validate_absence_of(:attr)
  end

  def validating_absence(options = {})
    define_model :example, :attr => :string do
      validates_absence_of :attr, options
    end.new
  end

  def active_model(&block)
    define_active_model_class('Example', :accessors => [:attr], &block).new
  end

  def active_model_validating_absence
    active_model { validates_absence_of :attr }
  end

  def has_many_children(options = {})
    define_model :child
    define_model :parent do
      has_many :children
      if options[:absence]
        validates_absence_of :children
      end
    end.new
  end

  def active_resource_model
    define_active_resource_class :foo, :attr => :string do
      validates_absence_of :attr
    end.new
  end
end
