require 'unit_spec_helper'

describe Shoulda::Matchers::ActiveModel::ValidateAbsenceOfMatcher, type: :model do
  if active_model_4_0?
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
        :binary
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
          it "accepts" do
            expect(validating_absence_of(:attr, {}, type: type)).
              to validate_absence_of(:attr)
          end
        end
      end
    end

    context 'a model without an absence validation' do
      it 'rejects' do
        model = define_model(:example, attr: :string).new
        expect(model).not_to validate_absence_of(:attr)
      end
    end

    context 'an ActiveModel class with an absence validation' do
      it 'accepts' do
        expect(active_model_validating_absence_of(:attr)).to validate_absence_of(:attr)
      end

      it 'does not override the default message with a blank' do
        expect(active_model_validating_absence_of(:attr)).to validate_absence_of(:attr).with_message(nil)
      end
    end

    context 'an ActiveModel class without an absence validation' do
      it 'rejects' do
        expect(active_model_with(:attr)).not_to validate_absence_of(:attr)
      end

      it 'provides the correct failure message' do
        message = %{Expected errors to include "must be blank" when attr is set to "an arbitrary value",\ngot no errors}

        expect { expect(active_model_with(:attr)).to validate_absence_of(:attr) }.to fail_with_message(message)
      end
    end

    context 'a has_many association with an absence validation' do
      it 'requires the attribute to not be set' do
        expect(having_many(:children, absence: true)).to validate_absence_of(:children)
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
    end

    context 'a non-absent has_and_belongs_to_many association' do
      it 'rejects' do
        model = having_and_belonging_to_many(:children, absence: false)
        expect(model).not_to validate_absence_of(:children)
      end
    end

    context "an i18n translation containing %{attribute} and %{model}" do
      after { I18n.backend.reload! }

      it "does not raise an exception" do
        stub_translation("activerecord.errors.messages.present",
                         "%{attribute} must be blank in a %{model}")

        expect {
          expect(validating_absence_of(:attr)).to validate_absence_of(:attr)
        }.to_not raise_exception
      end
    end

    context "an attribute with a context-dependent validation" do
      context "without the validation context" do
        it "does not match" do
          expect(validating_absence_of(:attr, on: :customisable)).not_to validate_absence_of(:attr)
        end
      end

      context "with the validation context" do
        it "matches" do
          expect(validating_absence_of(:attr, on: :customisable)).to validate_absence_of(:attr).on(:customisable)
        end
      end
    end

    def validating_absence_of(attr, validation_options = {}, given_column_options = {})
      default_column_options = { type: :string, options: {} }
      column_options = default_column_options.merge(given_column_options)

      define_model :example, attr => column_options do
        validates_absence_of attr, validation_options
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
