require File.join(File.dirname(__FILE__), '..', 'test_helper')
require 'mocha'

class ActiveRecordMatchersTest < Test::Unit::TestCase # :nodoc:

  context "an attribute with a format validation" do
    setup do
      build_model_class :example, :attr => :string do
        validates_format_of :attr, :with => /abc/
      end
      @model = Example.new
    end

    should "allow a good value" do
      assert_accepts allow_value("abcde").for(:attr), @model
    end
    
    should "not allow a bad value" do
      assert_rejects allow_value("xyz").for(:attr), @model
    end
  end

  context "an attribute with a format validation and a custom message" do
    setup do
      build_model_class :example, :attr => :string do
        validates_format_of :attr, :with => /abc/, :message => 'bad value'
      end
      @model = Example.new
    end

    should "allow a good value" do
      assert_accepts allow_value('abcde').for(:attr).with_message(/bad/),
                     @model
    end
    
    should "not allow a bad value" do
      assert_rejects allow_value('xyz').for(:attr).with_message(/bad/),
                     @model
    end
  end

  context "a required attribute" do
    setup do
      build_model_class :example, :attr => :string do
        validates_presence_of :attr
      end
      @model = Example.new
    end

    should "not allow a blank value" do
      assert_rejects allow_blank_for(:attr), @model
    end

    should "not override the default message with a blank" do
      assert_rejects allow_blank_for(:attr).with_message(nil), @model
    end
  end

  context "a required has_many association" do
    setup do
      build_model_class :child
      @model = build_model_class :parent do
        has_many :children
        validates_presence_of :children
      end.new
    end

    should "not allow a blank value" do
      assert_rejects allow_blank_for(:children), @model
    end
  end

  context "an optional has_many association" do
    setup do
      build_model_class :child
      @model = build_model_class :parent do
        has_many :children
      end.new
    end

    should "allow a blank value" do
      assert_accepts allow_blank_for(:children), @model
    end
  end

  context "a required has_and_belongs_to_many association" do
    setup do
      build_model_class :child
      @model = build_model_class :parent do
        has_and_belongs_to_many :children
        validates_presence_of :children
      end.new
    end

    should "not allow a blank value" do
      assert_rejects allow_blank_for(:children), @model
    end
  end

  context "an optional has_and_belongs_to_many association" do
    setup do
      build_model_class :child
      @model = build_model_class :parent do
        has_and_belongs_to_many :children
      end.new
    end

    should "allow a blank value" do
      assert_accepts allow_blank_for(:children), @model
    end
  end

  context "an optional attribute" do
    setup do
      @model = build_model_class(:example, :attr => :string).new
    end

    should "allow a blank value" do
      assert_accepts allow_blank_for(:attr), @model
    end
  end

  context "a unique attribute" do
    setup do
      @model = build_model_class(:example, :attr  => :string,
                                           :other => :integer) do
        validates_uniqueness_of :attr
      end.new
    end

    context "with an existing value" do
      setup do
        Example.create!(:attr => 'value', :other => 1)
      end

      should "require a unique value for that attribute" do
        assert_accepts require_unique_attribute(:attr), @model
      end

      should "fail when a scope is specified" do
        assert_rejects require_unique_attribute(:attr).scoped_to(:other), @model
      end
    end

    context "without an existing value" do
      setup do
        assert_nil Example.find(:first)
      end

      should "fail to require a unique value" do
        assert_rejects require_unique_attribute(:attr), @model
      end
    end
  end

  context "a unique attribute with a custom error and an existing value" do
    setup do
      @model = build_model_class(:example, :attr => :string) do
        validates_uniqueness_of :attr, :message => 'Bad value'
      end.new
      Example.create!
    end

    should "fail when checking the default message" do
      assert_rejects require_unique_attribute(:attr), @model
    end

    should "fail when checking a message that doesn't match" do
      assert_rejects require_unique_attribute(:attr).with_message(/abc/i), @model
    end

    should "pass when checking a message that matches" do
      assert_accepts require_unique_attribute(:attr).with_message(/bad/i), @model
    end
  end

  context "a scoped unique attribute with an existing value" do
    setup do
      @model = build_model_class(:example, :attr   => :string,
                                           :scope1 => :integer,
                                           :scope2 => :integer) do
        validates_uniqueness_of :attr, :scope => [:scope1, :scope2]
      end.new
      Example.create!(:attr => 'value', :scope1 => 1, :scope2 => 2)
    end

    should "pass when the correct scope is specified" do
      assert_accepts require_unique_attribute(:attr).scoped_to(:scope1, :scope2),
        @model
    end

    should "fail when a different scope is specified" do
      assert_rejects require_unique_attribute(:attr).scoped_to(:scope1), @model
    end

    should "fail when no scope is specified" do
      assert_rejects require_unique_attribute(:attr), @model
    end

    should "fail when a non-existent attribute is specified as a scope" do
      assert_rejects require_unique_attribute(:attr).scoped_to(:fake), @model
    end
  end

  context "a non-unique attribute with an existing value" do
    setup do
      @model = build_model_class(:example, :attr => :string).new
      Example.create!(:attr => 'value')
    end

    should "not require a unique value for that attribute" do
      assert_rejects require_unique_attribute(:attr), @model
    end
  end

  context "a case sensitive unique attribute with an existing value" do
    setup do
      @model = build_model_class(:example, :attr  => :string) do
        validates_uniqueness_of :attr, :case_sensitive => true
      end.new
      Example.create!(:attr => 'value')
    end

    should "not require a unique, case-insensitive value for that attribute" do
      assert_rejects require_unique_attribute(:attr).case_insensitive, @model
    end

    should "require a unique, case-sensitive value for that attribute" do
      assert_accepts require_unique_attribute(:attr), @model
    end
  end

  context "a case sensitive unique integer attribute with an existing value" do
    setup do
      @model = build_model_class(:example, :attr  => :integer) do
        validates_uniqueness_of :attr, :case_sensitive => true
      end.new
      Example.create!(:attr => 'value')
    end

    should "require a unique, case-insensitive value for that attribute" do
      assert_accepts require_unique_attribute(:attr).case_insensitive, @model
    end

    should "require a unique, case-sensitive value for that attribute" do
      assert_accepts require_unique_attribute(:attr), @model
    end
  end

  context "an attribute with a non-zero minimum length validation" do
    setup do
      @model = build_model_class(:example, :attr => :string) do
        validates_length_of :attr, :minimum => 4
      end.new
    end

    should "accept ensuring the correct minimum length" do
      assert_accepts ensure_length_of(:attr).is_at_least(4), @model
    end

    should "reject ensuring a lower minimum length with any message" do
      assert_rejects ensure_length_of(:attr).
                       is_at_least(3).
                       with_short_message(/.*/),
                     @model
    end

    should "reject ensuring a higher minimum length with any message" do
      assert_rejects ensure_length_of(:attr).
                       is_at_least(5).
                       with_short_message(/.*/),
                     @model
    end

    should "not override the default message with a blank" do
      assert_accepts ensure_length_of(:attr).
                       is_at_least(4).
                       with_short_message(nil),
                     @model
    end
  end

  context "an attribute with a minimum length validation of 0" do
    setup do
      @model = build_model_class(:example, :attr => :string) do
        validates_length_of :attr, :minimum => 0
      end.new
    end

    should "accept ensuring the correct minimum length" do
      assert_accepts ensure_length_of(:attr).is_at_least(0), @model
    end
  end

  context "an attribute with a custom minimum length validation" do
    setup do
      @model = build_model_class(:example, :attr => :string) do
        validates_length_of :attr, :minimum => 4, :too_short => 'short'
      end.new
    end

    should "accept ensuring the correct minimum length" do
      assert_accepts ensure_length_of(:attr).
                       is_at_least(4).
                       with_short_message(/short/),
                     @model
    end

  end

  context "an attribute without a length validation" do
    setup do
      @model = build_model_class(:example, :attr => :string).new
    end

    should "reject ensuring a minimum length" do
      assert_rejects ensure_length_of(:attr).is_at_least(1), @model
    end
  end

  context "belong_to" do
    setup do
      @matcher = belong_to(:parent)
    end

    should "accept a good association with the default foreign key" do
      build_model_class :parent
      build_model_class :child, :parent_id => :integer do
        belongs_to :parent
      end
      assert_accepts @matcher, Child.new
    end

    should "reject a nonexistent association" do
      build_model_class :child
      assert_rejects @matcher, Child.new
    end

    should "reject an association of the wrong type" do
      build_model_class :parent, :child_id => :integer
      child_class = build_model_class :child do
        has_one :parent
      end
      assert_rejects @matcher, Child.new
    end

    should "reject an association that has a nonexistent foreign key" do
      build_model_class :parent
      build_model_class :child do
        belongs_to :parent
      end
      assert_rejects @matcher, Child.new
    end

    should "accept an association with an existing custom foreign key" do
      build_model_class :parent
      build_model_class :child, :guardian_id => :integer do
        belongs_to :parent, :foreign_key => 'guardian_id'
      end
      assert_accepts @matcher, Child.new
    end

    should "accept a polymorphic association" do
      build_model_class :child, :parent_type => :string,
                                :parent_id   => :integer do
        belongs_to :parent, :polymorphic => true
      end
      assert_accepts @matcher, Child.new
    end

    should "accept an association with a valid :dependent option" do
      build_model_class :parent
      build_model_class :child, :parent_id => :integer do
        belongs_to :parent, :dependent => :destroy
      end
      assert_accepts @matcher.dependent(:destroy), Child.new
    end

    should "reject an association with a bad :dependent option" do
      build_model_class :parent
      build_model_class :child, :parent_id => :integer do
        belongs_to :parent
      end
      assert_rejects @matcher.dependent(:destroy), Child.new
    end
  end

  context "have_many" do
    setup do
      @matcher = have_many(:children)
    end

    should "accept a valid association without any options" do
      build_model_class :child, :parent_id => :integer
      build_model_class :parent do
        has_many :children
      end
      assert_accepts @matcher, Parent.new
    end

    should "accept a valid association with a :through option" do
      build_model_class :child
      build_model_class :conception, :child_id  => :integer,
                                     :parent_id => :integer do
        belongs_to :child
      end
      build_model_class :parent do
        has_many :conceptions
        has_many :children, :through => :conceptions
      end
      assert_accepts @matcher, Parent.new
    end

    should "accept a valid association with an :as option" do
      build_model_class :child, :guardian_type => :string,
                                :guardian_id   => :integer
      build_model_class :parent do
        has_many :children, :as => :guardian
      end
      assert_accepts @matcher, Parent.new
    end

    should "reject an association that has a nonexistent foreign key" do
      build_model_class :child
      build_model_class :parent do
        has_many :children
      end
      assert_rejects @matcher, Parent.new
    end

    should "reject an association with a bad :as option" do
      build_model_class :child, :caretaker_type => :string,
                                :caretaker_id   => :integer
      build_model_class :parent do
        has_many :children, :as => :guardian
      end
      assert_rejects @matcher, Parent.new
    end

    should "reject an association that has a bad :through option" do
      build_model_class :child, :parent_id => :integer
      build_model_class :parent do
        has_many :children
      end
      assert_rejects @matcher.through(:conceptions), Parent.new
    end

    should "reject an association that has the wrong :through option" do
      build_model_class :child
      build_model_class :conception, :child_id  => :integer,
                                     :parent_id => :integer do
        belongs_to :child
      end
      build_model_class :parent do
        has_many :conceptions
        has_many :children, :through => :conceptions
      end
      assert_rejects @matcher.through(:relationships), Parent.new
    end

    should "accept an association with a valid :dependent option" do
      build_model_class :child, :parent_id => :integer
      build_model_class :parent do
        has_many :children, :dependent => :destroy
      end
      assert_accepts @matcher.dependent(:destroy), Parent.new
    end

    should "reject an association with a bad :dependent option" do
      build_model_class :child, :parent_id => :integer
      build_model_class :parent do
        has_many :children
      end
      assert_rejects @matcher.dependent(:destroy), Parent.new
    end
  end

  context "have_one" do
    setup do
      @matcher = have_one(:profile)
    end

    should "accept a valid association without any options" do
      build_model_class :profile, :person_id => :integer
      build_model_class :person do
        has_one :profile
      end
      assert_accepts @matcher, Person.new
    end

    should "accept a valid association with an :as option" do
      build_model_class :profile, :profilable_id   => :integer,
                                  :profilable_type => :string
      build_model_class :person do
        has_one :profile, :as => :profilable
      end
      assert_accepts @matcher, Person.new
    end

    should "reject an association that has a nonexistent foreign key" do
      build_model_class :profile
      build_model_class :person do
        has_one :profile
      end
      assert_rejects @matcher, Person.new
    end

    should "reject an association with a bad :as option" do
      build_model_class :profile, :profilable_id   => :integer,
                                  :profilable_type => :string
      build_model_class :person do
        has_one :profile, :as => :describable
      end
      assert_rejects @matcher, Person.new
    end

    should "accept an association with a valid :dependent option" do
      build_model_class :profile, :person_id => :integer
      build_model_class :person do
        has_one :profile, :dependent => :destroy
      end
      assert_accepts @matcher.dependent(:destroy), Person.new
    end

    should "reject an association with a bad :dependent option" do
      build_model_class :profile, :person_id => :integer
      build_model_class :person do
        has_one :profile
      end
      assert_rejects @matcher.dependent(:destroy), Person.new
    end
  end

  context "have_and_belong_to_many" do
    setup do
      @matcher = have_and_belong_to_many(:relatives)
    end

    should "accept a valid association" do
      build_model_class :relatives
      build_model_class :person do
        has_and_belongs_to_many :relatives
      end
      build_model_class :people_relative, :person_id   => :integer,
                                          :relative_id => :integer
      assert_accepts @matcher, Person.new
    end

    should "reject a nonexistent association" do
      build_model_class :relatives
      build_model_class :person
      build_model_class :people_relative, :person_id   => :integer,
                                          :relative_id => :integer
      assert_rejects @matcher, Person.new
    end

    should "reject an association with a nonexistent join table" do
      build_model_class :relatives
      build_model_class :person do
        has_and_belongs_to_many :relatives
      end
      assert_rejects @matcher, Person.new
    end

    should "reject an association of the wrong type" do
      build_model_class :relatives, :person_id => :integer
      build_model_class :person do
        has_many :relatives
      end
      assert_rejects @matcher, Person.new
    end
  end

end
