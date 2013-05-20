require 'spec_helper'

describe Shoulda::Matchers::ActiveRecord::SerializeMatcher do
  it 'accepts when the attribute is serialized' do
    with_serialized_attr.should serialize(:attr)
  end

  context 'when attribute is not serialized' do
    it 'rejects' do
      unserialized_model.should_not serialize(:attr)
    end

    it 'assigns a helpful failure message' do
      matcher = serialize(:attr)

      matcher.matches?(unserialized_model)

      matcher.failure_message_for_should.should =~ /to serialize the attribute called :attr/
    end

    it 'assigns a helpful failure message when using #as' do
      matcher = serialize(:attr).as(Hash)

      matcher.matches?(unserialized_model)

      matcher.failure_message_for_should.should =~ /with a type of Hash/
    end

    it 'assigns a helpful failure message when using #as_instance_of' do
      matcher = serialize(:attr).as_instance_of(Hash)

      matcher.matches?(unserialized_model)

      matcher.failure_message_for_should.should =~ /with an instance of Hash/
    end

    def unserialized_model
      @model ||= define_model(:example, :attr => :string).new
    end
  end

  context 'an attribute that is serialized as a specific type' do
    it 'accepts when the types match' do
      with_serialized_attr(Hash).should serialize(:attr).as(Hash)
    end

    it 'rejects when the types do not match' do
      with_serialized_attr(Hash).should_not serialize(:attr).as(String)
    end

    it 'rejects when using as_instance_of' do
      with_serialized_attr(Hash).should_not serialize(:attr).as_instance_of(Hash)
    end
  end

  context 'a serializer that is an instance of a class' do
    it 'accepts when using #as_instance_of' do
      define_serializer(:ExampleSerializer)
      with_serialized_attr(ExampleSerializer.new).
        should serialize(:attr).as_instance_of(ExampleSerializer)
    end

    it 'rejects when using #as' do
      define_serializer(:ExampleSerializer)
      with_serialized_attr(ExampleSerializer.new).
        should_not serialize(:attr).as(ExampleSerializer)
    end
  end

  def with_serialized_attr(type = nil)
    define_model(:example, :attr => :string) do
      if type
        serialize :attr, type
      else
        serialize :attr
      end
    end.new
  end

  def define_serializer(name)
    define_class(name) do
      def load(*); end
      def dump(*); end
    end
  end
end
