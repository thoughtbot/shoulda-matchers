module Pets
  class Cat < ActiveRecord::Base
    belongs_to :owner, :class_name => 'User'
    belongs_to :address, :dependent => :destroy
    validates_presence_of :owner_id
  end
end
