require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::ValidatePresenceOfMatcher do
  context "a required attribute" do
    before do
      define_model :example, :attr => :string do
        validates_presence_of :attr
      end
      @model = Example.new
    end

    it "should require a value" do
      @model.should validate_presence_of(:attr)
    end

    it "should not override the default message with a blank" do
      @model.should validate_presence_of(:attr).with_message(nil)
    end
  end

  context "a required attribute on a class using ActiveModel::Validations" do
    before do
      define_active_model_class("Example", :accessors => [:attr]) do
        validates_presence_of :attr
      end
      @model = Example.new
    end

    it "should require a value" do
      @model.should validate_presence_of(:attr)
    end

    it "should not override the default message with a blank" do
      @model.should validate_presence_of(:attr).with_message(nil)
    end
  end

  context "an optional attribute" do
    before do
      @model = define_model(:example, :attr => :string).new
    end

    it "should not require a value" do
      @model.should_not validate_presence_of(:attr)
    end
  end

  context "an optional attribute on a class using ActiveModel::Validations" do
    before do
      @model = define_active_model_class("Example", :accessors => [:attr]).new
    end

    it "should not require a value" do
      @model.should_not validate_presence_of(:attr)
    end
  end

  context "a required has_many association" do
    before do
      define_model :child
      @model = define_model :parent do
        has_many :children
        validates_presence_of :children
      end.new
    end

    it "should require the attribute to be set" do
      @model.should validate_presence_of(:children)
    end
  end

  context "an optional has_many association" do
    before do
      define_model :child
      @model = define_model :parent do
        has_many :children
      end.new
    end

    it "should not require the attribute to be set" do
      @model.should_not validate_presence_of(:children)
    end
  end

  context "a required has_and_belongs_to_many association" do
    before do
      define_model :child
      @model = define_model :parent do
        has_and_belongs_to_many :children
        validates_presence_of :children
      end.new
      create_table "children_parents", :id => false do |t|
        t.integer :child_id
        t.integer :parent_id
      end
    end

    it "should require the attribute to be set" do
      @model.should validate_presence_of(:children)
    end
  end

  context "an optional has_and_belongs_to_many association" do
    before do
      define_model :child
      @model = define_model :parent do
        has_and_belongs_to_many :children
      end.new
      create_table "children_parents", :id => false do |t|
        t.integer :child_id
        t.integer :parent_id
      end
    end

    it "should not require the attribute to be set" do
      @model.should_not validate_presence_of(:children)
    end
  end

  if Rails::VERSION::STRING.to_f >= 3.2
    context "a strictly required attribute" do
      before do
        define_model :example, :attr => :string do
          validates_presence_of :attr, :strict => true
        end
        @model = Example.new
      end

      it "should require a value" do
        @model.should validate_presence_of(:attr).strict
      end
    end
  end

end
