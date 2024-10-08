require 'unit_spec_helper'

describe Shoulda::Matchers::ActiveRecord::SerializeMatcher, type: :model do
  it 'accepts when the attribute is serialized' do
    expect(with_serialized_attr).to serialize(:attr)
  end

  context 'when attribute is not serialized' do
    it 'rejects' do
      expect(unserialized_model).not_to serialize(:attr)
    end

    it 'assigns a helpful failure message' do
      matcher = serialize(:attr)

      matcher.matches?(unserialized_model)

      expect(matcher.failure_message).to match(/to serialize the attribute called :attr/)
    end

    it 'assigns a helpful failure message when using #as' do
      matcher = serialize(:attr).as(Hash)

      matcher.matches?(unserialized_model)

      expect(matcher.failure_message).to match(/with a type of Hash/)
    end

    it 'assigns a helpful failure message when using #as_instance_of' do
      matcher = serialize(:attr).as_instance_of(Hash)

      matcher.matches?(unserialized_model)

      expect(matcher.failure_message).to match(/with an instance of Hash/)
    end

    def unserialized_model
      @_unserialized_model ||= define_model(:example, attr: :string).new
    end
  end

  context 'an attribute that will end up being serialized as YAML' do
    it 'accepts when the types match' do
      expect(with_serialized_attr(type: Hash, coder: JSON)).to serialize(:attr).as(Hash)
    end

    it 'rejects when the types do not match' do
      expect(with_serialized_attr(type: Hash)).not_to serialize(:attr).as(String)
    end

    it 'rejects when using as_instance_of' do
      expect(with_serialized_attr(type: Hash)).not_to serialize(:attr).as_instance_of(Hash)
    end
  end

  context 'a serializer that is an instance of a class' do
    it 'accepts when using #as_instance_of' do
      define_serializer(:ExampleSerializer)
      expect(with_serialized_attr(coder: ExampleSerializer.new)).
        to serialize(:attr).as_instance_of(ExampleSerializer)
    end

    it 'rejects when using #as' do
      define_serializer(:ExampleSerializer)
      expect(with_serialized_attr(coder: ExampleSerializer.new)).
        not_to serialize(:attr).as(ExampleSerializer)
    end
  end

  def with_serialized_attr(type: nil, coder: YAML)
    args = rails_version >= 7.1 ? [] : [type || coder]

    define_model(:example, attr: :string) do
      if type
        serialize :attr, *args, type: type, coder: coder
      else
        serialize :attr, *args, coder: coder
      end
    end.new
  end

  def define_serializer(name)
    define_class(name) do
      def load(*) # rubocop:disable Lint/NestedMethodDefinition
      end

      def dump(*) # rubocop:disable Lint/NestedMethodDefinition
      end
    end
  end
end
