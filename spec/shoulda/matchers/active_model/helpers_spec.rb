# encoding: UTF-8
require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::Helpers do
  include Shoulda::Matchers::ActiveModel
  after { I18n.backend.reload! }

  describe 'default_error_message' do
    context 'if the translation for the model attribute’s error exists' do
      it 'provides the right error message for validate_presence_of' do
        store_translations

        assert_presence_validation_has_correct_message
      end

      it 'provides the right error message for validates_length_of' do
        store_translations

        assert_length_validation_has_correct_message
      end
    end

    context 'if no translation for the model attribute’s error exists' do
      context 'and the translation for the model’s error exists' do
        it 'provides the right error message for validate_presence_of' do
          store_translations(:without => :model_attribute)

          assert_presence_validation_has_correct_message
        end

        it 'provides the right error message for validates_length_of' do
          store_translations(:without => :model_attribute)

          assert_length_validation_has_correct_message
        end
      end

      context 'and no translation for the model’s error exists' do
        context 'and the translation for the message exists' do
          it 'provides the right error message for validate_presence_of' do
            store_translations(:without => [:model_attribute, :model])

            assert_presence_validation_has_correct_message
          end

          it 'provides the right error message for validates_length_of' do
            store_translations(:without => [:model_attribute, :model])

            assert_length_validation_has_correct_message
          end
        end

        context 'and no translation for the message exists' do
          context 'and the translation for the attribute exists' do
            it 'provides the right error message for validate_presence_of' do
              store_translations(:without => [:model_attribute, :model, :message])

              assert_presence_validation_has_correct_message
            end

            it 'provides the right error message for validates_length_of' do
              store_translations(:without => [:model_attribute, :model, :message])

              assert_length_validation_has_correct_message
            end
          end

          context 'and no translation for the attribute exists' do
            it 'provides the general error message for validate_presence_of' do
              assert_presence_validation_has_correct_message
            end

            it 'provides the general error message for validates_length_of' do
              assert_length_validation_has_correct_message
            end
          end
        end
      end
    end

    if active_model_3_0?
      context 'if ActiveModel::Errors#generate_message behavior has changed' do
        it 'provides the right error message for validate_presence_of' do
          stub_active_model_message_generation(:type => :blank,
                                               :message => 'Behavior has diverged.')
          assert_presence_validation_has_correct_message
        end
      end
    end
  end

  def assert_presence_validation_has_correct_message
    define_model :example, :attr => :string do
      validates_presence_of :attr
    end.new.should validate_presence_of(:attr)
  end

  def assert_length_validation_has_correct_message
    define_model :example, :attr => :string do
      validates_length_of :attr, :is => 40, :allow_blank => true
    end.new.should ensure_length_of(:attr).is_equal_to(40)
  end

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

  def stub_active_model_message_generation(options = {})
    attribute = options.delete(:attribute) || :attr
    message = options.delete(:message)
    type = options.delete(:type)

    ActiveModel::Errors.any_instance.expects(:generate_message).with(attribute, type, {}).at_least_once.returns(message)
  end
end
