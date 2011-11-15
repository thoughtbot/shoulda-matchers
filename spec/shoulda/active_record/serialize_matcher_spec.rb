require 'spec_helper'

describe Shoulda::Matchers::ActiveRecord::SerializeMatcher do
	context "an attribute that should be serialized" do
		before do
	    define_model :example, :attr => :string do
	      serialize :attr
	    end
	    @model = Example.new
	  end

	  it "should be serialized" do
      @model.should serialize(:attr)
    end
	end

	context "an attribute that should be serialized with a type of Hash" do
		before do
	    define_model :example, :attr => :string do
	      serialize :attr, Hash
	    end
	    @model = Example.new
	  end

	  it "should be serialized" do
      @model.should serialize(:attr).as(Hash)
    end
	end

	context "an attribute that should be serialized with a type of Array" do
		before do
	    define_model :example, :attr => :string, :attr2 => :string do
	      serialize :attr, Array
	      serialize :attr2, Array
	    end
	    @model = Example.new
	  end

	  it "should be serialized" do
      @model.should serialize(:attr).as(Array)
    end
	end

	context "an attribute that should be serialized but isn't" do
		before do
	    define_model :example, :attr => :string
	    @model = Example.new
	  end

    it "should assign a failure message" do
    	matcher = serialize(:attr)
      matcher.matches?(@model).should == false
      matcher.failure_message.should_not be_nil
    end

    it "should assign a failure message with 'as'" do
    	matcher = serialize(:attr).as(Hash)
      matcher.matches?(@model).should == false
      matcher.failure_message.should_not be_nil
    end
	end
end