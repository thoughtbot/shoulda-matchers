require File.join(File.dirname(__FILE__), '..', 'test_helper')

class DatabaseMatcherTest < Test::Unit::TestCase # :nodoc:

  context "has_db_column" do
    setup do
      @matcher = has_db_column(:avatar_file_name)
    end

    should "accept an existing database column" do
      build_model_class :account, :avatar_file_name => :string
      assert_accepts @matcher, Account.new
    end
    
    should "reject a nonexistent database column" do
      build_model_class :account
      assert_rejects @matcher, Account.new
    end
  end
  
  context "has_db_column with :type option" do
    setup do
      @matcher = has_db_column(:avatar_file_name, :type => :string)
    end

    should "accept an existing database column" do
      build_model_class :account, :avatar_file_name => :string
      assert_accepts @matcher, Account.new
    end
    
    should "reject a nonexistent database column" do
      build_model_class :account
      assert_rejects @matcher, Account.new
    end
    
    should "reject a column with the correct name but wrong type" do
      build_model_class :account, :avatar_file_name => :integer
      assert_rejects @matcher, Account.new
    end
  end

end
