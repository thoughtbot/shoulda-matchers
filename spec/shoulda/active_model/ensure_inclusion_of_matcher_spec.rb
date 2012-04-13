require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::EnsureInclusionOfMatcher do

  context "an attribute which must be included in a range" do
    before do
      @model = define_model(:example, :attr => :integer) do
        validates_inclusion_of :attr, :in => 2..5
      end.new
    end

    it "should accept ensuring the correct range" do
      @model.should ensure_inclusion_of(:attr).in_range(2..5)
    end

    it "should reject ensuring a lower minimum value" do
      @model.should_not ensure_inclusion_of(:attr).in_range(1..5)
    end

    it "should reject ensuring a higher minimum value" do
      @model.should_not ensure_inclusion_of(:attr).in_range(3..5)
    end

    it "should reject ensuring a lower maximum value" do
      @model.should_not ensure_inclusion_of(:attr).in_range(2..4)
    end

    it "should reject ensuring a higher maximum value" do
      @model.should_not ensure_inclusion_of(:attr).in_range(2..6)
    end

    it "should not override the default message with a blank" do
      @model.should ensure_inclusion_of(:attr).in_range(2..5).with_message(nil)
    end
  end

  context "an attribute with a custom ranged value validation" do
    before do
      @model = define_model(:example, :attr => :string) do
        validates_inclusion_of :attr, :in => 2..4, :message => 'not good'

      end.new
    end

    it "should accept ensuring the correct range" do
      @model.should ensure_inclusion_of(:attr).in_range(2..4).with_message(/not good/)
    end
  end

  context "an attribute with custom range validations" do
    before do
      define_model :example, :attr => :integer do
        validate :custom_validation
        def custom_validation
          if attr < 2
            errors.add(:attr, 'too low')
          elsif attr > 5
            errors.add(:attr, 'too high')
          end
        end
      end
      @model = Example.new
    end

    it "should accept ensuring the correct range and messages" do
      @model.should ensure_inclusion_of(:attr).in_range(2..5).with_low_message(/low/).with_high_message(/high/)
    end

  end

  context "an attribute which must be included in a array" do
    before do
      @model = define_model(:example_foo, :attr => :boolean) do
        validates_inclusion_of :attr, :in => [true,false]
      end.new(:attr=>true)
    end

    it "should accept ensuring the correct array" do
      @model.should ensure_inclusion_of(:attr).in_array [true,false]
    end
    it "should have the array in the description" do
      ensure_inclusion_of(:attr).in_array([true,false]).description.should  ==  "ensure inclusion of attr in [true, false]"
    end
  end
  
  context "an attribute not included in the array" do
    before do
      @model = define_model(:example_foo, :attr => :boolean) do
        validate :custom_validation
        def custom_validation
          unless [true,false].include? attr 
            errors.add(:attr, 'not boolean')
          end
        end
      end.new
    end

    it "should have an error on attr" do
      @model.should ensure_inclusion_of(:attr).in_array([true,false]).with_message(/boolean/)
    end
    context "should not accept other value then specified" do
      before do
        @model.attr = "foo"
      end
      it  "should not be valid" do
        @model.should ensure_inclusion_of(:attr).in_array([true,false]).with_message(/inclusion/)
      end
    end
  end
  
end
