require 'unit_spec_helper'

describe Shoulda::Matchers::ActiveModel::ValidatePresenceOfMatcher, type: :model do
  context 'a model with a presence validation' do
    it 'accepts' do
      expect(validating_presence).to matcher
    end

    it 'does not override the default message with a blank' do
      expect(validating_presence).to matcher.with_message(nil)
    end
  end

  context 'a model without a presence validation' do
    it 'rejects' do
      expect(define_model(:example, attr: :string).new).not_to matcher
    end
  end

  context 'an ActiveModel class with a presence validation' do
    it 'accepts' do
      expect(active_model_validating_presence).to matcher
    end

    it 'does not override the default message with a blank' do
      expect(active_model_validating_presence).to matcher.with_message(nil)
    end
  end

  context 'an ActiveModel class without a presence validation' do
    it 'rejects' do
      expect(active_model).not_to matcher
    end

    it 'provides the correct failure message' do
      message = %{Expected errors to include "can't be blank" when attr is set to nil,\ngot no errors}

      expect { expect(active_model).to matcher }.to fail_with_message(message)
    end
  end

  context 'a has_many association with a presence validation' do
    it 'requires the attribute to be set' do
      expect(has_many_children(presence: true)).to validate_presence_of(:children)
    end
  end

  context 'a has_many association without a presence validation' do
    it 'does not require the attribute to be set' do
      expect(has_many_children(presence: false)).
        not_to validate_presence_of(:children)
    end
  end

  context 'a required has_and_belongs_to_many association' do
    before do
      define_model :child
      @model = define_model :parent do
        has_and_belongs_to_many :children
        validates_presence_of :children
      end.new
      create_table 'children_parents', id: false do |t|
        t.integer :child_id
        t.integer :parent_id
      end
    end

    it 'accepts' do
      expect(@model).to validate_presence_of(:children)
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

    it 'rejects' do
      expect(@model).not_to validate_presence_of(:children)
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

  if active_model_3_2?
    context 'a strictly required attribute' do
      it 'accepts when the :strict options match' do
        expect(validating_presence(strict: true)).to matcher.strict
      end

      it 'rejects when the :strict options do not match' do
        expect(validating_presence(strict: false)).not_to matcher.strict
      end
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

  context 'an active_resource model' do
    context 'with the validation context' do
      it 'does not raise an exception' do
        expect {
          expect(active_resource_model).to validate_presence_of(:attr)
        }.to_not raise_exception
      end
    end
  end

  if rails_4_x?
    context 'against a pre-set password in a model that has_secure_password' do
      it 'raises a CouldNotSetPasswordError exception' do
        user_class = define_model :user, password_digest: :string do
          has_secure_password validations: false
          validates_presence_of :password
        end

        user = user_class.new
        user.password = 'something'

        error_class = Shoulda::Matchers::ActiveModel::CouldNotSetPasswordError
        expect do
          expect(user).to validate_presence_of(:password)
        end.to raise_error(error_class)
      end
    end
  end

  context 'when the attribute being tested intercepts the blank value we set on it (issue #479)' do
    context 'for a non-collection attribute' do
      it 'does not raise an error' do
        record = define_model :example, attr: :string do
          validates :attr, presence: true

          def attr=(value)
            value = '' if value.nil?
            super(value)
          end
        end.new

        expect do
          expect(record).to validate_presence_of(:attr)
        end.not_to raise_error
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
end
