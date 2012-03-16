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
  end
end
