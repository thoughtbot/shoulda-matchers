require 'spec_helper'

describe Shoulda::Matchers::ActiveRecord::AssociationMatcher do
  context 'belong_to' do
    it 'accepts a good association with the default foreign key' do
      belonging_to_parent.should belong_to(:parent)
    end

    it 'rejects a nonexistent association' do
      define_model(:child).new.should_not belong_to(:parent)
    end

    it 'rejects an association of the wrong type' do
      define_model :parent, :child_id => :integer
      define_model(:child) { has_one :parent }.new.should_not belong_to(:parent)
    end

    it 'rejects an association that has a nonexistent foreign key' do
      define_model :parent
      define_model(:child) { belongs_to :parent }.new.should_not belong_to(:parent)
    end

    it 'accepts an association with an existing custom foreign key' do
      define_model :parent
      define_model :child, :guardian_id => :integer do
        belongs_to :parent, :foreign_key => 'guardian_id'
      end

      Child.new.should belong_to(:parent)
    end

    it 'accepts a polymorphic association' do
      define_model :child, :parent_type => :string, :parent_id => :integer do
        belongs_to :parent, :polymorphic => true
      end

      Child.new.should belong_to(:parent)
    end

    it 'accepts an association with a valid :dependent option' do
      belonging_to_parent(:dependent => :destroy).
        should belong_to(:parent).dependent(:destroy)
    end

    it 'rejects an association with a bad :dependent option' do
      belonging_to_parent.should_not belong_to(:parent).dependent(:destroy)
    end

    it 'accepts an association with a valid :conditions option' do
      define_model :parent, :adopter => :boolean
      define_model :child, :parent_id => :integer do
        belongs_to :parent, :conditions => { :adopter => true }
      end

      Child.new.should belong_to(:parent).conditions(:adopter => true)
    end

    it 'rejects an association with a bad :conditions option' do
      define_model :parent, :adopter => :boolean
      define_model :child, :parent_id => :integer do
        belongs_to :parent
      end

      Child.new.should_not belong_to(:parent).conditions(:adopter => true)
    end

    it 'accepts an association without a :class_name option' do
      belonging_to_parent.should belong_to(:parent).class_name('Parent')
    end

    it 'accepts an association with a valid :class_name option' do
      define_model :tree_parent
      define_model :child, :parent_id => :integer do
        belongs_to :parent, :class_name => 'TreeParent'
      end

      Child.new.should belong_to(:parent).class_name('TreeParent')
    end

    it 'rejects an association with a bad :class_name option' do
      belonging_to_parent.should_not belong_to(:parent).class_name('TreeChild')
    end

    context 'validate' do
      [false, true].each do |validate_value|
        context 'when the model has :validate => #{validate_value}' do
          it 'accepts a matching validate option' do
            belonging_to_parent(:validate => validate_value).
              should belong_to(:parent).validate(validate_value)
          end

          it 'rejects a non-matching validate option' do
            belonging_to_parent(:validate => validate_value).
              should_not belong_to(:parent).validate(!validate_value)
          end

          it 'defaults to validate(true)' do
            if validate_value
              belonging_to_parent(:validate => validate_value).
                should belong_to(:parent).validate
            else
              belonging_to_parent(:validate => validate_value).
                should_not belong_to(:parent).validate
            end
          end
        end
      end
    end

    context 'an association without a :validate option' do
      it 'accepts validate(false)' do
        belonging_to_parent.should belong_to(:parent).validate(false)
      end

      it 'rejects validate(true)' do
        belonging_to_parent.should_not belong_to(:parent).validate(true)
      end

      it 'rejects validate()' do
        belonging_to_parent.should_not belong_to(:parent).validate
      end
    end

    def belonging_to_parent(options = {})
      define_model :parent
      define_model :child, :parent_id => :integer do
        belongs_to :parent, options
      end.new
    end
  end

  context 'have_many' do
    it 'accepts a valid association without any options' do
      having_many_children.should have_many(:children)
    end

    it 'accepts a valid association with a :through option' do
      define_model :child
      define_model :conception, :child_id => :integer,
        :parent_id => :integer do
        belongs_to :child
        end
      define_model :parent do
        has_many :conceptions
        has_many :children, :through => :conceptions
      end
      Parent.new.should have_many(:children)
    end

    it 'accepts a valid association with an :as option' do
      define_model :child, :guardian_type => :string, :guardian_id => :integer
      define_model :parent do
        has_many :children, :as => :guardian
      end

      Parent.new.should have_many(:children)
    end

    it 'rejects an association that has a nonexistent foreign key' do
      define_model :child
      define_model :parent do
        has_many :children
      end

      Parent.new.should_not have_many(:children)
    end

    it 'rejects an association with a bad :as option' do
      define_model :child, :caretaker_type => :string,
        :caretaker_id => :integer
      define_model :parent do
        has_many :children, :as => :guardian
      end

      Parent.new.should_not have_many(:children)
    end

    it 'rejects an association that has a bad :through option' do
      matcher = have_many(:children).through(:conceptions)

      matcher.matches?(having_many_children).should be_false

      matcher.failure_message_for_should.should =~ /does not have any relationship to conceptions/
    end

    it 'rejects an association that has the wrong :through option' do
      define_model :child

      define_model :conception, :child_id => :integer,
        :parent_id => :integer do
        belongs_to :child
      end

      define_model :parent do
        has_many :conceptions
        has_many :relationships
        has_many :children, :through => :conceptions
      end

      matcher = have_many(:children).through(:relationships)
      matcher.matches?(Parent.new).should be_false
      matcher.failure_message_for_should.should =~ /through relationships, but got it through conceptions/
    end

    it 'accepts an association with a valid :dependent option' do
      having_many_children(:dependent => :destroy).
        should have_many(:children).dependent(:destroy)
    end

    it 'rejects an association with a bad :dependent option' do
      having_many_children.should_not have_many(:children).dependent(:destroy)
    end

    it 'accepts an association with a valid :order option' do
      having_many_children(:order => :id).
        should have_many(:children).order(:id)
    end

    it 'rejects an association with a bad :order option' do
      having_many_children.should_not have_many(:children).order(:id)
    end

    it 'accepts an association with a valid :conditions option' do
      define_model :child, :parent_id => :integer, :adopted => :boolean
      define_model :parent do
        has_many :children, :conditions => { :adopted => true }
      end

      Parent.new.should have_many(:children).conditions(:adopted => true)
    end

    it 'rejects an association with a bad :conditions option' do
      define_model :child, :parent_id => :integer, :adopted => :boolean
      define_model :parent do
        has_many :children
      end

      Parent.new.should_not have_many(:children).conditions(:adopted => true)
    end

    it 'accepts an association without a :class_name option' do
      having_many_children.should have_many(:children).class_name('Child')
    end

    it 'accepts an association with a valid :class_name option' do
      define_model :node, :parent_id => :integer
      define_model :parent do
        has_many :children, :class_name => 'Node'
      end

      Parent.new.should have_many(:children).class_name('Node')
    end

    it 'rejects an association with a bad :class_name option' do
      having_many_children.should_not have_many(:children).class_name('Node')
    end

    context 'validate' do
      it 'accepts when the :validate option matches' do
        having_many_children(:validate => false).should have_many(:children).validate(false)
      end

      it 'rejects when the :validate option does not match' do
        having_many_children(:validate => true).should_not have_many(:children).validate(false)
      end

      it 'assumes validate() means validate(true)' do
        having_many_children(:validate => false).should_not have_many(:children).validate
      end

      it 'matches validate(false) to having no validate option specified' do
        having_many_children.should have_many(:children).validate(false)
      end
    end

    it 'accepts an association with a nonstandard reverse foreign key, using :inverse_of' do
      define_model :child, :ancestor_id => :integer do
        belongs_to :ancestor, :inverse_of => :children, :class_name => :Parent
      end

      define_model :parent do
        has_many :children, :inverse_of => :ancestor
      end

      Parent.new.should have_many(:children)
    end

    it 'rejects an association with a nonstandard reverse foreign key, if :inverse_of is not correct' do
      define_model :child, :mother_id => :integer do
        belongs_to :mother, :inverse_of => :children, :class_name => :Parent
      end

      define_model :parent do
        has_many :children, :inverse_of => :ancestor
      end

      Parent.new.should_not have_many(:children)
    end

    def having_many_children(options = {})
      define_model :child, :parent_id => :integer
      define_model :parent do
        has_many :children, options
      end.new
    end
  end

  context 'have_one' do
    it 'accepts a valid association without any options' do
      having_one_detail.should have_one(:detail)
    end

    it 'accepts a valid association with an :as option' do
      define_model :detail, :detailable_id => :integer,
        :detailable_type => :string
      define_model :person do
        has_one :detail, :as => :detailable
      end

      Person.new.should have_one(:detail)
    end

    it 'rejects an association that has a nonexistent foreign key' do
      define_model :detail
      define_model :person do
        has_one :detail
      end

      Person.new.should_not have_one(:detail)
    end

    it 'accepts an association with an existing custom foreign key' do
      define_model :detail, :detailed_person_id => :integer
      define_model :person do
        has_one :detail, :foreign_key => :detailed_person_id
      end
      Person.new.should have_one(:detail).with_foreign_key(:detailed_person_id)
    end

    it 'rejects an association with a bad :as option' do
      define_model :detail, :detailable_id => :integer,
        :detailable_type => :string
      define_model :person do
        has_one :detail, :as => :describable
      end

      Person.new.should_not have_one(:detail)
    end

    it 'accepts an association with a valid :dependent option' do
      having_one_detail(:dependent => :destroy).
        should have_one(:detail).dependent(:destroy)
    end

    it 'rejects an association with a bad :dependent option' do
      having_one_detail.should_not have_one(:detail).dependent(:destroy)
    end

    it 'accepts an association with a valid :order option' do
      having_one_detail(:order => :id).should have_one(:detail).order(:id)
    end

    it 'rejects an association with a bad :order option' do
      having_one_detail.should_not have_one(:detail).order(:id)
    end

    it 'accepts an association with a valid :conditions option' do
      define_model :detail, :person_id => :integer, :disabled => :boolean
      define_model :person do
        has_one :detail, :conditions => { :disabled => true}
      end

      Person.new.should have_one(:detail).conditions(:disabled => true)
    end

    it 'rejects an association with a bad :conditions option' do
      define_model :detail, :person_id => :integer, :disabled => :boolean
      define_model :person do
        has_one :detail
      end

      Person.new.should_not have_one(:detail).conditions(:disabled => true)
    end

    it 'accepts an association without a :class_name option' do
      having_one_detail.should have_one(:detail).class_name('Detail')
    end

    it 'accepts an association with a valid :class_name option' do
      define_model :person_detail, :person_id => :integer
      define_model :person do
        has_one :detail, :class_name => 'PersonDetail'
      end

      Person.new.should have_one(:detail).class_name('PersonDetail')
    end

    it 'rejects an association with a bad :class_name option' do
      having_one_detail.should_not have_one(:detail).class_name('NotSet')
    end

    it 'accepts an association with a through' do
      define_model :detail

      define_model :account do
        has_one :detail
      end

      define_model :person do
        has_one :account
        has_one :detail, :through => :account
      end

      Person.new.should have_one(:detail).through(:account)
    end

    it 'rejects an association with a bad through' do
      having_one_detail.should_not have_one(:detail).through(:account)
    end

    context 'validate' do
      it 'accepts when the :validate option matches' do
        having_one_detail(:validate => false).
          should have_one(:detail).validate(false)
      end

      it 'rejects when the :validate option does not match' do
        having_one_detail(:validate => true).
          should_not have_one(:detail).validate(false)
      end

      it 'assumes validate() means validate(true)' do
        having_one_detail(:validate => false).
          should_not have_one(:detail).validate
      end

      it 'matches validate(false) to having no validate option specified' do
        having_one_detail.should have_one(:detail).validate(false)
      end
    end

    def having_one_detail(options = {})
      define_model :detail, :person_id => :integer
      define_model :person do
        has_one :detail, options
      end.new
    end
  end

  context 'have_and_belong_to_many' do
    it 'accepts a valid association' do
      having_and_belonging_to_many_relatives.
        should have_and_belong_to_many(:relatives)
    end

    it 'rejects a nonexistent association' do
      define_model :relative
      define_model :person
      define_model :people_relative, :id => false, :person_id => :integer,
        :relative_id => :integer

      Person.new.should_not have_and_belong_to_many(:relatives)
    end

    it 'rejects an association with a nonexistent join table' do
      define_model :relative
      define_model :person do
        has_and_belongs_to_many :relatives
      end

      Person.new.should_not have_and_belong_to_many(:relatives)
    end

    it 'rejects an association of the wrong type' do
      define_model :relative, :person_id => :integer
      define_model :person do
        has_many :relatives
      end

      Person.new.should_not have_and_belong_to_many(:relatives)
    end

    it 'accepts an association with a valid :conditions option' do
      define_model :relative, :adopted => :boolean
      define_model :person do
        has_and_belongs_to_many :relatives, :conditions => { :adopted => true }
      end
      define_model :people_relative, :id => false, :person_id => :integer,
        :relative_id => :integer

      Person.new.should have_and_belong_to_many(:relatives).conditions(:adopted => true)
    end

    it 'rejects an association with a bad :conditions option' do
      define_model :relative, :adopted => :boolean
      define_model :person do
        has_and_belongs_to_many :relatives
      end
      define_model :people_relative, :id => false, :person_id => :integer,
        :relative_id => :integer

      Person.new.should_not have_and_belong_to_many(:relatives).conditions(:adopted => true)
    end

    it 'accepts an association without a :class_name option' do
      having_and_belonging_to_many_relatives.
        should have_and_belong_to_many(:relatives).class_name('Relative')
    end

    it 'accepts an association with a valid :class_name option' do
      define_model :person_relative, :adopted => :boolean
      define_model :person do
        has_and_belongs_to_many :relatives, :class_name => 'PersonRelative'
      end

      define_model :people_person_relative, :person_id => :integer,
        :person_relative_id => :integer

      Person.new.should have_and_belong_to_many(:relatives).class_name('PersonRelative')
    end

    it 'rejects an association with a bad :class_name option' do
      having_and_belonging_to_many_relatives.
        should_not have_and_belong_to_many(:relatives).class_name('PersonRelatives')
    end

    context 'validate' do
      it 'accepts when the :validate option matches' do
        having_and_belonging_to_many_relatives(:validate => false).
          should have_and_belong_to_many(:relatives).validate(false)
      end

      it 'rejects when the :validate option does not match' do
        having_and_belonging_to_many_relatives(:validate => true).
          should have_and_belong_to_many(:relatives).validate(false)
      end

      it 'assumes validate() means validate(true)' do
        having_and_belonging_to_many_relatives(:validate => false).
          should_not have_and_belong_to_many(:relatives).validate
      end

      it 'matches validate(false) to having no validate option specified' do
        having_and_belonging_to_many_relatives.
          should have_and_belong_to_many(:relatives).validate(false)
      end
    end

    def having_and_belonging_to_many_relatives(options = {})
      define_model :relative
      define_model :people_relative, :id => false, :person_id => :integer,
        :relative_id => :integer
      define_model :person do
        has_and_belongs_to_many :relatives
      end.new
    end
  end
end
