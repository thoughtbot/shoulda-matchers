require File.join(File.dirname(__FILE__), '..', 'test_helper')

class ProtectAttributeMatcherTest < Test::Unit::TestCase # :nodoc:

  context "an attribute that is blacklisted from mass-assignment" do
    setup do
      build_model_class :example, :attr => :string do
        attr_protected :attr
      end
      @model = Example.new
    end

    should "accept being protected" do
      assert_accepts protect_attribute(:attr), @model
    end
  end

  context "an attribute that is not whitelisted for mass-assignment" do
    setup do
      build_model_class :example, :attr => :string, :other => :string do
        attr_accessible :other
      end
      @model = Example.new
    end

    should "accept being protected" do
      assert_accepts protect_attribute(:attr), @model
    end
  end

  context "an attribute that is whitelisted for mass-assignment" do
    setup do
      build_model_class :example, :attr => :string do
        attr_accessible :attr
      end
      @model = Example.new
    end

    should "reject being protected" do
      assert_rejects protect_attribute(:attr), @model
    end
  end

  context "an attribute not included in the mass-assignment blacklist" do
    setup do
      build_model_class :example, :attr => :string, :other => :string do
        attr_protected :other
      end
      @model = Example.new
    end

    should "reject being protected" do
      assert_rejects protect_attribute(:attr), @model
    end
  end

  context "an attribute on a class with no protected attributes" do
    setup do
      build_model_class :example, :attr => :string
      @model = Example.new
    end

    should "reject being protected" do
      assert_rejects protect_attribute(:attr), @model
    end
  end

end
