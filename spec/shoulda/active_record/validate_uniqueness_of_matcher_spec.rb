require 'spec_helper'

describe Shoulda::Matchers::ActiveRecord::ValidateUniquenessOfMatcher do

  context "a unique attribute" do
    before do
      @model = define_model(:example, :attr  => :string,
                                      :other => :integer) do
        validates_uniqueness_of :attr
      end.new
    end

    context "with an existing value" do
      before do
        @existing = Example.create!(:attr => 'value', :other => 1)
      end

      it "should require a unique value for that attribute" do
        @model.should validate_uniqueness_of(:attr)
      end

      it "should pass when the subject is an existing record" do
        @existing.should validate_uniqueness_of(:attr)
      end

      it "should fail when a scope is specified" do
        @model.should_not validate_uniqueness_of(:attr).scoped_to(:other)
      end
    end

    context "without an existing value" do
      before do
        Example.find(:first).should be_nil
        @matcher = validate_uniqueness_of(:attr)
      end

      it "should fail to require a unique value" do
        @model.should_not @matcher
      end

      it "should alert the tester that an existing value is not present" do
        @matcher.matches?(@model)
        @matcher.negative_failure_message.should =~ /^Can't find first .*/
      end
    end
  end

  context "a unique attribute with a custom error and an existing value" do
    before do
      @model = define_model(:example, :attr => :string) do
        validates_uniqueness_of :attr, :message => 'Bad value'
      end.new
      Example.create!
    end

    it "should fail when checking the default message" do
      @model.should_not validate_uniqueness_of(:attr)
    end

    it "should fail when checking a message that doesn't match" do
      @model.should_not validate_uniqueness_of(:attr).with_message(/abc/i)
    end

    it "should pass when checking a message that matches" do
      @model.should validate_uniqueness_of(:attr).with_message(/bad/i)
    end
  end

  context "a scoped unique attribute with an existing value" do
    before do
      @model = define_model(:example, :attr   => :string,
                                      :scope1 => :integer,
                                      :scope2 => :integer) do
        validates_uniqueness_of :attr, :scope => [:scope1, :scope2]
      end.new
      @existing = Example.create!(:attr => 'value', :scope1 => 1, :scope2 => 2)
    end

    it "should pass when the correct scope is specified" do
      @model.should validate_uniqueness_of(:attr).scoped_to(:scope1, :scope2)
    end

    it "should pass when the subject is an existing record" do
      @existing.should validate_uniqueness_of(:attr).scoped_to(:scope1, :scope2)
    end

    it "should fail when a different scope is specified" do
      @model.should_not validate_uniqueness_of(:attr).scoped_to(:scope1)
    end

    it "should fail when no scope is specified" do
      @model.should_not validate_uniqueness_of(:attr)
    end

    it "should fail when a non-existent attribute is specified as a scope" do
      @model.should_not validate_uniqueness_of(:attr).scoped_to(:fake)
    end
  end

  context "a non-unique attribute with an existing value" do
    before do
      @model = define_model(:example, :attr => :string).new
      Example.create!(:attr => 'value')
    end

    it "should not require a unique value for that attribute" do
      @model.should_not validate_uniqueness_of(:attr)
    end
  end

  context "a case sensitive unique attribute with an existing value" do
    before do
      @model = define_model(:example, :attr  => :string) do
        validates_uniqueness_of :attr, :case_sensitive => true
      end.new
      Example.create!(:attr => 'value')
    end

    it "should not require a unique, case-insensitive value for that attribute" do
      @model.should_not validate_uniqueness_of(:attr).case_insensitive
    end

    it "should require a unique, case-sensitive value for that attribute" do
      @model.should validate_uniqueness_of(:attr)
    end
  end

  context "a case sensitive unique integer attribute with an existing value" do
    before do
      @model = define_model(:example, :attr  => :integer) do
        validates_uniqueness_of :attr, :case_sensitive => true
      end.new
      Example.create!(:attr => 'value')
    end

    it "should require a unique, case-insensitive value for that attribute" do
      @model.should validate_uniqueness_of(:attr).case_insensitive
    end

    it "should require a unique, case-sensitive value for that attribute" do
      @model.should validate_uniqueness_of(:attr)
    end
  end

end
