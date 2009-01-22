require File.join(File.dirname(__FILE__), '..', 'test_helper')

class DatabaseMatcherTest < Test::Unit::TestCase # :nodoc:

  context "has_db_column" do
    setup do
      @matcher = has_db_column(:avatar_file_name)
    end

    should "accept an existing database column" do
      build_model_class :user, :avatar_file_name => :string
      assert_accepts @matcher, User.new
    end
    
    should "reject a nonexistent database column" do
      build_model_class :user
      assert_rejects @matcher, User.new
    end
  end

end
