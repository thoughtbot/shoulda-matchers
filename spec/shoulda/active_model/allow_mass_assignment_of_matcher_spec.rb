require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::AllowMassAssignmentOfMatcher do
  context "an attribute that is blacklisted from mass-assignment" do
    let(:model) do
      define_model(:example, :attr => :string) do
        attr_protected :attr
      end.new
    end

    it "should reject being mass-assignable" do
      model.should_not allow_mass_assignment_of(:attr)
    end
  end

  context "an attribute that is not whitelisted for mass-assignment" do
    let(:model) do
      define_model(:example, :attr => :string, :other => :string) do
        attr_accessible :other
      end.new
    end

    it "should reject being mass-assignable" do
      model.should_not allow_mass_assignment_of(:attr)
    end
  end

  context "an attribute that is whitelisted for mass-assignment" do
    let(:model) do
      define_model(:example, :attr => :string) do
        attr_accessible :attr
      end.new
    end

    it "should accept being mass-assignable" do
      model.should allow_mass_assignment_of(:attr)
    end
  end

  context "an attribute not included in the mass-assignment blacklist" do
    let(:model) do
      define_model(:example, :attr => :string, :other => :string) do
        attr_protected :other
      end.new
    end

    it "should accept being mass-assignable" do
      model.should allow_mass_assignment_of(:attr)
    end
  end

  unless active_model_3_2?
    context "an attribute on a class with no protected attributes" do
      let(:model) { define_model(:example, :attr => :string).new }

      it "should accept being mass-assignable" do
        model.should allow_mass_assignment_of(:attr)
      end

      it "should assign a negative failure message" do
        matcher = allow_mass_assignment_of(:attr)
        matcher.matches?(model).should == true
        matcher.negative_failure_message.should_not be_nil
      end
    end
  end

  context "an attribute on a class with all protected attributes" do
    let(:model) do
      define_model(:example, :attr => :string) do
        attr_accessible
      end.new
    end

    it "should reject being mass-assignable" do
      model.should_not allow_mass_assignment_of(:attr)
    end
  end

  if active_model_3_1?
    context "an attribute included in the mass-assignment whitelist for admin role only" do
      let(:model) do
        define_model(:example, :attr => :string) do
          attr_accessible :attr, :as => :admin
        end.new
      end

      it "should reject being mass-assignable" do
        model.should_not allow_mass_assignment_of(:attr)
      end

      it "should accept being mass-assignable for admin" do
        model.should allow_mass_assignment_of(:attr).as(:admin)
      end
    end

    context "messages" do
      it "should include the role in the description when used" do
        matcher = allow_mass_assignment_of(:attr).as(:admin)
        matcher.description.should match(/for :admin role/)
      end

      it "should not include the role in the description when not used" do
        matcher = allow_mass_assignment_of(:attr)
        matcher.description.should_not match(/for :default role/)
      end

      context "with whitelisting" do
        let(:model) do
          define_model(:example, :attr => :string) do
            attr_accessible :attr, :as => [ :default, :admin ]
          end.new
        end

        let(:no_default_model) do
          define_model(:example, :attr => :string) do
            attr_accessible :attr, :as => :admin
          end.new
        end

        it "should include the role in the failure message when used" do
          matcher = allow_mass_assignment_of(:attr).as(:monkey)
          matcher.matches?(model).should == false
          matcher.failure_message.should_not be_nil
          matcher.failure_message.should match(/to :monkey role/)
        end

        it "should not include the role in the failure message when not used" do
          matcher = allow_mass_assignment_of(:attr)
          matcher.matches?(no_default_model).should == false
          matcher.failure_message.should_not be_nil
          matcher.failure_message.should_not match(/from :default role/)
        end

        it "should include the role in the negative failure message when used" do
          matcher = allow_mass_assignment_of(:attr).as(:admin)
          matcher.matches?(model).should == true
          matcher.negative_failure_message.should_not be_nil
          matcher.negative_failure_message.should match(/to :admin role/)
        end

        it "should not include the role in the negative failure message when not used" do
          matcher = allow_mass_assignment_of(:attr)
          matcher.matches?(model).should == true
          matcher.negative_failure_message.should_not be_nil
          matcher.negative_failure_message.should_not match(/to :default role/)
        end
      end

      context "with blacklisting" do
        let(:protected_model) do
          define_model(:example, :attr => :string) do
            attr_protected :attr, :as => [ :default, :admin ]
          end.new
        end

        it "should include the role in the failure message when used" do
          matcher = allow_mass_assignment_of(:attr).as(:admin)
          matcher.matches?(protected_model).should == false
          matcher.failure_message.should_not be_nil
          matcher.failure_message.should match(/from :admin role/)
        end

        it "should not include the role in the failure message when not used" do
          matcher = allow_mass_assignment_of(:attr)
          matcher.matches?(protected_model).should == false
          matcher.failure_message.should_not be_nil
          matcher.failure_message.should_not match(/from :default role/)
        end

        it "should include the role in the negative failure message when used" do
          matcher = allow_mass_assignment_of(:attr2).as(:admin)
          matcher.matches?(protected_model).should == true
          matcher.negative_failure_message.should_not be_nil
          matcher.negative_failure_message.should match(/from :admin role/)
        end

        it "should not include the role in the negative failure message when not used" do
          matcher = allow_mass_assignment_of(:attr2)
          matcher.matches?(protected_model).should == true
          matcher.negative_failure_message.should_not be_nil
          matcher.negative_failure_message.should_not match(/from :default role/)
        end
      end
    end
  end
end
