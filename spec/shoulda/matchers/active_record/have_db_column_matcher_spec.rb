require 'spec_helper'

describe Shoulda::Matchers::ActiveRecord::HaveDbColumnMatcher do
  it 'accepts an existing database column' do
    model(:nickname => :string).should have_db_column(:nickname)
  end

  it 'rejects a nonexistent database column' do
    define_model(:employee).new.should_not have_db_column(:nickname)
  end

  context '#of_type' do
    it 'accepts a column of correct type' do
      model(:nickname => :string).
        should have_db_column(:nickname).of_type(:string)
    end

    it 'rejects a nonexistent database column' do
      define_model(:superhero).new.
        should_not have_db_column(:nickname).of_type(:string)
    end

    it 'rejects a column of wrong type' do
      model(:nickname => :integer).
        should_not have_db_column(:nickname).of_type(:string)
    end
  end

  context 'with precision option' do
    it 'accepts a column of correct precision' do
      with_table(:salary, :decimal, :precision => 5).
        should have_db_column(:salary).with_options(:precision => 5)
    end

    it 'rejects a column of wrong precision' do
      with_table(:salary, :decimal, :precision => 6).
        should_not have_db_column(:salary).with_options(:precision => 5)
    end
  end

  context 'with limit option' do
    it 'accepts a column of correct limit' do
      with_table(:email, :string, :limit => 255).
        should have_db_column(:email).with_options(:limit => 255)
    end

    it 'rejects a column of wrong limit' do
      with_table(:email, :string, :limit => 100).
        should_not have_db_column(:email).with_options(:limit => 255)
    end
  end

  context 'with default option' do
    it 'accepts a column with correct default' do
      with_table(:admin, :boolean, :default => false).
        should have_db_column(:admin).with_options(:default => false)
    end

    it 'rejects a column with wrong default' do
      with_table(:admin, :boolean, :default => true).
        should_not have_db_column(:admin).with_options(:default => false)
    end
  end

  context 'with null option' do
    it 'accepts a column of correct null' do
      with_table(:admin, :boolean, :null => false).
        should have_db_column(:admin).with_options(:null => false)
    end

    it 'rejects a column of wrong null' do
      with_table(:admin, :boolean, :null => true).
        should_not have_db_column(:admin).with_options(:null => false)
    end
  end

  context 'with scale option' do
    it 'accepts a column of correct scale' do
      with_table(:salary, :decimal, :precision => 10, :scale => 2).
        should have_db_column(:salary).with_options(:scale => 2)
    end

    it 'rejects a column of wrong scale' do
      with_table(:salary, :decimal, :precision => 10, :scale => 4).
        should_not have_db_column(:salary).with_options(:scale => 2)
    end
  end

  context 'with primary option' do
    it 'accepts a column that is primary' do
      with_table(:id, :integer, :primary => true).
        should have_db_column(:id).with_options(:primary => true)
    end

    it 'rejects a column that is not primary' do
      with_table(:whatever, :integer, :primary => false).
        should_not have_db_column(:whatever).with_options(:primary => true)
    end
  end

  def model(options = {})
    define_model(:employee, options).new
  end

  def with_table(column_name, column_type, options)
    create_table 'employees' do |table|
      table.send(column_type, column_name, options)
    end
    define_model_class('Employee').new
  end
end
