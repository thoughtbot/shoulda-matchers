class User < ActiveRecord::Base
  has_many :posts
  has_many :dogs, :foreign_key => :owner_id

  has_one :address, :as => :addressable
  
  attr_protected :password
  attr_readonly :name

  validates_format_of :email, :with => /\w*@\w*.com/
  validates_length_of :email, :in => 1..100
  validates_inclusion_of :age, :in => 1..100
  validates_acceptance_of :eula
  validates_uniqueness_of :email, :scope => :name
  validates_length_of :ssn, :is => 9, :message => "Social Security Number is not the right length"
  validates_numericality_of :ssn
end
