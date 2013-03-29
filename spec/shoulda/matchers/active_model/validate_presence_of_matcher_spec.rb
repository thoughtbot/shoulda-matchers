require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::ValidatePresenceOfMatcher do
  context 'a model with a presence validation' do
    it 'accepts' do
      validating_presence.should matcher
    end

    it 'does not override the default message with a blank' do
      validating_presence.should matcher.with_message(nil)
    end
  end

  context 'a model without a presence validation' do
    it 'rejects' do
      define_model(:example, :attr => :string).new.should_not matcher
    end
  end

  context 'an ActiveModel class with a presence validation' do
    it 'accepts' do
      active_model_validating_presence.should matcher
    end

    it 'does not override the default message with a blank' do
      active_model_validating_presence.should matcher.with_message(nil)
    end
  end

  context 'an ActiveModel class without a presence validation' do
    it 'rejects' do
      define_active_model_class('Example', :accessors => [:attr]).new.
        should_not matcher
    end
  end

  context 'a has_many association with a presence validation' do
    it 'requires the attribute to be set' do
      has_many_children(:presence => true).should validate_presence_of(:children)
    end
  end

  context 'a has_many association without a presence validation' do
    it 'does not require the attribute to be set' do
      has_many_children(:presence => false).
        should_not validate_presence_of(:children)
    end
  end

  context 'a required has_and_belongs_to_many association' do
    before do
      define_model :child
      @model = define_model :parent do
        has_and_belongs_to_many :children
        validates_presence_of :children
      end.new
      create_table 'children_parents', :id => false do |t|
        t.integer :child_id
        t.integer :parent_id
      end
    end

    it 'accepts' do
      @model.should validate_presence_of(:children)
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

    it 'rejects' do
      @model.should_not validate_presence_of(:children)
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
        validating_presence.should validate_presence_of(:attr)
      }.to_not raise_exception
    end
  end

  if active_model_3_2?
    context 'a strictly required attribute' do
      it 'accepts when the :strict options match' do
        validating_presence(:strict => true).should matcher.strict
      end

      it 'rejects when the :strict options do not match' do
        validating_presence(:strict => false).should_not matcher.strict
      end
    end

    it 'does not override the default message with a blank' do
      validating_presence(:strict => true).
        should matcher.strict.with_message(nil)
    end
  end

  def matcher
    validate_presence_of(:attr)
  end

  def validating_presence(options = {})
    define_model :example, :attr => :string do
      validates_presence_of :attr, options
    end.new
  end

  def active_model_validating_presence
    define_active_model_class('Example', :accessors => [:attr]) do
      validates_presence_of :attr
    end.new
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
end
