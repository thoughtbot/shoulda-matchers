require 'spec_helper'

describe Shoulda::ActiveRecord::HaveDbColumnMatcher do

  context "have_db_column" do
    before do
      @matcher = have_db_column(:nickname)
    end

    it "should accept an existing database column" do
      create_table 'superheros' do |table|
        table.string :nickname
      end
      define_model_class 'Superhero'
      Superhero.new.should @matcher
    end

    it "should reject a nonexistent database column" do
      define_model :superhero
      Superhero.new.should_not @matcher
    end
  end

  context "have_db_column of type string" do
    before do
      @matcher = have_db_column(:nickname).of_type(:string)
    end

    it "should accept a column of correct type" do
      create_table 'superheros' do |table|
        table.string :nickname
      end
      define_model_class 'Superhero'
      Superhero.new.should @matcher
    end

    it "should reject a nonexistent database column" do
      define_model :superhero
      Superhero.new.should_not @matcher
    end

    it "should reject a column of wrong type" do
      create_table 'superheros' do |table|
        table.integer :nickname
      end
      define_model_class 'Superhero'
      Superhero.new.should_not @matcher
    end
  end

  context "have_db_column with precision option" do
    before do
      @matcher = have_db_column(:salary).with_options(:precision => 5)
    end

    it "should accept a column of correct precision" do
      create_table 'superheros' do |table|
        table.decimal :salary, :precision => 5
      end
      define_model_class 'Superhero'
      Superhero.new.should @matcher
    end

    it "should reject a column of wrong precision" do
      create_table 'superheros' do |table|
        table.decimal :salary, :precision => 15
      end
      define_model_class 'Superhero'
      Superhero.new.should_not @matcher
    end
  end

  context "have_db_column with limit option" do
    before do
      @matcher = have_db_column(:email).
                   of_type(:string).
                   with_options(:limit => 255)
    end

    it "should accept a column of correct limit" do
      create_table 'superheros' do |table|
        table.string :email, :limit => 255
      end
      define_model_class 'Superhero'
      Superhero.new.should @matcher
    end

    it "should reject a column of wrong limit" do
      create_table 'superheros' do |table|
        table.string :email, :limit => 500
      end
      define_model_class 'Superhero'
      Superhero.new.should_not @matcher
    end
  end

  context "have_db_column with default option" do
    before do
      @matcher = have_db_column(:admin).
                   of_type(:boolean).
                   with_options(:default => false)
    end

    it "should accept a column of correct default" do
      create_table 'superheros' do |table|
        table.boolean :admin, :default => false
      end
      define_model_class 'Superhero'
      Superhero.new.should @matcher
    end

    it "should reject a column of wrong default" do
      create_table 'superheros' do |table|
        table.boolean :admin, :default => true
      end
      define_model_class 'Superhero'
      Superhero.new.should_not @matcher
    end
  end

  context "have_db_column with null option" do
    before do
      @matcher = have_db_column(:admin).
                   of_type(:boolean).
                   with_options(:null => false)
    end

    it "should accept a column of correct null" do
      create_table 'superheros' do |table|
        table.boolean :admin, :null => false
      end
      define_model_class 'Superhero'
      Superhero.new.should @matcher
    end

    it "should reject a column of wrong null" do
      create_table 'superheros' do |table|
        table.boolean :admin, :null => true
      end
      define_model_class 'Superhero'
      Superhero.new.should_not @matcher
    end
  end

  context "have_db_column with scale option" do
    before do
      @matcher = have_db_column(:salary).
                   of_type(:decimal).
                   with_options(:scale => 2)
    end

    it "should accept a column of correct scale" do
      create_table 'superheros' do |table|
        table.decimal :salary, :precision => 10, :scale => 2
      end
      define_model_class 'Superhero'
      Superhero.new.should @matcher
    end

    it "should reject a column of wrong scale" do
      create_table 'superheros' do |table|
        table.decimal :salary, :precision => 10, :scale => 4
      end
      define_model_class 'Superhero'
      Superhero.new.should_not @matcher
    end
  end

end
