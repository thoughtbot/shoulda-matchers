class User < ActiveRecord::Base
  has_many :posts
  
  attr_protected :password
  validates_format_of :email, :with => /\w*@\w*.com/
  validates_length_of :email, :in => 1..100
  validates_inclusion_of :age, :in => 1..100
end
