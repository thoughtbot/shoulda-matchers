class Post < ActiveRecord::Base
  belongs_to :user
  has_many :taggings
  has_many :tags, :through => :taggings
  
  validates_uniqueness_of :title
  validates_presence_of :title
  validates_presence_of :body, :message => 'Seriously...  wtf'
  validates_numericality_of :user_id
end
