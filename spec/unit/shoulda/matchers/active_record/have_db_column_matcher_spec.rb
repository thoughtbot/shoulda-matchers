require 'unit_spec_helper'

describe Shoulda::Matchers::ActiveRecord::HaveDbColumnMatcher, type: :model do
  it 'accepts an existing database column' do
    expect(model(nickname: :string)).to have_db_column(:nickname)
  end

  it 'rejects a nonexistent database column' do
    expect(define_model(:employee).new).not_to have_db_column(:nickname)
  end

  context '#of_type' do
    it 'accepts a column of correct type' do
      expect(model(nickname: :string)).
        to have_db_column(:nickname).of_type(:string)
    end

    it 'rejects a nonexistent database column' do
      expect(define_model(:superhero).new).
        not_to have_db_column(:nickname).of_type(:string)
    end

    it 'rejects a column of wrong type' do
      expect(model(nickname: :integer)).
        not_to have_db_column(:nickname).of_type(:string)
    end
  end

  context '#of_sql_type' do
    it 'accepts a column of correct type' do
      sql_column_type = postgresql? ? 'character varying(36)' : 'varchar(36)'
      expect(with_table(:nickname, :string, limit: 36)).
        to have_db_column(:nickname).of_sql_type(sql_column_type)
    end

    it 'rejects a nonexistent database column' do
      sql_column_type = postgresql? ? 'character varying(36)' : 'varchar(36)'
      assertion = lambda do
        expect(with_table(:nickname, :string, limit: 36)).
          to have_db_column(:superhero).of_sql_type(sql_column_type)
      end

      message = <<-MESSAGE
        Expected Employee to have db column named superhero of sql_type #{sql_column_type} (Employee does not have a db column named superhero.)
      MESSAGE

      expect(&assertion).to fail_with_message(message)
    end

    it 'rejects a column of wrong sql type' do
      sql_column_type = postgresql? ? 'character varying(36)' : 'varchar(36)'
      assertion = lambda do
        expect(with_table(:nickname, :string, limit: 36)).
          to have_db_column(:nickname).of_sql_type('varchar')
      end

      message = <<-MESSAGE
        Expected Employee to have db column named nickname of sql_type varchar (Employee has a db column named nickname of sql type #{sql_column_type}, not varchar.)
      MESSAGE

      expect(&assertion).to fail_with_message(message)
    end
  end

  context 'with precision option' do
    it 'accepts a column of correct precision' do
      expect(with_table(:salary, :decimal, precision: 5)).
        to have_db_column(:salary).with_options(precision: 5)
    end

    it 'rejects a column of wrong precision' do
      expect(with_table(:salary, :decimal, precision: 6)).
        not_to have_db_column(:salary).with_options(precision: 5)
    end
  end

  context 'with limit option' do
    it 'accepts a column of correct limit' do
      expect(with_table(:email, :string, limit: 255)).
        to have_db_column(:email).with_options(limit: 255)
    end

    it 'rejects a column of wrong limit' do
      expect(with_table(:email, :string, limit: 100)).
        not_to have_db_column(:email).with_options(limit: 255)
    end
  end

  context 'with default option' do
    it 'accepts a column with correct default' do
      expect(with_table(:admin, :boolean, default: false)).
        to have_db_column(:admin).with_options(default: false)
    end

    it 'rejects a column with wrong default' do
      expect(with_table(:admin, :boolean, default: true)).
        not_to have_db_column(:admin).with_options(default: false)
    end
  end

  context 'with null option' do
    it 'accepts a column of correct null' do
      expect(with_table(:admin, :boolean, null: false)).
        to have_db_column(:admin).with_options(null: false)
    end

    it 'rejects a column of wrong null' do
      expect(with_table(:admin, :boolean, null: true)).
        not_to have_db_column(:admin).with_options(null: false)
    end
  end

  context 'with scale option' do
    it 'accepts a column of correct scale' do
      expect(with_table(:salary, :decimal, precision: 10, scale: 2)).
        to have_db_column(:salary).with_options(scale: 2)
    end

    it 'rejects a column of wrong scale' do
      expect(with_table(:salary, :decimal, precision: 10, scale: 4)).
        not_to have_db_column(:salary).with_options(scale: 2)
    end
  end

  context 'with primary option' do
    it 'accepts a column that is primary' do
      expect(with_table(:custom_id, :integer, primary: true)).
        to have_db_column(:id).with_options(primary: true)
    end

    it 'rejects a column that is not primary' do
      expect(with_table(:whatever, :integer, primary: false)).
        not_to have_db_column(:whatever).with_options(primary: true)
    end
  end

  if database_supports_array_columns?
    context 'with array option' do
      it 'accepts a column that is array' do
        expect(with_table(:tags, :string, array: true)).
          to have_db_column(:tags).with_options(array: true)
      end

      it 'rejects a column that is not array' do
        expect(with_table(:whatever, :string, array: false)).
          not_to have_db_column(:whatever).with_options(array: true)
      end
    end
  end

  context 'with invalid argument option' do
    it 'raises an error with the unknown options' do
      expect {
        have_db_column(:salary).with_options(preccision: 5, primaryy: true)
      }.to raise_error('Unknown option(s): :preccision, :primaryy')
    end
  end

  def model(options = {})
    define_model(:employee, options).new
  end

  def with_table(column_name, column_type, options)
    create_table 'employees' do |table|
      table.__send__(column_type, column_name, **options)
    end
    define_model_class('Employee').new
  end
end
