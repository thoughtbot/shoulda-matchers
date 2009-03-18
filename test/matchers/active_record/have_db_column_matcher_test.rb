require File.join(File.dirname(__FILE__), '..', '..', 'test_helper')

class HaveDbColumnMatcherTest < ActiveSupport::TestCase # :nodoc:

  context "have_db_column" do
    setup do
      @matcher = have_db_column(:nickname)
    end

    should "accept an existing database column" do
      create_table 'superheros' do |table|
        table.string :nickname
      end
      define_model_class 'Superhero'
      assert_accepts @matcher, Superhero.new
    end
    
    should "reject a nonexistent database column" do
      define_model :superhero
      assert_rejects @matcher, Superhero.new
    end
  end
  
  context "have_db_column of type string" do
    setup do
      @matcher = have_db_column(:nickname).of_type(:string)
    end

    should "accept a column of correct type" do
      create_table 'superheros' do |table|
        table.string :nickname
      end
      define_model_class 'Superhero'
      assert_accepts @matcher, Superhero.new
    end
    
    should "reject a nonexistent database column" do
      define_model :superhero
      assert_rejects @matcher, Superhero.new
    end
    
    should "reject a column of wrong type" do
      create_table 'superheros' do |table|
        table.integer :nickname
      end
      define_model_class 'Superhero'
      assert_rejects @matcher, Superhero.new
    end
  end
  
  context "have_db_column with precision option" do
    setup do
      @matcher = have_db_column(:salary).with_options(:precision => 5)
    end
    
    should "accept a column of correct precision" do
      create_table 'superheros' do |table|
        table.decimal :salary, :precision => 5
      end
      define_model_class 'Superhero'
      assert_accepts @matcher, Superhero.new
    end

    should "reject a column of wrong precision" do
      create_table 'superheros' do |table|
        table.decimal :salary, :precision => 15
      end
      define_model_class 'Superhero'
      assert_rejects @matcher, Superhero.new
    end
  end
  
  context "have_db_column with limit option" do
    setup do
      @matcher = have_db_column(:email).
                   of_type(:string).
                   with_options(:limit => 255)
    end
    
    should "accept a column of correct limit" do
      create_table 'superheros' do |table|
        table.string :email, :limit => 255
      end
      define_model_class 'Superhero'
      assert_accepts @matcher, Superhero.new
    end

    should "reject a column of wrong limit" do
      create_table 'superheros' do |table|
        table.string :email, :limit => 500
      end
      define_model_class 'Superhero'
      assert_rejects @matcher, Superhero.new
    end
  end
  
  context "have_db_column with default option" do
    setup do
      @matcher = have_db_column(:admin).
                   of_type(:boolean).
                   with_options(:default => false)
    end
    
    should "accept a column of correct default" do
      create_table 'superheros' do |table|
        table.boolean :admin, :default => false
      end
      define_model_class 'Superhero'
      assert_accepts @matcher, Superhero.new
    end

    should "reject a column of wrong default" do
      create_table 'superheros' do |table|
        table.boolean :admin, :default => true
      end
      define_model_class 'Superhero'
      assert_rejects @matcher, Superhero.new
    end
  end
  
  context "have_db_column with null option" do
    setup do
      @matcher = have_db_column(:admin).
                   of_type(:boolean).
                   with_options(:null => false)
    end
    
    should "accept a column of correct null" do
      create_table 'superheros' do |table|
        table.boolean :admin, :null => false
      end
      define_model_class 'Superhero'
      assert_accepts @matcher, Superhero.new
    end

    should "reject a column of wrong null" do
      create_table 'superheros' do |table|
        table.boolean :admin, :null => true
      end
      define_model_class 'Superhero'
      assert_rejects @matcher, Superhero.new
    end
  end
  
  context "have_db_column with scale option" do
    setup do
      @matcher = have_db_column(:salary).
                   of_type(:decimal).
                   with_options(:scale => 2)
    end
    
    should "accept a column of correct scale" do
      create_table 'superheros' do |table|
        table.decimal :salary, :precision => 10, :scale => 2
      end
      define_model_class 'Superhero'
      assert_accepts @matcher, Superhero.new
    end

    should "reject a column of wrong scale" do
      create_table 'superheros' do |table|
        table.decimal :salary, :precision => 10, :scale => 4
      end
      define_model_class 'Superhero'
      assert_rejects @matcher, Superhero.new
    end
  end
  
end
