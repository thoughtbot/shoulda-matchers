# encoding: UTF-8
require "spec_helper"

def store_translations(options = {:without => []})
  options[:without] = Array.wrap(options[:without] || [])

  translations = {
    :activerecord => {
      :errors => {
        :models => {
          :example => {
              :attributes => {
              :attr => {}
            }
          }
        },
        :messages => {}
      }
    },
    :errors => {
      :attributes => {
        :attr => {}
      },
      :messages => {}
    }
  }

  unless options[:without].include?(:model_attribute)
    translations[:activerecord][:errors][:models][:example][:attributes][:attr][:blank] = "Don't you do that to me!"
    translations[:activerecord][:errors][:models][:example][:attributes][:attr][:wrong_length] = "Don't you do that to me!"
  end

  unless options[:without].include?(:model)
    translations[:activerecord][:errors][:models][:example][:blank] = 'Give it one more try!'
    translations[:activerecord][:errors][:models][:example][:wrong_length] = 'Give it one more try!'
  end

  unless options[:without].include?(:message)
    translations[:activerecord][:errors][:messages][:blank] = 'Oh no!'
    translations[:activerecord][:errors][:messages][:wrong_length] = 'Oh no!'
  end

  unless options[:without].include?(:attribute)
    translations[:errors][:attributes][:attr][:blank] = 'Seriously?'
    translations[:errors][:attributes][:attr][:wrong_length] = 'Seriously?'
  end

  I18n.backend.store_translations(:en, translations)
end

describe Shoulda::Matchers::ActiveModel::Helpers do
  include Shoulda::Matchers::ActiveModel

  describe "default_error_message" do
    before do
      define_model :example, :attr => :string do
        validates_presence_of :attr
        validates_length_of :attr, :is => 40, :allow_blank => true
      end
      @model = Example.new
    end

    after { I18n.backend.reload! }

    context "if the translation for the model attribute’s error exists" do
      it "provides the right error message for validate_presence_of" do
        store_translations
        @model.should validate_presence_of(:attr)
      end

      it "provides the right error message for validates_length_of" do
        store_translations
        @model.should ensure_length_of(:attr).is_equal_to(40)
      end
    end

    context "if no translation for the model attribute’s error exists" do
      context "and the translation for the model’s error exists" do
        it "provides the right error message for validate_presence_of" do
          store_translations(:without => :model_attribute)
          @model.should validate_presence_of(:attr)
        end

        it "provides the right error message for validates_length_of" do
          store_translations(:without => :model_attribute)
          @model.should ensure_length_of(:attr).is_equal_to(40)
        end
      end

      context "and no translation for the model’s error exists" do
        context "and the translation for the message exists" do
          it "provides the right error message for validate_presence_of" do
            store_translations(:without => [:model_attribute, :model])
            @model.should validate_presence_of(:attr)
          end

          it "provides the right error message for validates_length_of" do
            store_translations(:without => [:model_attribute, :model])
            @model.should ensure_length_of(:attr).is_equal_to(40)
          end
        end

        context "and no translation for the message exists" do
          context "and the translation for the attribute exists" do
            it "provides the right error message for validate_presence_of" do
              store_translations(:without => [:model_attribute, :model, :message])
              @model.should validate_presence_of(:attr)
            end

            it "provides the right error message for validates_length_of" do
              store_translations(:without => [:model_attribute, :model, :message])
              @model.should ensure_length_of(:attr).is_equal_to(40)
            end
          end

          context "and no translation for the attribute exists" do
            it "provides the general error message for validate_presence_of" do
              @model.should validate_presence_of(:attr)
            end

            it "provides the general error message for validates_length_of" do
              @model.should ensure_length_of(:attr).is_equal_to(40)
            end
          end
        end
      end
    end
  end
end
