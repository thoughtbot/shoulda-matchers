require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::AllowMassAssignmentOfMatcher do
  context '#description' do
    context 'without a role' do
      it 'includes the attribute name' do
        described_class.new(:attr).description.should ==
          'allow mass assignment of attr'
      end
    end

    if active_model_3_1?
      context 'with a role' do
        it 'includes the attribute name and the role' do
          described_class.new(:attr).as(:admin).description.should ==
            'allow mass assignment of attr as admin'
        end
      end
    end
  end

  context 'an attribute that is blacklisted from mass-assignment' do
    it 'rejects being mass-assignable' do
      model = define_model(:example, :blacklisted => :string) do
        attr_protected :blacklisted
      end.new

      model.should_not allow_mass_assignment_of(:blacklisted)
    end
  end

  context 'an attribute that is not whitelisted for mass-assignment' do
    it 'rejects being mass-assignable' do
      model = define_model(:example, :not_whitelisted => :string,
        :whitelisted => :string) do
        attr_accessible :whitelisted
      end.new

      model.should_not allow_mass_assignment_of(:not_whitelisted)
    end
  end

  context 'an attribute that is whitelisted for mass-assignment' do
    it 'accepts being mass-assignable' do
      define_model(:example, :whitelisted => :string) do
        attr_accessible :whitelisted
      end.new.should allow_mass_assignment_of(:whitelisted)
    end
  end

  context 'an attribute not included in the mass-assignment blacklist' do
    it 'accepts being mass-assignable' do
      model = define_model(:example, :not_blacklisted => :string,
        :blacklisted => :string) do
        attr_protected :blacklisted
      end.new

      model.should allow_mass_assignment_of(:not_blacklisted)
    end
  end

  unless active_model_3_2? || active_model_4_0?
    context 'an attribute on a class with no protected attributes' do
      it 'accepts being mass-assignable' do
        no_protected_attributes.should allow_mass_assignment_of(:attr)
      end

      it 'assigns a negative failure message' do
        matcher = allow_mass_assignment_of(:attr)

        matcher.matches?(no_protected_attributes).should be_true

        matcher.failure_message_for_should_not.should_not be_nil
      end
    end

    def no_protected_attributes
      define_model(:example, :attr => :string).new
    end
  end

  context 'an attribute on a class with all protected attributes' do
    it 'rejects being mass-assignable' do
      all_protected_attributes.should_not allow_mass_assignment_of(:attr)
    end

    def all_protected_attributes
      define_model(:example, :attr => :string) do
        attr_accessible nil
      end.new
    end
  end

  if active_model_3_1?
    context 'an attribute included in the mass-assignment whitelist for admin role only' do
      it 'rejects being mass-assignable' do
        mass_assignable_as_admin.should_not allow_mass_assignment_of(:attr)
      end

      it 'accepts being mass-assignable for admin' do
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
