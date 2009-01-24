require File.join(File.dirname(__FILE__), '..', 'test_helper')

class DatabaseMatcherTest < Test::Unit::TestCase # :nodoc:

  context "has_db_column" do
    setup do
      @matcher = has_db_column(:nickname)
    end

    should "accept an existing database column" do
      db_column = DatabaseColumn.new(:nickname, :string)
      build_model_class :superhero, db_column
      assert_accepts @matcher, Superhero.new
    end
    
    should "reject a nonexistent database column" do
      build_model_class :superhero
      assert_rejects @matcher, Superhero.new
    end
  end
  
  context "has_db_column with column_type option" do
    setup do
      @matcher = has_db_column(:nickname).column_type(:string)
    end

    should "accept a column of correct type" do
      db_column = DatabaseColumn.new(:nickname, :string)
      build_model_class :superhero, db_column
      assert_accepts @matcher, Superhero.new
    end
    
    should "reject a column of wrong type" do
      db_column = DatabaseColumn.new(:nickname, :integer)
      build_model_class :superhero, db_column
      assert_rejects @matcher, Superhero.new
    end
  end
  
  context "has_db_column with precision option" do
    setup do
      @matcher = has_db_column(:money).precision(15)
    end
    
    should "accept a column of correct precision" do
      db_column = DatabaseColumn.new(:money, :decimal, :precision => 15)
      build_model_class :superhero, db_column
      assert_accepts @matcher, Superhero.new
    end

    should "reject a column of wrong precision" do
      db_column = DatabaseColumn.new(:money, :decimal, :precision => 30)
      build_model_class :superhero, db_column
      assert_rejects @matcher, Superhero.new
    end
  end
  
  context "has_db_column with limit option" do
    setup do
      @matcher = has_db_column(:email).column_type(:string).limit(255)
    end
    
    should "accept a column of correct limit" do
      db_column = DatabaseColumn.new(:email, :string, :limit => 255)
      build_model_class :superhero, db_column
      assert_accepts @matcher, Superhero.new
    end

    should "reject a column of wrong limit" do
      db_column = DatabaseColumn.new(:email, :string, :limit => 500)
      build_model_class :superhero, db_column
      assert_rejects @matcher, Superhero.new
    end
  end
  
  context "has_db_column with default option" do
    setup do
      @matcher = has_db_column(:admin).column_type(:boolean).default(false)
    end
    
    should "accept a column of correct default" do
      db_column = DatabaseColumn.new(:admin, :boolean, :default => false)
      build_model_class :superhero, db_column
      assert_accepts @matcher, Superhero.new
    end

    should "reject a column of wrong default" do
      db_column = DatabaseColumn.new(:admin, :boolean, :default => true)
      build_model_class :superhero, db_column
      assert_rejects @matcher, Superhero.new
    end
  end
  
  # :default, :null,
  # :primary, :scale, and :sql_type

end
