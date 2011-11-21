# encoding: UTF-8
require "spec_helper"

include Shoulda::Matchers::ActiveModel

def store_translations(options = {:without => []})
  options[:without] ||= []
  options[:without] = [options[:without]] unless options[:without].is_a? Array
  
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
    }}
  translations[:activerecord][:errors][:models][:example][:attributes][:attr][:blank] = 'Don’t you do that to me!' unless options[:without].include?(:model_attribute)
  translations[:activerecord][:errors][:models][:example][:blank] = 'Give it one more try!' unless options[:without].include?(:model)
  translations[:activerecord][:errors][:messages][:blank] = 'Oh no!' unless options[:without].include?(:message)
  translations[:errors][:attributes][:attr][:blank] = 'Seriously?' unless options[:without].include?(:attribute)
  
  I18n.backend.store_translations :en, translations
end

describe Shoulda::Matchers::ActiveModel::Helpers do
  describe "default_error_message" do
    before do
      define_model :example, :attr => :string do
        validates_presence_of :attr
      end
      @model = Example.new
    end
    
    after { I18n.backend.reload! }
    
    context "if the translation for the model attribute’s error exists" do
      it "provides the right error message" do
        store_translations
        @model.should validate_presence_of(:attr)
      end
    end
    
    context "if no translation for the model attribute’s error exists" do
      context "and the translation for the model’s error exists" do
        it "provides the right error message" do
          store_translations :without => :model_attribute
          @model.should validate_presence_of(:attr)
        end
      end
      
      context "and no translation for the model’s error exists" do
        context "and the translation for the message exists" do
          it "provides the right error message" do
            store_translations :without => [:model_attribute, :model]
            @model.should validate_presence_of(:attr)
          end
        end
        
        context "and no translation for the message exists" do
          context "and the translation for the attribute exists" do
            it "provides the right error message" do
              store_translations :without => [:model_attribute, :model, :message]
              @model.should validate_presence_of(:attr)
            end
          end
          
          context "and no translation for the attribute exists" do
            it "provides the general error message" do
              @model.should validate_presence_of(:attr)
            end
          end
        end
      end
    end
  end
end