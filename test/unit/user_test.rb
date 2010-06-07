require 'test_helper'

class UserTest < ActiveSupport::TestCase
  fixtures :all

  should_have_many :posts
  should_have_many :dogs
  should_have_many :cats

  should_have_many :friendships
  should_have_many :friends

  should_have_one :address
  should_have_one :address, :dependent => :destroy

  should_have_db_indices :email, :name
  should_have_db_index :age
  should_have_db_index [:email, :name], :unique => true
  should_have_db_index :age, :unique => false

  should_not_allow_values_for :email, "blah", "b lah"
  should_allow_values_for :email, "a@b.com", "asdf@asdf.com"
  should_allow_values_for :age, 1, 10, 99
  should_not_allow_values_for :age, "a", "-"
  should_not_allow_values_for :ssn, "a", 1234567890
  should_ensure_length_in_range :email, 1..100
  should_ensure_value_in_range :age, 1..100, :low_message  => /greater/,
                                             :high_message => /less/

  should_not_allow_mass_assignment_of :password
  should_have_class_methods :find, :destroy
  should_have_instance_methods :email, :age, :email=, :valid?
  should_have_db_columns :name, :email, :age
  should_have_db_column :id,    :type => "integer"
  should_have_db_column :email, :type => "string", :default => nil, :precision => nil, :limit    => 255,
                                :null => true,     :scale   => nil
  should_validate_acceptance_of :eula
  should_validate_uniqueness_of :email, :scoped_to => :name, :case_sensitive => false

  should_ensure_length_is :ssn, 9, :message => "Social Security Number is not the right length"
  should_validate_numericality_of :ssn

  should_have_readonly_attributes :name

  should_have_one :profile, :through => :registration
end
