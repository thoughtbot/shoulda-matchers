require 'unit_spec_helper'

describe Shoulda::Matchers::ActiveModel::AllowMassAssignmentOfMatcher, type: :model do
  context '#description' do
    context 'without a role' do
      it 'includes the attribute name' do
        expect(described_class.new(:attr).description).
          to eq 'allow mass assignment of attr'
      end
    end

    if active_model_3_1?
      context 'with a role' do
        it 'includes the attribute name and the role' do
          expect(described_class.new(:attr).as(:admin).description).
            to eq 'allow mass assignment of attr as admin'
        end
      end
    end
  end

  context 'an attribute that is blacklisted from mass-assignment' do
    it 'rejects being mass-assignable' do
      model = define_model(:example, blacklisted: :string) do
        attr_protected :blacklisted
      end.new

      expect(model).not_to allow_mass_assignment_of(:blacklisted)
    end
  end

  context 'an attribute that is not whitelisted for mass-assignment' do
    it 'rejects being mass-assignable' do
      model = define_model(:example, not_whitelisted: :string,
        whitelisted: :string) do
        attr_accessible :whitelisted
      end.new

      expect(model).not_to allow_mass_assignment_of(:not_whitelisted)
    end
  end

  context 'an attribute that is whitelisted for mass-assignment' do
    it 'accepts being mass-assignable' do
      expect(define_model(:example, whitelisted: :string) do
        attr_accessible :whitelisted
      end.new).to allow_mass_assignment_of(:whitelisted)
    end
  end

  context 'an attribute not included in the mass-assignment blacklist' do
    it 'accepts being mass-assignable' do
      model = define_model(:example, not_blacklisted: :string,
        blacklisted: :string) do
        attr_protected :blacklisted
      end.new

      expect(model).to allow_mass_assignment_of(:not_blacklisted)
    end
  end

  unless active_model_3_2? || active_model_4_0?
    context 'an attribute on a class with no protected attributes' do
      it 'accepts being mass-assignable' do
        expect(no_protected_attributes).to allow_mass_assignment_of(:attr)
      end

      it 'assigns a negative failure message' do
        matcher = allow_mass_assignment_of(:attr)

        expect(matcher.matches?(no_protected_attributes)).to eq true

        expect(matcher.failure_message_when_negated).not_to be_nil
      end
    end

    def no_protected_attributes
      define_model(:example, attr: :string).new
    end
  end

  context 'an attribute on a class with all protected attributes' do
    it 'rejects being mass-assignable' do
      expect(all_protected_attributes).not_to allow_mass_assignment_of(:attr)
    end

    def all_protected_attributes
      define_model(:example, attr: :string) do
        attr_accessible nil
      end.new
    end
  end

  if active_model_3_1?
    context 'an attribute included in the mass-assignment whitelist for admin role only' do
      it 'rejects being mass-assignable' do
        expect(mass_assignable_as_admin).not_to allow_mass_assignment_of(:attr)
      end

      it 'accepts being mass-assignable for admin' do
        expect(mass_assignable_as_admin).to allow_mass_assignment_of(:attr).as(:admin)
      end

      def mass_assignable_as_admin
        define_model(:example, attr: :string) do
          attr_accessible :attr, as: :admin
        end.new
      end
    end
  end

  def define_model(name, columns, &block)
    super(name, columns, whitelist_attributes: false, &block)
  end
end
