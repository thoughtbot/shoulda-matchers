require File.join(File.dirname(__FILE__), 'test_helper')

class Post < ActiveRecord::Base
  belongs_to :user
  validates_uniqueness_of :title
  validates_presence_of :title
  validates_presence_of :body, :message => 'Seriously...  wtf'
  validates_numericality_of :user_id
end

class User < ActiveRecord::Base
  has_many :posts
  has_many :taggings
  has_many :tags, :through => :taggings
  attr_protected :password
  validates_format_of :email, :with => /\w*@\w*.com/
  validates_length_of :email, :in => 1..100
  validates_inclusion_of :age, :in => 1..100
end

class Tag < ActiveRecord::Base
  has_many :taggings
  has_many :users, :through => :taggings
end

class Tagging < ActiveRecord::Base
	belongs_to :user
	belongs_to :tag
end

class PostTest < Test::Unit::TestCase # :nodoc:
  fixtures :posts
  
  should_belong_to :user
  should_require_unique_attributes :title
  
  should_require_attributes :body, :message => /wtf/
  should_require_attributes :title
  should_only_allow_numeric_values_for :user_id
end

class UserTest < Test::Unit::TestCase # :nodoc:
  fixtures :users
  
  should_have_many :posts
  should_have_many :taggings
  should_have_many :tags, :through => :taggings
  
  should_not_allow_values_for :email, "blah", "b lah"
  should_allow_values_for :email, "a@b.com", "asdf@asdf.com"
  should_ensure_length_in_range :email, 1..100
  should_ensure_value_in_range :age, 1..100
  should_protect_attributes :password
end