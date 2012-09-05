require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::CallbackMatcher do
  context "invalid use" do
    before do
      @model = define_model(:example, :attr  => :string,
                                      :other => :integer) do
        attr_accessible :attr, :other
        before_create :dance!, :if => :evaluates_to_false!
        after_save  :shake!, :unless => :evaluates_to_true!
      end.new
    end
    it "should return a specific failure message when used invalidly" do
      matcher = callback(:dance!)
      matcher.matches?(@model).should be_false
      matcher.failure_message.should == "callback dance! can not be tested against an undefined lifecycle, use .before, .after or .around"
      matcher.negative_failure_message.should == "callback dance! can not be tested against an undefined lifecycle, use .before, .after or .around"
    end
  end
  [:save, :create, :update, :destroy].each do |lifecycle|
    context "on #{lifecycle}" do
      before do
        @model = define_model(:example, :attr  => :string,
                                        :other => :integer) do
          attr_accessible :attr, :other
          send(:"before_#{lifecycle}", :dance!, :if => :evaluates_to_false!)
          send(:"after_#{lifecycle}", :shake!, :unless => :evaluates_to_true!)
          send(:"around_#{lifecycle}", :giggle!)
        end.new
      end
      context "as a simple callback test" do
        it "should find the callback before the fact" do
          @model.should callback(:dance!).before(lifecycle)
        end
        it "should find the callback after the fact" do
          @model.should callback(:shake!).after(lifecycle)
        end
        it "should find the callback around the fact" do
          @model.should callback(:giggle!).around(lifecycle)
        end
        it "should not find callbacks that are not there" do
          @model.should_not callback(:scream!).around(lifecycle)
        end
        it "should have a meaningful description" do
          matcher = callback(:dance!).before(lifecycle)
          matcher.description.should == "callback dance! before #{lifecycle}"
        end
      end
      context "with conditions" do
        it "should match the if condition" do
          @model.should callback(:dance!).before(lifecycle).if(:evaluates_to_false!)
        end
        it "should match the unless condition" do
          @model.should callback(:shake!).after(lifecycle).unless(:evaluates_to_true!)
        end
        it "should not find callbacks not matching the conditions" do
          @model.should_not callback(:giggle!).around(lifecycle).unless(:evaluates_to_false!)
        end
        it "should not find callbacks that are not there entirely" do
          @model.should_not callback(:scream!).before(lifecycle).unless(:evaluates_to_false!)
        end
        it "should have a meaningful description" do
          matcher = callback(:dance!).after(lifecycle).unless(:evaluates_to_false!)
          matcher.description.should == "callback dance! after #{lifecycle} unless evaluates_to_false! evaluates to false"
        end
      end
    end
  end
  
  context "on validation" do
    before do
      @model = define_model(:example, :attr  => :string,
                                      :other => :integer) do
        attr_accessible :attr, :other
        before_validation :dance!, :if => :evaluates_to_false!
        after_validation  :shake!, :unless => :evaluates_to_true!
      end.new
    end
    context "as a simple callback test" do
      it "should find the callback before the fact" do
        @model.should callback(:dance!).before(:validation)
      end
      it "should find the callback after the fact" do
        @model.should callback(:shake!).after(:validation)
      end
      it "should not find the callback around the fact" do
        @model.should_not callback(:giggle!).around(:validation)
      end
      it "should not find callbacks that are not there" do
        @model.should_not callback(:scream!).around(:validation)
      end
      it "should have a meaningful description" do
        matcher = callback(:dance!).before(:validation)
        matcher.description.should == "callback dance! before validation"
      end
    end
    context "with conditions" do
      it "should match the if condition" do
        @model.should callback(:dance!).before(:validation).if(:evaluates_to_false!)
      end
      it "should match the unless condition" do
        @model.should callback(:shake!).after(:validation).unless(:evaluates_to_true!)
      end
      it "should not find callbacks not matching the conditions" do
        @model.should_not callback(:giggle!).around(:validation).unless(:evaluates_to_false!)
      end
      it "should not find callbacks that are not there entirely" do
        @model.should_not callback(:scream!).before(:validation).unless(:evaluates_to_false!)
      end
      it "should have a meaningful description" do
        matcher = callback(:dance!).after(:validation).unless(:evaluates_to_false!)
        matcher.description.should == "callback dance! after validation unless evaluates_to_false! evaluates to false"
      end
    end
  end
  
  [:initialize, :find, :touch].each do |lifecycle|
    context "on #{lifecycle}" do
      before do
        @model = define_model(:example, :attr  => :string,
                                        :other => :integer) do
          attr_accessible :attr, :other
          send(:"after_#{lifecycle}", :dance!, :if => :evaluates_to_false!)
          send(:"after_#{lifecycle}", :shake!, :unless => :evaluates_to_true!)
          
          define_method :evaluates_to_false! do
            false
          end
          
          define_method :evaluates_to_true! do
            true
          end
          
        end.new
      end
      context "as a simple callback test" do
        it "should not find a callback before the fact" do
          @model.should_not callback(:dance!).before(lifecycle)
        end
        it "should find the callback after the fact" do
          @model.should callback(:shake!).after(lifecycle)
        end
        it "should not find a callback around the fact" do
          @model.should_not callback(:giggle!).around(lifecycle)
        end
        it "should not find callbacks that are not there" do
          @model.should_not callback(:scream!).around(lifecycle)
        end
        it "should have a meaningful description" do
          matcher = callback(:dance!).before(lifecycle)
          matcher.description.should == "callback dance! before #{lifecycle}"
        end
      end
      context "with conditions" do
        it "should match the if condition" do
          @model.should callback(:dance!).after(lifecycle).if(:evaluates_to_false!)
        end
        it "should match the unless condition" do
          @model.should callback(:shake!).after(lifecycle).unless(:evaluates_to_true!)
        end
        it "should not find callbacks not matching the conditions" do
          @model.should_not callback(:giggle!).around(lifecycle).unless(:evaluates_to_false!)
        end
        it "should not find callbacks that are not there entirely" do
          @model.should_not callback(:scream!).before(lifecycle).unless(:evaluates_to_false!)
        end
        it "should have a meaningful description" do
          matcher = callback(:dance!).after(lifecycle).unless(:evaluates_to_false!)
          matcher.description.should == "callback dance! after #{lifecycle} unless evaluates_to_false! evaluates to false"
        end
      end
    end
  end
end
