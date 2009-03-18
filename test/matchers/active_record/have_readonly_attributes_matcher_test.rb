require File.join(File.dirname(__FILE__), '..', '..', 'test_helper')

class HaveReadonlyAttributesMatcherTest < ActiveSupport::TestCase # :nodoc:

  context "an attribute that cannot be set after being saved" do
    setup do
      define_model :example, :attr => :string do
        attr_readonly :attr
      end
      @model = Example.new
    end

    should "accept being read-only" do
      assert_accepts have_readonly_attribute(:attr), @model
    end
  end

  context "an attribute that can be set after being saved" do
    setup do
      define_model :example, :attr => :string
      @model = Example.new
    end

    should "accept being read-only" do
      assert_rejects have_readonly_attribute(:attr), @model
    end
  end

end
