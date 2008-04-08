class Dog < ActiveRecord::Base
  belongs_to :user, :foreign_key => :owner_id
  has_and_belongs_to_many :fleas
end
