require File.join(File.dirname(__FILE__), '..', '..', 'test_helper')

class AllowMassAssignmentOfMatcherTest < ActiveSupport::TestCase # :nodoc:

  context "an attribute that is blacklisted from mass-assignment" do
    setup do
      define_model :example, :attr => :string do
        attr_protected :attr
      end
      @model = Example.new
    end

    should "reject being mass-assignable" do
      assert_rejects allow_mass_assignment_of(:attr), @model
    end
  end

  context "an attribute that is not whitelisted for mass-assignment" do
    setup do
      define_model :example, :attr => :string, :other => :string do
        attr_accessible :other
      end
      @model = Example.new
    end

    should "reject being mass-assignable" do
      assert_rejects allow_mass_assignment_of(:attr), @model
    end
  end

  context "an attribute that is whitelisted for mass-assignment" do
    setup do
      define_model :example, :attr => :string do
        attr_accessible :attr
      end
      @model = Example.new
    end

    should "accept being mass-assignable" do
      assert_accepts allow_mass_assignment_of(:attr), @model
    end
  end

  context "an attribute not included in the mass-assignment blacklist" do
    setup do
      define_model :example, :attr => :string, :other => :string do
        attr_protected :other
      end
      @model = Example.new
    end

    should "accept being mass-assignable" do
      assert_accepts allow_mass_assignment_of(:attr), @model
    end
  end

  context "an attribute on a class with no protected attributes" do
    setup do
      define_model :example, :attr => :string
      @model = Example.new
    end

    should "accept being mass-assignable" do
      assert_accepts allow_mass_assignment_of(:attr), @model
    end
  end

end
