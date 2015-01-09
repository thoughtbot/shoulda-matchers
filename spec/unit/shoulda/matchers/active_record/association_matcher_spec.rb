require 'unit_spec_helper'

describe Shoulda::Matchers::ActiveRecord::AssociationMatcher, type: :model do
  context 'belong_to' do
    it 'accepts a good association with the default foreign key' do
      expect(belonging_to_parent).to belong_to(:parent)
    end

    it 'rejects a nonexistent association' do
      expect(define_model(:child).new).not_to belong_to(:parent)
    end

    it 'rejects an association of the wrong type' do
      define_model :parent, child_id: :integer
      expect(define_model(:child) { has_one :parent }.new).not_to belong_to(:parent)
    end

    it 'rejects an association that has a nonexistent foreign key' do
      define_model :parent
      expect(define_model(:child) { belongs_to :parent }.new).not_to belong_to(:parent)
    end

    it 'accepts an association with an existing custom foreign key' do
      define_model :parent
      define_model :child, guardian_id: :integer do
        belongs_to :parent, foreign_key: 'guardian_id'
      end

      expect(Child.new).to belong_to(:parent)
    end

    it 'accepts an association using an existing custom primary key' do
      define_model :parent
      define_model :child, parent_id: :integer, custom_primary_key: :integer do
        belongs_to :parent, primary_key: :custom_primary_key
      end
      expect(Child.new).to belong_to(:parent).with_primary_key(:custom_primary_key)
    end

    it 'rejects an association with a bad :primary_key option' do
      matcher = belong_to(:parent).with_primary_key(:custom_primary_key)

      expect(belonging_to_parent).not_to matcher

      expect(matcher.failure_message).to match(/Child does not have a custom_primary_key primary key/)
    end

    it 'accepts a polymorphic association' do
      define_model :child, parent_type: :string, parent_id: :integer do
        belongs_to :parent, polymorphic: true
      end

      expect(Child.new).to belong_to(:parent)
    end

    it 'accepts an association with a valid :dependent option' do
      expect(belonging_to_parent(dependent: :destroy)).
        to belong_to(:parent).dependent(:destroy)
    end

    it 'rejects an association with a bad :dependent option' do
      expect(belonging_to_parent).not_to belong_to(:parent).dependent(:destroy)
    end

    it 'accepts an association with a valid :counter_cache option' do
      expect(belonging_to_parent(counter_cache: :attribute_count)).
        to belong_to(:parent).counter_cache(:attribute_count)
    end

    it 'defaults :counter_cache to true' do
      expect(belonging_to_parent(counter_cache: true)).
        to belong_to(:parent).counter_cache
    end

    it 'rejects an association with a bad :counter_cache option' do
      expect(belonging_to_parent(counter_cache: :attribute_count)).
        not_to belong_to(:parent).counter_cache(true)
    end

    it 'rejects an association that has no :counter_cache option' do
      expect(belonging_to_parent).not_to belong_to(:parent).counter_cache
    end

    it 'accepts an association with a valid :inverse_of option' do
      expect(belonging_to_parent(inverse_of: :children))
        .to belong_to(:parent).inverse_of(:children)
    end

    it 'rejects an association with a bad :inverse_of option' do
      expect(belonging_to_parent(inverse_of: :other_children))
        .not_to belong_to(:parent).inverse_of(:children)
    end

    it 'rejects an association that has no :inverse_of option' do
      expect(belonging_to_parent)
        .not_to belong_to(:parent).inverse_of(:children)
    end

    it 'accepts an association with a valid :conditions option' do
      define_model :parent, adopter: :boolean
      define_model(:child, parent_id: :integer).tap do |model|
        define_association_with_conditions(model, :belongs_to, :parent, adopter: true)
      end

      expect(Child.new).to belong_to(:parent).conditions(adopter: true)
    end

    it 'rejects an association with a bad :conditions option' do
      define_model :parent, adopter: :boolean
      define_model :child, parent_id: :integer do
        belongs_to :parent
      end

      expect(Child.new).not_to belong_to(:parent).conditions(adopter: true)
    end

    it 'accepts an association without a :class_name option' do
      expect(belonging_to_parent).to belong_to(:parent).class_name('Parent')
    end

    it 'accepts an association with a valid :class_name option' do
      define_model :tree_parent
      define_model :child, parent_id: :integer do
        belongs_to :parent, class_name: 'TreeParent'
      end

      expect(Child.new).to belong_to(:parent).class_name('TreeParent')
    end

    it 'rejects an association with a bad :class_name option' do
      expect(belonging_to_parent).not_to belong_to(:parent).class_name('TreeChild')
    end

    it 'rejects an association with non-existent implicit class name' do
      expect(belonging_to_non_existent_class(:child, :parent)).not_to belong_to(:parent)
    end

    it 'rejects an association with non-existent explicit class name' do
      expect(belonging_to_non_existent_class(:child, :parent, class_name: 'Parent')).not_to belong_to(:parent)
    end

    it 'adds error message when rejecting an association with non-existent class' do
      message = 'Expected Child to have a belongs_to association called parent (Parent2 does not exist)'
      expect {
        expect(belonging_to_non_existent_class(:child, :parent, class_name: 'Parent2')).to belong_to(:parent)
      }.to fail_with_message(message)
    end

    it 'accepts an association with a namespaced class name' do
      define_module 'Models'
      define_model 'Models::Organization'
      user_model = define_model 'Models::User', organization_id: :integer do
        belongs_to :organization, class_name: 'Organization'
      end

      expect(user_model.new).
        to belong_to(:organization).
        class_name('Organization')
    end

    it 'resolves class_name within the context of the namespace before the global namespace' do
      define_module 'Models'
      define_model 'Organization'
      define_model 'Models::Organization'
      user_model = define_model 'Models::User', organization_id: :integer do
        belongs_to :organization, class_name: 'Organization'
      end

      expect(user_model.new).
        to belong_to(:organization).
        class_name('Organization')
    end

    it 'accepts an association with a matching :autosave option' do
      define_model :parent, adopter: :boolean
      define_model :child, parent_id: :integer do
        belongs_to :parent, autosave: true
      end
      expect(Child.new).to belong_to(:parent).autosave(true)
    end

    it 'rejects an association with a non-matching :autosave option with the correct message' do
      define_model :parent, adopter: :boolean
      define_model :child, parent_id: :integer do
        belongs_to :parent, autosave: false
      end

      message = 'Expected Child to have a belongs_to association called parent (parent should have autosave set to true)'
      expect {
        expect(Child.new).to belong_to(:parent).autosave(true)
      }.to fail_with_message(message)
    end

    context 'an association with a :validate option' do
      [false, true].each do |validate_value|
        context "when the model has validate: #{validate_value}" do
          it 'accepts a matching validate option' do
            expect(belonging_to_parent(validate: validate_value)).
              to belong_to(:parent).validate(validate_value)
          end

          it 'rejects a non-matching validate option' do
            expect(belonging_to_parent(validate: validate_value)).
              not_to belong_to(:parent).validate(!validate_value)
          end

          it 'defaults to validate(true)' do
            if validate_value
              expect(belonging_to_parent(validate: validate_value)).
                to belong_to(:parent).validate
            else
              expect(belonging_to_parent(validate: validate_value)).
                not_to belong_to(:parent).validate
            end
          end

          it 'will not break matcher when validate option is unspecified' do
            expect(belonging_to_parent(validate: validate_value)).to belong_to(:parent)
          end
        end
      end
    end

    context 'an association without a :validate option' do
      it 'accepts validate(false)' do
        expect(belonging_to_parent).to belong_to(:parent).validate(false)
      end

      it 'rejects validate(true)' do
        expect(belonging_to_parent).not_to belong_to(:parent).validate(true)
      end

      it 'rejects validate()' do
        expect(belonging_to_parent).not_to belong_to(:parent).validate
      end
    end

    context 'an association with a :touch option' do
      [false, true].each do |touch_value|
        context "when the model has touch: #{touch_value}" do
          it 'accepts a matching touch option' do
            expect(belonging_to_parent(touch: touch_value)).
              to belong_to(:parent).touch(touch_value)
          end

          it 'rejects a non-matching touch option' do
            expect(belonging_to_parent(touch: touch_value)).
              not_to belong_to(:parent).touch(!touch_value)
          end

          it 'defaults to touch(true)' do
            if touch_value
              expect(belonging_to_parent(touch: touch_value)).
                to belong_to(:parent).touch
            else
              expect(belonging_to_parent(touch: touch_value)).
                not_to belong_to(:parent).touch
            end
          end

          it 'will not break matcher when touch option is unspecified' do
            expect(belonging_to_parent(touch: touch_value)).to belong_to(:parent)
          end
        end
      end
    end

    context 'an association without a :touch option' do
      it 'accepts touch(false)' do
        expect(belonging_to_parent).to belong_to(:parent).touch(false)
      end

      it 'rejects touch(true)' do
        expect(belonging_to_parent).not_to belong_to(:parent).touch(true)
      end

      it 'rejects touch()' do
        expect(belonging_to_parent).not_to belong_to(:parent).touch
      end
    end

    def belonging_to_parent(options = {})
      define_model :parent
      define_model :child, parent_id: :integer do
        belongs_to :parent, options
      end.new
    end

    def belonging_to_non_existent_class(model_name, assoc_name, options = {})
      define_model model_name, "#{assoc_name}_id" => :integer do
        belongs_to assoc_name, options
      end.new
    end
  end

  context 'have_many' do
    it 'accepts a valid association without any options' do
      expect(having_many_children).to have_many(:children)
    end

    it 'accepts a valid association with a :through option' do
      define_model :child
      define_model :conception, child_id: :integer,
        parent_id: :integer do
        belongs_to :child
        end
      define_model :parent do
        has_many :conceptions
        has_many :children, through: :conceptions
      end
      expect(Parent.new).to have_many(:children)
    end

    it 'accepts a valid association with an :as option' do
      define_model :child, guardian_type: :string, guardian_id: :integer
      define_model :parent do
        has_many :children, as: :guardian
      end

      expect(Parent.new).to have_many(:children)
    end

    it 'rejects an association that has a nonexistent foreign key' do
      define_model :child
      define_model :parent do
        has_many :children
      end

      expect(Parent.new).not_to have_many(:children)
    end

    it 'accepts an association using an existing custom primary key' do
      define_model :child, parent_id: :integer
      define_model :parent, custom_primary_key: :integer do
        has_many :children, primary_key: :custom_primary_key
      end
      expect(Parent.new).to have_many(:children).with_primary_key(:custom_primary_key)
    end

    it 'rejects an association with a bad :primary_key option' do
      matcher = have_many(:children).with_primary_key(:custom_primary_key)

      expect(having_many_children).not_to matcher

      expect(matcher.failure_message).to match(/Parent does not have a custom_primary_key primary key/)
    end

    it 'rejects an association with a bad :as option' do
      define_model :child, caretaker_type: :string,
        caretaker_id: :integer
      define_model :parent do
        has_many :children, as: :guardian
      end

      expect(Parent.new).not_to have_many(:children)
    end

    it 'rejects an association that has a bad :through option' do
      matcher = have_many(:children).through(:conceptions)

      expect(matcher.matches?(having_many_children)).to eq false

      expect(matcher.failure_message).to match(/does not have any relationship to conceptions/)
    end

    it 'rejects an association that has the wrong :through option' do
      define_model :child

      define_model :conception, child_id: :integer,
        parent_id: :integer do
        belongs_to :child
      end

      define_model :parent do
        has_many :conceptions
        has_many :relationships
        has_many :children, through: :conceptions
      end

      matcher = have_many(:children).through(:relationships)
      expect(matcher.matches?(Parent.new)).to eq false
      expect(matcher.failure_message).to match(/through relationships, but got it through conceptions/)
    end

    it 'produces a failure message without exception when association is missing :through option' do
      define_model :child
      define_model :parent
      matcher = have_many(:children).through(:relationships).source(:child)
      failure_message = 'Expected Parent to have a has_many association called children (no association called children)'

      matcher.matches?(Parent.new)
      expect(matcher.failure_message).to eq failure_message
    end

    it 'accepts an association with a valid :dependent option' do
      expect(having_many_children(dependent: :destroy)).
        to have_many(:children).dependent(:destroy)
    end

    it 'rejects an association with a bad :dependent option' do
      matcher = have_many(:children).dependent(:destroy)

      expect(having_many_children).not_to matcher

      expect(matcher.failure_message).to match(/children should have destroy dependency/)
    end

    it 'accepts an association with a valid :source option' do
      expect(having_many_children(source: :user)).
        to have_many(:children).source(:user)
    end

    it 'rejects an association with a bad :source option' do
      matcher = have_many(:children).source(:user)

      expect(having_many_children).not_to matcher

      expect(matcher.failure_message).to match(/children should have user as source option/)
    end

    it 'accepts an association with a valid :order option' do
      expect(having_many_children(order: :id)).
        to have_many(:children).order(:id)
    end

    it 'rejects an association with a bad :order option' do
      matcher = have_many(:children).order(:id)

      expect(having_many_children).not_to matcher

      expect(matcher.failure_message).to match(/children should be ordered by id/)
    end

    it 'accepts an association with a valid :conditions option' do
      define_model :child, parent_id: :integer, adopted: :boolean
      define_model(:parent).tap do |model|
        define_association_with_conditions(model, :has_many, :children, adopted: true)
      end

      expect(Parent.new).to have_many(:children).conditions(adopted: true)
    end

    it 'rejects an association with a bad :conditions option' do
      define_model :child, parent_id: :integer, adopted: :boolean
      define_model :parent do
        has_many :children
      end

      expect(Parent.new).not_to have_many(:children).conditions(adopted: true)
    end

    it 'accepts an association without a :class_name option' do
      expect(having_many_children).to have_many(:children).class_name('Child')
    end

    it 'accepts an association with a valid :class_name option' do
      define_model :node, parent_id: :integer
      define_model :parent do
        has_many :children, class_name: 'Node'
      end

      expect(Parent.new).to have_many(:children).class_name('Node')
    end

    it 'rejects an association with a bad :class_name option' do
      expect(having_many_children).not_to have_many(:children).class_name('Node')
    end

    it 'rejects an association with non-existent implicit class name' do
      expect(having_many_non_existent_class(:parent, :children)).not_to have_many(:children)
    end

    it 'rejects an association with non-existent explicit class name' do
      expect(having_many_non_existent_class(:parent, :children, class_name: 'Child')).not_to have_many(:children)
    end

    it 'adds error message when rejecting an association with non-existent class' do
      message = 'Expected Parent to have a has_many association called children (Child2 does not exist)'
      expect {
        expect(having_many_non_existent_class(:parent, :children, class_name: 'Child2')).to have_many(:children)
      }.to fail_with_message(message)
    end

    it 'accepts an association with a namespaced class name' do
      define_module 'Models'
      define_model 'Models::Friend', user_id: :integer
      friend_model = define_model 'Models::User' do
        has_many :friends, class_name: 'Friend'
      end

      expect(friend_model.new).
        to have_many(:friends).
        class_name('Friend')
    end

    it 'resolves class_name within the context of the namespace before the global namespace' do
      define_module 'Models'
      define_model 'Friend'
      define_model 'Models::Friend', user_id: :integer
      friend_model = define_model 'Models::User' do
        has_many :friends, class_name: 'Friend'
      end

      expect(friend_model.new).
        to have_many(:friends).
        class_name('Friend')
    end

    it 'accepts an association with a matching :autosave option' do
      define_model :child, parent_id: :integer
      define_model :parent do
        has_many :children, autosave: true
      end
      expect(Parent.new).to have_many(:children).autosave(true)
    end

    it 'rejects an association with a non-matching :autosave option with the correct message' do
      define_model :child, parent_id: :integer
      define_model :parent do
        has_many :children, autosave: false
      end

      message = 'Expected Parent to have a has_many association called children (children should have autosave set to true)'
      expect {
        expect(Parent.new).to have_many(:children).autosave(true)
      }.to fail_with_message(message)
    end

    context 'validate' do
      it 'accepts when the :validate option matches' do
        expect(having_many_children(validate: false)).to have_many(:children).validate(false)
      end

      it 'rejects when the :validate option does not match' do
        expect(having_many_children(validate: true)).not_to have_many(:children).validate(false)
      end

      it 'assumes validate() means validate(true)' do
        expect(having_many_children(validate: false)).not_to have_many(:children).validate
      end

      it 'matches validate(false) to having no validate option specified' do
        expect(having_many_children).to have_many(:children).validate(false)
      end
    end

    it 'accepts an association with a nonstandard reverse foreign key, using :inverse_of' do
      define_model :child, ancestor_id: :integer do
        belongs_to :ancestor, inverse_of: :children, class_name: :Parent
      end

      define_model :parent do
        has_many :children, inverse_of: :ancestor
      end

      expect(Parent.new).to have_many(:children)
    end

    it 'rejects an association with a nonstandard reverse foreign key, if :inverse_of is not correct' do
      define_model :child, mother_id: :integer do
        belongs_to :mother, inverse_of: :children, class_name: :Parent
      end

      define_model :parent do
        has_many :children, inverse_of: :ancestor
      end

      expect(Parent.new).not_to have_many(:children)
    end

    def having_many_children(options = {})
      define_model :child, parent_id: :integer
      define_model(:parent).tap do |model|
        if options.key?(:order)
          order = options.delete(:order)
          define_association_with_order(model, :has_many, :children, order, options)
        else
          model.has_many :children, options
        end
      end.new
    end

    def having_many_non_existent_class(model_name, assoc_name, options = {})
      define_model model_name do
        has_many assoc_name, options
      end.new
    end
  end

  context 'have_one' do
    it 'accepts a valid association without any options' do
      expect(having_one_detail).to have_one(:detail)
    end

    it 'accepts a valid association with an :as option' do
      define_model :detail, detailable_id: :integer,
        detailable_type: :string
      define_model :person do
        has_one :detail, as: :detailable
      end

      expect(Person.new).to have_one(:detail)
    end

    it 'rejects an association that has a nonexistent foreign key' do
      define_model :detail
      define_model :person do
        has_one :detail
      end

      expect(Person.new).not_to have_one(:detail)
    end

    it 'accepts an association with an existing custom foreign key' do
      define_model :detail, detailed_person_id: :integer
      define_model :person do
        has_one :detail, foreign_key: :detailed_person_id
      end
      expect(Person.new).to have_one(:detail).with_foreign_key(:detailed_person_id)
    end

    it 'accepts an association using an existing custom primary key' do
      define_model :detail, person_id: :integer
      define_model :person, custom_primary_key: :integer do
        has_one :detail, primary_key: :custom_primary_key
      end
      expect(Person.new).to have_one(:detail).with_primary_key(:custom_primary_key)
    end

    it 'rejects an association with a bad :primary_key option' do
      matcher = have_one(:detail).with_primary_key(:custom_primary_key)

      expect(having_one_detail).not_to matcher

      expect(matcher.failure_message).to match(/Person does not have a custom_primary_key primary key/)
    end

    it 'rejects an association with a bad :as option' do
      define_model :detail, detailable_id: :integer,
        detailable_type: :string
      define_model :person do
        has_one :detail, as: :describable
      end

      expect(Person.new).not_to have_one(:detail)
    end

    it 'accepts an association with a valid :dependent option' do
      dependent_options.each do |option|
        expect(having_one_detail(dependent: option)).
          to have_one(:detail).dependent(option)
      end
    end

    it 'accepts any dependent option if true' do
      dependent_options.each do |option|
        expect(having_one_detail(dependent: option)).
          to have_one(:detail).dependent(true)
      end
    end

    it 'rejects any dependent options if false' do
      dependent_options.each do |option|
        expect(having_one_detail(dependent: option)).
          to_not have_one(:detail).dependent(false)
      end
    end

    it 'accepts a nil dependent option if false' do
      expect(having_one_detail).to have_one(:detail).dependent(false)
    end

    it 'rejects an association with a bad :dependent option' do
      matcher = have_one(:detail).dependent(:destroy)

      expect(having_one_detail).not_to matcher

      expect(matcher.failure_message).to match(/detail should have destroy dependency/)
    end

    it 'accepts an association with a valid :order option' do
      expect(having_one_detail(order: :id)).to have_one(:detail).order(:id)
    end

    it 'rejects an association with a bad :order option' do
      matcher = have_one(:detail).order(:id)

      expect(having_one_detail).not_to matcher

      expect(matcher.failure_message).to match(/detail should be ordered by id/)
    end

    it 'accepts an association with a valid :conditions option' do
      define_model :detail, person_id: :integer, disabled: :boolean
      define_model(:person).tap do |model|
        define_association_with_conditions(model, :has_one, :detail, disabled: true)
      end

      expect(Person.new).to have_one(:detail).conditions(disabled: true)
    end

    it 'rejects an association with a bad :conditions option' do
      define_model :detail, person_id: :integer, disabled: :boolean
      define_model :person do
        has_one :detail
      end

      expect(Person.new).not_to have_one(:detail).conditions(disabled: true)
    end

    it 'accepts an association without a :class_name option' do
      expect(having_one_detail).to have_one(:detail).class_name('Detail')
    end

    it 'accepts an association with a valid :class_name option' do
      define_model :person_detail, person_id: :integer
      define_model :person do
        has_one :detail, class_name: 'PersonDetail'
      end

      expect(Person.new).to have_one(:detail).class_name('PersonDetail')
    end

    it 'rejects an association with a bad :class_name option' do
      expect(having_one_detail).not_to have_one(:detail).class_name('NotSet')
    end

    it 'rejects an association with non-existent implicit class name' do
      expect(having_one_non_existent(:pserson, :detail)).not_to have_one(:detail)
    end

    it 'rejects an association with non-existent explicit class name' do
      expect(having_one_non_existent(:person, :detail, class_name: 'Detail')).not_to have_one(:detail)
    end

    it 'adds error message when rejecting an association with non-existent class' do
      message = 'Expected Person to have a has_one association called detail (Detail2 does not exist)'
      expect {
        expect(having_one_non_existent(:person, :detail, class_name: 'Detail2')).to have_one(:detail)
      }.to fail_with_message(message)
    end

    it 'accepts an association with a namespaced class name' do
      define_module 'Models'
      define_model 'Models::Account', user_id: :integer
      user_model = define_model 'Models::User' do
        has_one :account, class_name: 'Account'
      end

      expect(user_model.new).
        to have_one(:account).
        class_name('Account')
    end

    it 'resolves class_name within the context of the namespace before the global namespace' do
      define_module 'Models'
      define_model 'Account'
      define_model 'Models::Account', user_id: :integer
      user_model = define_model 'Models::User' do
        has_one :account, class_name: 'Account'
      end

      expect(user_model.new).
        to have_one(:account).
        class_name('Account')
    end

    it 'accepts an association with a matching :autosave option' do
      define_model :detail, person_id: :integer, disabled: :boolean
      define_model :person do
        has_one :detail, autosave: true
      end
      expect(Person.new).to have_one(:detail).autosave(true)
    end

    it 'rejects an association with a non-matching :autosave option with the correct message' do
      define_model :detail, person_id: :integer, disabled: :boolean
      define_model :person do
        has_one :detail, autosave: false
      end

      message = 'Expected Person to have a has_one association called detail (detail should have autosave set to true)'
      expect {
        expect(Person.new).to have_one(:detail).autosave(true)
      }.to fail_with_message(message)
    end


    it 'accepts an association with a through' do
      define_model :detail

      define_model :account do
        has_one :detail
      end

      define_model :person do
        has_one :account
        has_one :detail, through: :account
      end

      expect(Person.new).to have_one(:detail).through(:account)
    end

    it 'rejects an association with a bad through' do
      expect(having_one_detail).not_to have_one(:detail).through(:account)
    end

    context 'validate' do
      it 'accepts when the :validate option matches' do
        expect(having_one_detail(validate: false)).
          to have_one(:detail).validate(false)
      end

      it 'rejects when the :validate option does not match' do
        expect(having_one_detail(validate: true)).
          not_to have_one(:detail).validate(false)
      end

      it 'assumes validate() means validate(true)' do
        expect(having_one_detail(validate: false)).
          not_to have_one(:detail).validate
      end

      it 'matches validate(false) to having no validate option specified' do
        expect(having_one_detail).to have_one(:detail).validate(false)
      end
    end

    def having_one_detail(options = {})
      define_model :detail, person_id: :integer
      define_model(:person).tap do |model|
        if options.key?(:order)
          order = options.delete(:order)
          define_association_with_order(model, :has_one, :detail, order, options)
        else
          model.has_one :detail, options
        end
      end.new
    end

    def having_one_non_existent(model_name, assoc_name, options = {})
      define_model model_name do
        has_one assoc_name, options
      end.new
    end
  end

  context 'have_and_belong_to_many' do
    it 'accepts a valid association' do
      expect(having_and_belonging_to_many_relatives).
        to have_and_belong_to_many(:relatives)
    end

    it 'rejects a nonexistent association' do
      define_model :relative
      define_model :person
      define_model :people_relative, id: false, person_id: :integer,
        relative_id: :integer

      expect(Person.new).not_to have_and_belong_to_many(:relatives)
    end

    it 'rejects an association with a nonexistent join table' do
      define_model :relative
      define_model :person do
        has_and_belongs_to_many :relatives
      end

      expected_failure_message = "join table people_relatives doesn't exist"

      expect do
        expect(Person.new).to have_and_belong_to_many(:relatives)
      end.to fail_with_message_including(expected_failure_message)
    end

    it 'rejects an association with a join table with incorrect columns' do
      define_model :relative
      define_model :person do
        has_and_belongs_to_many :relatives
      end

      define_model :people_relative, id: false, some_crazy_id: :integer

      expect do
        expect(Person.new).to have_and_belong_to_many(:relatives)
      end.to fail_with_message_including('missing columns: person_id, relative_id')
    end

    context 'using a custom foreign key' do
      it 'rejects an association with a join table with incorrect columns' do
        define_model :relative
        define_model :person do
          has_and_belongs_to_many :relatives,
            foreign_key: :custom_foreign_key_id
        end

        define_model :people_relative,
          id: false,
          custom_foreign_key_id: :integer,
          some_crazy_id: :integer

        expect do
          expect(Person.new).to have_and_belong_to_many(:relatives)
        end.to fail_with_message_including('missing column: relative_id')
      end
    end

    context 'using a custom association foreign key' do
      it 'rejects an association with a join table with incorrect columns' do
        define_model :relative
        define_model :person do
          has_and_belongs_to_many :relatives,
            association_foreign_key: :custom_association_foreign_key_id
        end

        define_model :people_relative,
          id: false,
          custom_association_foreign_key_id: :integer,
          some_crazy_id: :integer

        expect do
          expect(Person.new).to have_and_belong_to_many(:relatives)
        end.to fail_with_message_including('missing column: person_id')
      end

      it 'accepts foreign keys when they are symbols' do
        define_model :relative
        define_model :person do
          has_and_belongs_to_many :relatives,
                                  foreign_key: :some_foreign_key_id,
                                  association_foreign_key: :custom_association_foreign_key_id
        end

        define_model :people_relative,
                     id: false,
                     custom_association_foreign_key_id: :integer,
                     some_foreign_key_id: :integer

        expect(Person.new).to have_and_belong_to_many(:relatives)

      end

    end

    it 'rejects an association of the wrong type' do
      define_model :relative, person_id: :integer
      define_model :person do
        has_many :relatives
      end

      expect(Person.new).not_to have_and_belong_to_many(:relatives)
    end

    it 'accepts an association with a valid :conditions option' do
      define_model :relative, adopted: :boolean
      define_model(:person).tap do |model|
        define_association_with_conditions(model, :has_and_belongs_to_many, :relatives, adopted: true)
      end
      define_model :people_relative, id: false, person_id: :integer,
        relative_id: :integer

      expect(Person.new).to have_and_belong_to_many(:relatives).conditions(adopted: true)
    end

    it 'rejects an association with a bad :conditions option' do
      define_model :relative, adopted: :boolean
      define_model :person do
        has_and_belongs_to_many :relatives
      end
      define_model :people_relative, id: false, person_id: :integer,
        relative_id: :integer

      expect(Person.new).not_to have_and_belong_to_many(:relatives).conditions(adopted: true)
    end

    it 'accepts an association without a :class_name option' do
      expect(having_and_belonging_to_many_relatives).
        to have_and_belong_to_many(:relatives).class_name('Relative')
    end

    it 'accepts an association with a valid :class_name option' do
      define_model :person_relative, adopted: :boolean
      define_model :person do
        has_and_belongs_to_many :relatives, class_name: 'PersonRelative'
      end

      define_model :people_person_relative, person_id: :integer,
        person_relative_id: :integer

      expect(Person.new).to have_and_belong_to_many(:relatives).class_name('PersonRelative')
    end

    it 'rejects an association with a bad :class_name option' do
      expect(having_and_belonging_to_many_relatives).
        not_to have_and_belong_to_many(:relatives).class_name('PersonRelatives')
    end

    it 'rejects an association with non-existent implicit class name' do
      expect(having_and_belonging_to_many_non_existent_class(:person, :relatives)).
        not_to have_and_belong_to_many(:relatives)
    end

    it 'rejects an association with non-existent explicit class name' do
      expect(having_and_belonging_to_many_non_existent_class(:person, :relatives, class_name: 'Relative')).
        not_to have_and_belong_to_many(:relatives)
    end

    it 'adds error message when rejecting an association with non-existent class' do
      message = 'Expected Person to have a has_and_belongs_to_many association called relatives (Relative2 does not exist)'
      expect {
        expect(having_and_belonging_to_many_non_existent_class(:person, :relatives, class_name: 'Relative2')).
          to have_and_belong_to_many(:relatives)
      }.to fail_with_message(message)
    end

    it 'accepts an association with a namespaced class name' do
      possible_join_table_names = [:groups_users, :models_groups_users, :groups_models_users]
      possible_join_table_names.each do |join_table_name|
        create_table join_table_name, id: false do |t|
          t.integer :group_id
          t.integer :user_id
        end
      end
      define_module 'Models'
      define_model 'Models::Group'
      user_model = define_model 'Models::User' do
        has_and_belongs_to_many :groups, class_name: 'Group'
      end

      expect(user_model.new).
        to have_and_belong_to_many(:groups).
        class_name('Group')
    end

    it 'resolves class_name within the context of the namespace before the global namespace' do
      possible_join_table_names = [:groups_users, :models_groups_users, :groups_models_users]
      possible_join_table_names.each do |join_table_name|
        create_table join_table_name, id: false do |t|
          t.integer :group_id
          t.integer :user_id
        end
      end
      define_module 'Models'
      define_model 'Group'
      define_model 'Models::Group'
      user_model = define_model 'Models::User' do
        has_and_belongs_to_many :groups, class_name: 'Group'
      end

      expect(user_model.new).
        to have_and_belong_to_many(:groups).
        class_name('Group')
    end

    it 'accepts an association with a matching :autosave option' do
      define_model :relatives, adopted: :boolean
      define_model :person do
        has_and_belongs_to_many :relatives, autosave: true
      end
      define_model :people_relative, person_id: :integer,
                                     relative_id: :integer
      expect(Person.new).to have_and_belong_to_many(:relatives).autosave(true)
    end

    it 'rejects an association with a non-matching :autosave option with the correct message' do
      define_model :relatives, adopted: :boolean
      define_model :person do
        has_and_belongs_to_many :relatives
      end
      define_model :people_relative, person_id: :integer,
                                     relative_id: :integer

      message = 'Expected Person to have a has_and_belongs_to_many association called relatives (relatives should have autosave set to true)'
      expect {
        expect(Person.new).to have_and_belong_to_many(:relatives).autosave(true)
      }.to fail_with_message(message)
    end

    context 'validate' do
      it 'accepts when the :validate option matches' do
        expect(having_and_belonging_to_many_relatives(validate: false)).
          to have_and_belong_to_many(:relatives).validate(false)
      end

      it 'rejects when the :validate option does not match' do
        expect(having_and_belonging_to_many_relatives(validate: true)).
          to have_and_belong_to_many(:relatives).validate(false)
      end

      it 'assumes validate() means validate(true)' do
        expect(having_and_belonging_to_many_relatives(validate: false)).
          not_to have_and_belong_to_many(:relatives).validate
      end

      it 'matches validate(false) to having no validate option specified' do
        expect(having_and_belonging_to_many_relatives).
          to have_and_belong_to_many(:relatives).validate(false)
      end
    end

    def having_and_belonging_to_many_relatives(options = {})
      define_model :relative
      define_model :people_relative, id: false, person_id: :integer,
        relative_id: :integer
      define_model :person do
        has_and_belongs_to_many :relatives
      end.new
    end

    def having_and_belonging_to_many_non_existent_class(model_name, assoc_name, options = {})
      define_model model_name do
        has_and_belongs_to_many assoc_name, options
      end.new
    end
  end

  def define_association_with_conditions(model, macro, name, conditions, other_options={})
    args = []
    options = {}
    if Shoulda::Matchers::RailsShim.active_record_major_version == 4
      args << proc { where(conditions) }
    else
      options[:conditions] = conditions
    end
    args << options
    model.__send__(macro, name, *args)
  end

  def define_association_with_order(model, macro, name, order, other_options={})
    args = []
    options = {}
    if Shoulda::Matchers::RailsShim.active_record_major_version == 4
      args << proc { order(order) }
    else
      options[:order] = order
    end
    args << options
    model.__send__(macro, name, *args)
  end

  def dependent_options
    case Rails.version
    when /\A3/
      [:destroy, :delete, :nullify, :restrict]
    when /\A4/
      [:destroy, :delete, :nullify, :restrict_with_exception, :restrict_with_error]
    end
  end
end
