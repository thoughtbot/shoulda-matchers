class Address < ActiveRecord::Base
  belongs_to :addressable, :polymorphic => true
  validates_uniqueness_of :title, :scope => [:addressable_type, :addressable_id]
end
