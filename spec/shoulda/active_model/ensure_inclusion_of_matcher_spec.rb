require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::EnsureInclusionOfMatcher do
  context "with no validations" do
    before do
      @model = define_model(:example, :attr => :string) do
      end.new
    end

    it "should reject an array which does not have a validator defined" do
      @model.should_not ensure_inclusion_of(:attr).in_array(%w(Yes No))
    end
  end

  context "with true/false values" do
    it "can verify outside values to ensure the negative case" do
      model = define_model(:example, :attr => :string).new

      model.should_not ensure_inclusion_of(:attr).in_array([true, false])
    end
  end

  context "where we cannot determine a value outside the array" do
    it "should raise a custom exception" do
      model = define_model(:example, :attr => :string).new

      arbitrary_string = Shoulda::Matchers::ActiveModel::EnsureInclusionOfMatcher::ARBITRARY_OUTSIDE_STRING
      expect { model.should ensure_inclusion_of(:attr).in_array([arbitrary_string]) }.to raise_error Shoulda::Matchers::ActiveModel::CouldNotDetermineValueOutsideOfArray
    end
  end

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

  context "an attribute which must be included in an array" do
    before do
      @model = define_model(:example, :attr => :string) do
        validates_inclusion_of :attr, :in => %w(one two)
      end.new
    end

    it "accepts with correct array" do
      @model.should ensure_inclusion_of(:attr).in_array(%w(one two))
    end

    it "rejects when only part of array matches" do
      @model.should_not ensure_inclusion_of(:attr).in_array(%w(one wrong_value))
    end

    it "rejects when array doesn't match at all" do
      @model.should_not ensure_inclusion_of(:attr).in_array(%w(cat dog))
    end

    it "has correct description" do
      ensure_inclusion_of(:attr).in_array([true, 'dog']).description.should == 'ensure inclusion of attr in [true, "dog"]'
    end

    it "rejects allow_blank" do
      @model.should_not ensure_inclusion_of(:attr).in_array(['one', 'two']).allow_blank(true)
      @model.should ensure_inclusion_of(:attr).in_array(['one', 'two']).allow_blank(false)
    end

    it "rejects allow_nil" do
      @model.should_not ensure_inclusion_of(:attr).in_array(['one', 'two']).allow_nil(true)
      @model.should ensure_inclusion_of(:attr).in_array(['one', 'two']).allow_nil(false)
    end
  end

  context "allowed blank and allowed nil" do
    before do
      @model = define_model(:example, :attr => :string) do
          validates_inclusion_of :attr, :in => %w(one two), :allow_blank => true, :allow_nil => true
      end.new
    end

    it "allows allow_blank" do
      @model.should ensure_inclusion_of(:attr).in_array(['one', 'two']).allow_blank(true)
      @model.should ensure_inclusion_of(:attr).in_array(['one', 'two']).allow_blank()
      @model.should_not ensure_inclusion_of(:attr).in_array(['one', 'two']).allow_blank(false)
    end

    it "allows allow_nil" do
      @model.should ensure_inclusion_of(:attr).in_array(['one', 'two']).allow_nil(true)
      @model.should ensure_inclusion_of(:attr).in_array(['one', 'two']).allow_nil()
      @model.should_not ensure_inclusion_of(:attr).in_array(['one', 'two']).allow_nil(false)
    end
  end

  context "an attribute allowing some blank values but not others" do
    before do
      @model = define_model(:example, :attr => :string) do
        validates_inclusion_of :attr, :in => ['one', 'two', '']
      end.new
    end

    it "rejects allow_blank" do
      @model.should_not ensure_inclusion_of(:attr).in_array(['one', 'two', '']).allow_blank(true)
      @model.should ensure_inclusion_of(:attr).in_array(['one', 'two', '']).allow_blank(false)
    end
  end

  if Rails::VERSION::STRING.to_f >= 3.2
    context "a strict attribute which must be included in a range" do
      before do
        @model = define_model(:example, :attr => :integer) do
          validates_inclusion_of :attr, :in => 2..5, :strict => true
        end.new
      end

      it "should accept ensuring the correct range" do
        @model.should ensure_inclusion_of(:attr).in_range(2..5).strict
      end

      it "should not accept ensuring another range" do
        @model.should_not ensure_inclusion_of(:attr).in_range(2..6).strict
      end
    end
  end
end
