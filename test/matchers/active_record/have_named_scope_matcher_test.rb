require File.join(File.dirname(__FILE__), '..', '..', 'test_helper')

class HaveNamedScopeMatcherTest < ActiveSupport::TestCase # :nodoc:

  context "an attribute with a named scope" do
    setup do
      define_model :example, :attr => :string do
        named_scope :xyz, lambda {|n|
          { :order => :attr }
        }
      end
      @model = Example.new
    end

    should "accept having a scope with the correct signature" do
      assert_accepts have_named_scope("xyz(1)"), @model
    end

    should "accept having a scope with the correct signature and find options" do
      assert_accepts have_named_scope("xyz(1)").finding(:order => :attr), @model
    end
    
    should "reject having a scope with incorrect find options" do
      assert_rejects have_named_scope("xyz(1)").
                       finding(:order => 'attr DESC'),
                     @model
    end
    
    should "reject having a scope with another name" do
      assert_rejects have_named_scope("abc(1)"), @model
    end

  end

  should "evaluate the scope in the correct context" do
    define_model :example, :attr => :string do
      named_scope :xyz, lambda {|n|
        { :order => n }
      }
    end
    model = Example.new
    @order = :attr
    assert_accepts have_named_scope("xyz(@order)").
                     finding(:order => @order).
                     in_context(self),
                   model
  end

  context "a method that does not return a scope" do
    setup do
      klass = Class.new
      klass.class_eval do
        def self.xyz
          'xyz'
        end
      end
      @model = klass.new
    end

    should "reject having a named scope with that name" do
      assert_rejects have_named_scope(:xyz), @model
    end
  end

end
