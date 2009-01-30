require File.dirname(__FILE__) + '/../test_helper'

class PostTest < Test::Unit::TestCase
  fixtures :all

  should_belong_to :user
  should_belong_to :owner
  should_have_many :tags, :through => :taggings
  should_have_many :through_tags, :through => :taggings

  should_require_unique_attributes :title
  should_validate_presence_of :body, :message => /wtf/
  should_validate_presence_of :title
  should_validate_numericality_of :user_id

  should_fail do
    should_validate_uniqueness_of :title, :case_sensitive => false
  end
end
