require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::ValidateUniquenessOfMatcher do
  context "a unique attribute" do
    before do
      @model = define_model(:example, :attr  => :string,
                                      :other => :integer) do
        attr_accessible :attr, :other
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
        Example.first.should be_nil
        @matcher = validate_uniqueness_of(:attr)
      end

      it "does not not require a created instance" do
        @model.should @matcher
      end
    end
  end

  context "a unique attribute with a custom error and an existing value" do
    before do
      @model = define_model(:example, :attr => :string) do
        attr_accessible :attr
        validates_uniqueness_of :attr, :message => 'Bad value'
      end.new
      Example.create!(:attr => 'value')
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
                                      :scope2 => :integer,
                                      :other => :integer) do
        attr_accessible :attr, :scope1, :scope2, :other
        validates_uniqueness_of :attr, :scope => [:scope1, :scope2]
      end.new
      @existing = Example.create!(:attr => 'value', :scope1 => 1, :scope2 => 2, :other => 3)
    end

    it "should pass when the correct scope is specified" do
      @model.should validate_uniqueness_of(:attr).scoped_to(:scope1, :scope2)
    end

    it "should pass when the subject is an existing record" do
      @existing.should validate_uniqueness_of(:attr).scoped_to(:scope1, :scope2)
    end

    it "should fail when too narrow of a scope is specified" do
      @model.should_not validate_uniqueness_of(:attr).scoped_to(:scope1, :scope2, :other)
    end

    it "should fail when too broad of a scope is specified" do
      @model.should_not validate_uniqueness_of(:attr).scoped_to(:scope1)
    end

    it "should fail when a different scope is specified" do
      @model.should_not validate_uniqueness_of(:attr).scoped_to(:other)
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
      @model = define_model(:example, :attr => :string) do
        attr_accessible :attr
      end.new
      Example.create!(:attr => 'value')
    end

    it "should not require a unique value for that attribute" do
      @model.should_not validate_uniqueness_of(:attr)
    end
  end

  context "a case sensitive unique attribute with an existing value" do
    before do
      @model = define_model(:example, :attr  => :string) do
        attr_accessible :attr
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
        attr_accessible :attr
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

  context "when the validation allows nil" do
    before do
      @model = define_model(:example, :attr  => :integer) do
        attr_accessible :attr
        validates_uniqueness_of :attr, :allow_nil => true
      end.new
    end

    context "when there is an existing entry with a nil" do
      it "should allow_nil" do
        Example.create!(:attr => nil)
        @model.should validate_uniqueness_of(:attr).allow_nil
      end
    end

    it "should create a nil and verify that it is allowed" do
      @model.should validate_uniqueness_of(:attr).allow_nil
      Example.all.any?{ |instance| instance.attr.nil? }
    end
  end

  context "when the validation does not allow a nil" do
    before do
      @model = define_model(:example, :attr  => :integer) do
        attr_accessible :attr
        validates_uniqueness_of :attr
      end.new
    end

    context "when there is an existing entry with a nil" do
      it "should not allow_nil" do
        Example.create!(:attr => nil)
        @model.should_not validate_uniqueness_of(:attr).allow_nil
      end
    end

    it "should not allow_nil" do
      @model.should_not validate_uniqueness_of(:attr).allow_nil
    end
  end
end
