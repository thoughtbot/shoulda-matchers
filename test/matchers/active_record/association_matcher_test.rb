require File.join(File.dirname(__FILE__), '..', '..', 'test_helper')

class AssociationMatcherTest < Test::Unit::TestCase # :nodoc:

  context "belong_to" do
    setup do
      @matcher = belong_to(:parent)
    end

    should "accept a good association with the default foreign key" do
      define_model :parent
      define_model :child, :parent_id => :integer do
        belongs_to :parent
      end
      assert_accepts @matcher, Child.new
    end

    should "reject a nonexistent association" do
      define_model :child
      assert_rejects @matcher, Child.new
    end

    should "reject an association of the wrong type" do
      define_model :parent, :child_id => :integer
      child_class = define_model :child do
        has_one :parent
      end
      assert_rejects @matcher, Child.new
    end

    should "reject an association that has a nonexistent foreign key" do
      define_model :parent
      define_model :child do
        belongs_to :parent
      end
      assert_rejects @matcher, Child.new
    end

    should "accept an association with an existing custom foreign key" do
      define_model :parent
      define_model :child, :guardian_id => :integer do
        belongs_to :parent, :foreign_key => 'guardian_id'
      end
      assert_accepts @matcher, Child.new
    end

    should "accept a polymorphic association" do
      define_model :child, :parent_type => :string,
                                :parent_id   => :integer do
        belongs_to :parent, :polymorphic => true
      end
      assert_accepts @matcher, Child.new
    end

    should "accept an association with a valid :dependent option" do
      define_model :parent
      define_model :child, :parent_id => :integer do
        belongs_to :parent, :dependent => :destroy
      end
      assert_accepts @matcher.dependent(:destroy), Child.new
    end

    should "reject an association with a bad :dependent option" do
      define_model :parent
      define_model :child, :parent_id => :integer do
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
      define_model :child, :parent_id => :integer
      define_model :parent do
        has_many :children
      end
      assert_accepts @matcher, Parent.new
    end

    should "accept a valid association with a :through option" do
      define_model :child
      define_model :conception, :child_id  => :integer,
                                     :parent_id => :integer do
        belongs_to :child
      end
      define_model :parent do
        has_many :conceptions
        has_many :children, :through => :conceptions
      end
      assert_accepts @matcher, Parent.new
    end

    should "accept a valid association with an :as option" do
      define_model :child, :guardian_type => :string,
                                :guardian_id   => :integer
      define_model :parent do
        has_many :children, :as => :guardian
      end
      assert_accepts @matcher, Parent.new
    end

    should "reject an association that has a nonexistent foreign key" do
      define_model :child
      define_model :parent do
        has_many :children
      end
      assert_rejects @matcher, Parent.new
    end

    should "reject an association with a bad :as option" do
      define_model :child, :caretaker_type => :string,
                                :caretaker_id   => :integer
      define_model :parent do
        has_many :children, :as => :guardian
      end
      assert_rejects @matcher, Parent.new
    end

    should "reject an association that has a bad :through option" do
      define_model :child, :parent_id => :integer
      define_model :parent do
        has_many :children
      end
      assert_rejects @matcher.through(:conceptions), Parent.new
    end

    should "reject an association that has the wrong :through option" do
      define_model :child
      define_model :conception, :child_id  => :integer,
                                     :parent_id => :integer do
        belongs_to :child
      end
      define_model :parent do
        has_many :conceptions
        has_many :children, :through => :conceptions
      end
      assert_rejects @matcher.through(:relationships), Parent.new
    end

    should "accept an association with a valid :dependent option" do
      define_model :child, :parent_id => :integer
      define_model :parent do
        has_many :children, :dependent => :destroy
      end
      assert_accepts @matcher.dependent(:destroy), Parent.new
    end

    should "reject an association with a bad :dependent option" do
      define_model :child, :parent_id => :integer
      define_model :parent do
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
      define_model :profile, :person_id => :integer
      define_model :person do
        has_one :profile
      end
      assert_accepts @matcher, Person.new
    end

    should "accept a valid association with an :as option" do
      define_model :profile, :profilable_id   => :integer,
                                  :profilable_type => :string
      define_model :person do
        has_one :profile, :as => :profilable
      end
      assert_accepts @matcher, Person.new
    end

    should "reject an association that has a nonexistent foreign key" do
      define_model :profile
      define_model :person do
        has_one :profile
      end
      assert_rejects @matcher, Person.new
    end

    should "reject an association with a bad :as option" do
      define_model :profile, :profilable_id   => :integer,
                                  :profilable_type => :string
      define_model :person do
        has_one :profile, :as => :describable
      end
      assert_rejects @matcher, Person.new
    end

    should "accept an association with a valid :dependent option" do
      define_model :profile, :person_id => :integer
      define_model :person do
        has_one :profile, :dependent => :destroy
      end
      assert_accepts @matcher.dependent(:destroy), Person.new
    end

    should "reject an association with a bad :dependent option" do
      define_model :profile, :person_id => :integer
      define_model :person do
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
      define_model :relatives
      define_model :person do
        has_and_belongs_to_many :relatives
      end
      define_model :people_relative, :person_id   => :integer,
                                          :relative_id => :integer
      assert_accepts @matcher, Person.new
    end

    should "reject a nonexistent association" do
      define_model :relatives
      define_model :person
      define_model :people_relative, :person_id   => :integer,
                                          :relative_id => :integer
      assert_rejects @matcher, Person.new
    end

    should "reject an association with a nonexistent join table" do
      define_model :relatives
      define_model :person do
        has_and_belongs_to_many :relatives
      end
      assert_rejects @matcher, Person.new
    end

    should "reject an association of the wrong type" do
      define_model :relatives, :person_id => :integer
      define_model :person do
        has_many :relatives
      end
      assert_rejects @matcher, Person.new
    end
  end

end
