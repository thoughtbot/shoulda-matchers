require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
  fixtures :all

  should_have_many :posts
  should_have_many :dogs

  should_have_many :friendships
  should_have_many :friends

  should_have_one :address
  should_have_one :address, :dependent => :destroy

  should_have_indices :email, :name
  should_have_index :age
  should_have_index [:email, :name], :unique => true
  should_have_index :age, :unique => false

  should_fail do
    should_have_index :phone
    should_have_index :email, :unique => false
    should_have_index :age, :unique => true
  end

  should_have_named_scope :old,       :conditions => "age > 50"
  should_have_named_scope :eighteen,  :conditions => { :age => 18 }

  should_have_named_scope 'recent(5)',            :limit => 5
  should_have_named_scope 'recent(1)',            :limit => 1
  should_have_named_scope 'recent_via_method(7)', :limit => 7

  context "when given an instance variable" do
    setup { @count = 2 }
    should_have_named_scope 'recent(@count)', :limit => 2
  end

  should_not_allow_values_for :email, "blah", "b lah"
  should_allow_values_for :email, "a@b.com", "asdf@asdf.com"
  should_ensure_length_in_range :email, 1..100
  should_ensure_value_in_range :age, 1..100
  should_not_allow_mass_assignment_of :password
  should_have_class_methods :find, :destroy
  should_have_instance_methods :email, :age, :email=, :valid?
  should_have_db_columns :name, :email, :age
  should_have_db_column :id,    :type => "integer"
  should_have_db_column :email, :type => "string", :default => nil, :precision => nil, :limit    => 255,
                                :null => true,     :scale   => nil
  should_validate_acceptance_of :eula
  should_require_acceptance_of :eula
  should_validate_uniqueness_of :email, :scoped_to => :name, :case_sensitive => false

  should_ensure_length_is :ssn, 9, :message => "Social Security Number is not the right length"
  should_validate_numericality_of :ssn

  should_have_readonly_attributes :name

  should_fail do
    should_not_allow_mass_assignment_of :name, :age
  end
end
