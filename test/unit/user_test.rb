require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
  load_all_fixtures

  should_have_many :posts
  should_have_many :dogs

  should_not_allow_values_for :email, "blah", "b lah"
  should_allow_values_for :email, "a@b.com", "asdf@asdf.com"
  should_ensure_length_in_range :email, 1..100
  should_ensure_value_in_range :age, 1..100
  should_protect_attributes :password
  should_have_class_methods :find, :destroy
  should_have_instance_methods :email, :age, :email=, :valid?
  should_have_db_columns :name, :email, :age
  should_have_db_column :id, :type => "integer", :primary => true
  should_have_db_column :email, :type => "string", :default => nil,   :precision => nil, :limit    => 255, 
                                :null => true,     :primary => false, :scale     => nil, :sql_type => 'varchar(255)'
  should_require_acceptance_of :eula
end
