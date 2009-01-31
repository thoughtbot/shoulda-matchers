require File.join(File.dirname(__FILE__), '..', 'test_helper')

class ValidateUniquenessOfMatcherTest < Test::Unit::TestCase # :nodoc:

  context "a unique attribute" do
    setup do
      @model = define_model(:example, :attr  => :string,
                                           :other => :integer) do
        validates_uniqueness_of :attr
      end.new
    end

    context "with an existing value" do
      setup do
        @existing = Example.create!(:attr => 'value', :other => 1)
      end

      should "require a unique value for that attribute" do
        assert_accepts validate_uniqueness_of(:attr), @model
      end

      should "pass when the subject is an existing record" do
        assert_accepts validate_uniqueness_of(:attr), @existing
      end

      should "fail when a scope is specified" do
        assert_rejects validate_uniqueness_of(:attr).scoped_to(:other), @model
      end
    end

    context "without an existing value" do
      setup do
        assert_nil Example.find(:first)
      end

      should "fail to require a unique value" do
        assert_rejects validate_uniqueness_of(:attr), @model
      end
    end
  end

  context "a unique attribute with a custom error and an existing value" do
    setup do
      @model = define_model(:example, :attr => :string) do
        validates_uniqueness_of :attr, :message => 'Bad value'
      end.new
      Example.create!
    end

    should "fail when checking the default message" do
      assert_rejects validate_uniqueness_of(:attr), @model
    end

    should "fail when checking a message that doesn't match" do
      assert_rejects validate_uniqueness_of(:attr).with_message(/abc/i), @model
    end

    should "pass when checking a message that matches" do
      assert_accepts validate_uniqueness_of(:attr).with_message(/bad/i), @model
    end
  end

  context "a scoped unique attribute with an existing value" do
    setup do
      @model = define_model(:example, :attr   => :string,
                                           :scope1 => :integer,
                                           :scope2 => :integer) do
        validates_uniqueness_of :attr, :scope => [:scope1, :scope2]
      end.new
      @existing = Example.create!(:attr => 'value', :scope1 => 1, :scope2 => 2)
    end

    should "pass when the correct scope is specified" do
      assert_accepts validate_uniqueness_of(:attr).scoped_to(:scope1, :scope2),
        @model
    end

    should "pass when the subject is an existing record" do
      assert_accepts validate_uniqueness_of(:attr).scoped_to(:scope1, :scope2),
        @existing
    end

    should "fail when a different scope is specified" do
      assert_rejects validate_uniqueness_of(:attr).scoped_to(:scope1), @model
    end

    should "fail when no scope is specified" do
      assert_rejects validate_uniqueness_of(:attr), @model
    end

    should "fail when a non-existent attribute is specified as a scope" do
      assert_rejects validate_uniqueness_of(:attr).scoped_to(:fake), @model
    end
  end

  context "a non-unique attribute with an existing value" do
    setup do
      @model = define_model(:example, :attr => :string).new
      Example.create!(:attr => 'value')
    end

    should "not require a unique value for that attribute" do
      assert_rejects validate_uniqueness_of(:attr), @model
    end
  end

  context "a case sensitive unique attribute with an existing value" do
    setup do
      @model = define_model(:example, :attr  => :string) do
        validates_uniqueness_of :attr, :case_sensitive => true
      end.new
      Example.create!(:attr => 'value')
    end

    should "not require a unique, case-insensitive value for that attribute" do
      assert_rejects validate_uniqueness_of(:attr).case_insensitive, @model
    end

    should "require a unique, case-sensitive value for that attribute" do
      assert_accepts validate_uniqueness_of(:attr), @model
    end
  end

  context "a case sensitive unique integer attribute with an existing value" do
    setup do
      @model = define_model(:example, :attr  => :integer) do
        validates_uniqueness_of :attr, :case_sensitive => true
      end.new
      Example.create!(:attr => 'value')
    end

    should "require a unique, case-insensitive value for that attribute" do
      assert_accepts validate_uniqueness_of(:attr).case_insensitive, @model
    end

    should "require a unique, case-sensitive value for that attribute" do
      assert_accepts validate_uniqueness_of(:attr), @model
    end
  end

end
