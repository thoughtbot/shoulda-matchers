class Product < ActiveRecord::Base
  validates_presence_of :title, :price
  validates_inclusion_of :price, :in => 0..99, :unless => :tangible

  validates_inclusion_of :price, :in => 1..9999, :if => :tangible
  validates_inclusion_of :weight, :in => 1..100, :if => :tangible
  validates_format_of :size, :with => /.+x.+x.+/, :if => :tangible
  validates_length_of :size, :in => 5..20, :if => :tangible
end
