require 'spec_helper'

describe Shoulda::Matchers::ActiveRecord::SerializeMatcher do
  context "an attribute that should be serialized" do
    let(:model) do
      define_model(:example, :attr => :string) do
        serialize :attr
      end.new
    end

    it "should be serialized" do
      model.should serialize(:attr)
    end
  end

  context "an attribute that should be serialized with a type of Hash" do
    let(:model) do
      define_model(:example, :attr => :string) do
        serialize :attr, Hash
      end.new
    end

    it "should be serialized" do
      model.should serialize(:attr).as(Hash)
    end

    it "should not match when using as_instance_of" do
      model.should_not serialize(:attr).as_instance_of(Hash)
    end
  end

  context "an attribute that should be serialized with a type of Array" do
    let(:model) do
      define_model(:example, :attr => :string, :attr2 => :string) do
        serialize :attr, Array
        serialize :attr2, Array
      end.new
    end

    it "should be serialized" do
      model.should serialize(:attr).as(Array)
    end
  end

  context "an attribute that should be serialized but isn't" do
    let(:model) { define_model(:example, :attr => :string).new }

    it "should assign a failure message" do
      matcher = serialize(:attr)
      matcher.matches?(model).should == false
      matcher.failure_message.should_not be_nil
    end

    it "should assign a failure message with 'as'" do
      matcher = serialize(:attr).as(Hash)
      matcher.matches?(model).should == false
      matcher.failure_message.should_not be_nil
    end

    context "a serializer that is an instance of a class" do
      before do
        define_class(:ExampleSerializer) do
          def load(*); end
          def dump(*); end
        end
        define_model :example, :attr => :string do
          serialize :attr, ExampleSerializer.new
        end
        @model = Example.new
      end

      it "should match when using as_instance_of" do
        @model.should serialize(:attr).as_instance_of(ExampleSerializer)
      end

      it "should not match when using as" do
        @model.should_not serialize(:attr).as(ExampleSerializer)
      end
    end
  end
end
