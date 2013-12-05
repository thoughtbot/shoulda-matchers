require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::ValidateAbsenceOfMatcher do
  before do
    unless active_model_4_0?
      stub_translation("activerecord.errors.messages.present",
                       "must be blank")
    end
  end

  context 'a model with an absence validation' do
    it 'accepts' do
      validating_absence.should matcher
    end

    it 'does not override the default message with a present' do
      validating_absence.should matcher.with_message(nil)
    end
  end

  context 'a model without an absence validation' do
    it 'rejects' do
      define_model(:example, :attr => :string).new.should_not matcher
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
    it 'rejects' do
      active_model.should_not matcher
    end

    it 'provides the correct failure message' do
      unless active_model_4_0?
        stub_translation("activemodel.errors.models.example.attributes.attr.present",
                         "must be blank")
      end
      message = %{Expected errors to include "must be blank" when attr is set to "HEY-OH!", got no errors}

      expect { active_model.should matcher }.to fail_with_message(message)
    end
  end

  context 'a has_many association with an absence validation' do
    it 'requires the attribute to not be set' do
      has_many_children(:absence => true).should validate_absence_of(:children)
    end
  end

  context 'a has_many association without an absence validation' do
    it 'does not require the attribute to not be set' do
      has_many_children(:absence => false).
        should_not validate_absence_of(:children)
    end
  end

  context 'an absent has_and_belongs_to_many association' do
    before do
      @model = has_and_belongs_to_many_children(:absence => true)
      create_table 'children_parents', :id => false do |t|
        t.integer :child_id
        t.integer :parent_id
      end
    end

    it 'accepts' do
      @model.should validate_absence_of(:children)
    end
  end

  context 'a non-absent has_and_belongs_to_many association' do
    before do
      @model = has_and_belongs_to_many_children(:absence => false)
      create_table 'children_parents', :id => false do |t|
        t.integer :child_id
        t.integer :parent_id
      end
    end

    it 'rejects' do
      @model.should_not validate_absence_of(:children)
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

  if active_model_3_2?
    context 'a strictly absent attribute' do
      it 'accepts when the :strict options match' do
        validating_absence(:strict => true).should matcher.strict
      end

      it 'rejects when the :strict options do not match' do
        validating_absence(:strict => false).should_not matcher.strict
      end

      it 'does not override the default message with a present' do
        validating_absence(:strict => true).
          should matcher.strict.with_message(nil)
      end
    end
  end

  context "an attribute with a context-dependent validation" do
    context "without the validation context" do
      it "does not match" do
        validating_absence(:on => :customisable).should_not matcher
      end
    end

    context "with the validation context" do
      it "matches" do
        validating_absence(:on => :customisable).should matcher.on(:customisable)
      end
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
      if active_model_4_0?
        validates_absence_of :attr, options
      else
        validates_inclusion_of :attr, options.merge(:in => [nil, ''], :message => :present)
      end
    end.new
  end

  def active_model(&block)
    define_active_model_class('Example', :accessors => [:attr], &block).new
  end

  def active_model_validating_absence
    active_model do
      if active_model_4_0?
        validates_absence_of :attr
      else
        validates_inclusion_of :attr, :in => [nil, ''], :message => :present
      end
    end
  end

  def has_many_children(options = {})
    define_model :child
    define_model :parent do
      has_many :children
      if options[:absence]
        if active_model_4_0?
          validates_absence_of :children
        else
          validate :no_children
          def no_children
            errors.add(:children, :present) if children.length > 0
          end
        end
      end
    end.new
  end

  def has_and_belongs_to_many_children(options = {})
    define_model :child
    @model = define_model :parent do
      has_and_belongs_to_many :children
      if options[:absence]
        if active_model_4_0?
          validates_absence_of :children
        else
          validate :no_children
          def no_children
            errors.add(:children, :present) if children.length > 0
          end
        end
      end
    end.new
  end

  def active_resource_model
    define_active_resource_class :foo, :attr => :string do
      if active_model_4_0?
        validates_absence_of :attr
      else
        validates_inclusion_of :attr, :in => [nil, ''], :message => :present
      end
    end.new
  end
end
