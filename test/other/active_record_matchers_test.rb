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
      assert_accepts accept_value("abcde").for(:attr), @model
    end
    
    should "not allow a bad value" do
      assert_rejects accept_value("xyz").for(:attr), @model
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
      assert_accepts accept_value('abcde').for(:attr).with_message(/bad/),
                     @model
    end
    
    should "not allow a bad value" do
      assert_rejects accept_value('xyz').for(:attr).with_message(/bad/),
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
  end

  context "an optional attribute" do
    setup do
      @model = build_model_class(:example, :attr => :string).new
    end

    should "allow a blank value" do
      assert_accepts allow_blank_for(:attr), @model
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
