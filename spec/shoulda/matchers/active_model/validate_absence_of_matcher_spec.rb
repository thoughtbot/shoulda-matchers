require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::ValidateAbsenceOfMatcher do
  if active_model_4_0?
    context 'a model with an absence validation' do
      it 'accepts' do
        validating_absence_of(:attr).should validate_absence_of(:attr)
      end

      it 'does not override the default message with a present' do
        validating_absence_of(:attr).should validate_absence_of(:attr).with_message(nil)
      end
    end

    context 'a model without an absence validation' do
      it 'rejects' do
        model = define_model(:example, attr: :string).new
        model.should_not validate_absence_of(:attr)
      end
    end

    context 'an ActiveModel class with an absence validation' do
      it 'accepts' do
        active_model_validating_absence_of(:attr).should validate_absence_of(:attr)
      end

      it 'does not override the default message with a blank' do
        active_model_validating_absence_of(:attr).should validate_absence_of(:attr).with_message(nil)
      end
    end

    context 'an ActiveModel class without an absence validation' do
      it 'rejects' do
        active_model_with(:attr).should_not validate_absence_of(:attr)
      end

      it 'provides the correct failure message' do
        message = %{Expected errors to include "must be blank" when attr is set to "an arbitrary value", got no errors}

        expect { active_model_with(:attr).should validate_absence_of(:attr) }.to fail_with_message(message)
      end
    end

    context 'a has_many association with an absence validation' do
      it 'requires the attribute to not be set' do
        having_many(:children, absence: true).should validate_absence_of(:children)
      end
    end

    context 'a has_many association without an absence validation' do
      it 'does not require the attribute to not be set' do
        having_many(:children, absence: false).
          should_not validate_absence_of(:children)
      end
    end

    context 'an absent has_and_belongs_to_many association' do
      it 'accepts' do
        model = having_and_belonging_to_many(:children, absence: true)
        model.should validate_absence_of(:children)
      end
    end

    context 'a non-absent has_and_belongs_to_many association' do
      it 'rejects' do
        model = having_and_belonging_to_many(:children, absence: false)
        model.should_not validate_absence_of(:children)
      end
    end

    context "an i18n translation containing %{attribute} and %{model}" do
      after { I18n.backend.reload! }

      it "does not raise an exception" do
        stub_translation("activerecord.errors.messages.present",
                         "%{attribute} must be blank in a %{model}")

        expect {
          validating_absence_of(:attr).should validate_absence_of(:attr)
        }.to_not raise_exception
      end
    end

    context "an attribute with a context-dependent validation" do
      context "without the validation context" do
        it "does not match" do
          validating_absence_of(:attr, on: :customisable).should_not validate_absence_of(:attr)
        end
      end

      context "with the validation context" do
        it "matches" do
          validating_absence_of(:attr, on: :customisable).should validate_absence_of(:attr).on(:customisable)
        end
      end
    end

    def validating_absence_of(attr, options = {})
      define_model :example, attr => :string do
        validates_absence_of attr, options
      end.new
    end

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
  end
end
