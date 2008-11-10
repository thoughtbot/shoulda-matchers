module Pets
  class Dog < ActiveRecord::Base
    belongs_to :user, :foreign_key => :owner_id
    belongs_to :address, :dependent => :destroy
    has_many :treats
    has_and_belongs_to_many :fleas, :join_table => :fleas
    validates_presence_of :treats, :fleas
    validates_presence_of :owner_id
  end
end
