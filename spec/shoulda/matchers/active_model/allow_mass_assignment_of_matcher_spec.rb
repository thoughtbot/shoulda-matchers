require "spec_helper"

describe Shoulda::Matchers::ActiveModel::AllowMassAssignmentOfMatcher do
  context "#description" do
    context "without a role" do
      it "includes the attribute name" do
        matcher = described_class.new(:attr)
        matcher.description.should eq("allow mass assignment of attr")
      end
    end

    if active_model_3_1?
      context "with a role" do
        it "includes the attribute name and the role" do
          matcher = described_class.new(:attr).as(:admin)
          matcher.description.should eq("allow mass assignment of attr as admin")
        end
      end
    end
  end

  context "an attribute that is blacklisted from mass-assignment" do
    let(:model) do
      define_model(:example, :attr => :string) do
        attr_protected :attr
      end.new
    end

    it "rejects being mass-assignable" do
      model.should_not allow_mass_assignment_of(:attr)
    end
  end

  context "an attribute that is not whitelisted for mass-assignment" do
    let(:model) do
      define_model(:example, :attr => :string, :other => :string) do
        attr_accessible :other
      end.new
    end

    it "rejects being mass-assignable" do
      model.should_not allow_mass_assignment_of(:attr)
    end
  end

  context "an attribute that is whitelisted for mass-assignment" do
    let(:model) do
      define_model(:example, :attr => :string) do
        attr_accessible :attr
      end.new
    end

    it "accepts being mass-assignable" do
      model.should allow_mass_assignment_of(:attr)
    end
  end

  context "an attribute not included in the mass-assignment blacklist" do
    let(:model) do
      define_model(:example, :attr => :string, :other => :string) do
        attr_protected :other
      end.new
    end

    it "accepts being mass-assignable" do
      model.should allow_mass_assignment_of(:attr)
    end
  end

  unless active_model_3_2?
    context "an attribute on a class with no protected attributes" do
      let(:model) { define_model(:example, :attr => :string).new }

      it "accepts being mass-assignable" do
        model.should allow_mass_assignment_of(:attr)
      end

      it "assigns a negative failure message" do
        matcher = allow_mass_assignment_of(:attr)

        matcher.matches?(model).should == true

        matcher.negative_failure_message.should_not be_nil
      end
    end
  end

  context "an attribute on a class with all protected attributes" do
    it "rejects being mass-assignable" do
      define_model(:example, :attr => :string) do
        attr_accessible
      end.new.should_not allow_mass_assignment_of(:attr)
    end
  end

  if active_model_3_1?
    context "an attribute included in the mass-assignment whitelist for admin role only" do
      it "rejects being mass-assignable" do
        mass_assignable_as_admin.should_not allow_mass_assignment_of(:attr)
      end

      it "accepts being mass-assignable for admin" do
        mass_assignable_as_admin.should allow_mass_assignment_of(:attr).as(:admin)
      end

      def mass_assignable_as_admin
        define_model(:example, :attr => :string) do
          attr_accessible :attr, :as => :admin
        end.new
      end
    end
  end
end
