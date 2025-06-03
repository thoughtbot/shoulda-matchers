require 'unit_spec_helper'

describe Shoulda::Matchers::ActiveRecord::HaveRichTextMatcher, type: :model do
  def self.rich_text_is_defined?
    defined?(ActionText::RichText)
  end

  def self.encrypted_rich_text_is_defined?
    defined?(ActionText::EncryptedRichText)
  end

  context '#description' do
    it 'returns the message including the name of the provided association' do
      matcher = have_rich_text(:content)
      expect(matcher.description).
        to eq('have configured :content as a ActionText::RichText association')
    end
  end

  if rich_text_is_defined?
    context 'when the model has a RichText association' do
      it 'matches when the subject configures has_rich_text' do
        valid_record = new_post(is_rich_text_association: true)

        expected_message = 'Did not expect Post to have ActionText::RichText :content'

        expect { have_rich_text(:content) }.
          to match_against(valid_record).
          or_fail_with(expected_message)
      end
    end

    if encrypted_rich_text_is_defined?
      context 'when the model has an encrypted RichText association' do
        it 'matches when the subject configures has_rich_text' do
          valid_record = new_post(is_rich_text_association: true, encrypted: true)

          expected_message = 'Did not expect Post to have ActionText::RichText :content'

          expect { have_rich_text(:content) }.
            to match_against(valid_record).
            or_fail_with(expected_message)
        end
      end
    end

    context 'when the model does not have a RichText association' do
      it 'does not match when provided with a model attribute that exist' do
        invalid_record = new_post(has_invalid_content: true)
        expected_message = 'Expected Post to have configured :invalid_content as a ' \
          'ActionText::RichText association'

        expect { have_rich_text(:invalid_content) }.
          not_to match_against(invalid_record).
          and_fail_with(expected_message)
      end

      it 'does not match when provided with a model attribute that does not exist' do
        invalid_record = new_post
        expected_message = 'Expected Post to have configured :invalid_attribute as a ' \
          'ActionText::RichText association but :invalid_attribute does not exist'

        expect { have_rich_text(:invalid_attribute) }.
          not_to match_against(invalid_record).
          and_fail_with(expected_message)
      end
    end
  else
    it 'does not match when provided with a model attribute that exist' do
      invalid_record = new_post(has_invalid_content: true)
      expected_message = 'Expected Post to have configured :invalid_content as a ' \
        'ActionText::RichText association'

      expect { have_rich_text(:invalid_content) }.
        not_to match_against(invalid_record).
        and_fail_with(expected_message)
    end

    it 'does not match when provided with a model attribute that does not exist' do
      invalid_record = new_post
      expected_message = 'Expected Post to have configured :invalid_attribute as a ' \
        'ActionText::RichText association but :invalid_attribute does not exist'

      expect { have_rich_text(:invalid_attribute) }.
        not_to match_against(invalid_record).
        and_fail_with(expected_message)
    end
  end

  def new_post(has_invalid_content: false, is_rich_text_association: false, encrypted: false)
    columns = {}

    if has_invalid_content
      columns[:invalid_content] = :string
    end

    define_model 'Post', columns do
      if is_rich_text_association
        if encrypted
          has_rich_text :content, encrypted: encrypted
        else
          has_rich_text :content
        end
      end
    end.new
  end
end
