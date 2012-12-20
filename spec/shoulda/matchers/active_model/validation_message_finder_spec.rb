require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::ValidationMessageFinder do
  context '#allow_description' do
    it 'describes its attribute' do
      finder = build_finder(:attribute => :attr)

      description = finder.allow_description('allowed values')

      description.should == 'allow attr to be set to allowed values'
    end
  end

  context '#expected_message_from' do
    it 'returns the message as-is' do
      finder = build_finder

      message = finder.expected_message_from('some message')

      message.should == 'some message'
    end
  end

  context '#has_messages?' do
    it 'has messages when some validations fail' do
      finder = build_finder(:format => /abc/, :value => 'xyz')

      result = finder.has_messages?

      result.should be_true
    end

    it 'has no messages when all validations pass' do
      finder = build_finder(:format => /abc/, :value => 'abc')

      result = finder.has_messages?

      result.should be_false
    end
  end

  context '#messages' do
    it 'returns errors for the given attribute' do
      finder = build_finder(:format => /abc/, :value => 'xyz')

      messages = finder.messages

      messages.should == ['is invalid']
    end
  end

  context '#messages_description' do
    it 'describes errors for the given attribute' do
      finder = build_finder(
        :attribute => :attr,
        :format => /abc/,
        :value => 'xyz'
      )

      description = finder.messages_description

      expected_messages = ['attr is invalid ("xyz")']
      description.should == "errors: #{expected_messages}"
    end

    it 'describes errors when there are none' do
      finder = build_finder(:format => /abc/, :value => 'abc')

      description = finder.messages_description

      description.should == 'no errors'
    end
  end

  context '#source_description' do
    it 'describes the source of its messages' do
      finder = build_finder

      description = finder.source_description

      description.should == 'errors'
    end
  end

  def build_finder(arguments = {})
    arguments[:attribute] ||= :attr
    instance = build_instance_validating(
      arguments[:attribute],
      arguments[:format] || /abc/,
      arguments[:value] || 'abc'
    )
    Shoulda::Matchers::ActiveModel::ValidationMessageFinder.new(
      instance,
      arguments[:attribute]
    )
  end

  def build_instance_validating(attribute, format, value)
    model_class = define_model(:example, attribute => :string) do
      attr_accessible attribute
      validates_format_of attribute, :with => format
    end

    model_class.new(attribute => value)
  end
end
