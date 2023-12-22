require 'bundler/inline'

gemfile(true) do
  source 'https://rubygems.org'
  gem 'shoulda-matchers'
  gem 'activerecord'
  gem 'sqlite3'
  gem 'rspec'
end

require 'active_record'
require 'shoulda-matchers'
require 'logger'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
ActiveRecord::Base.logger = Logger.new(STDOUT)

# TODO: Update the schema to include the specific tables or columns necessary
# to reproduct the bug
ActiveRecord::Schema.define do
  create_table :posts, force: true do |t|
    t.string :body
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec

    with.library :active_record
    with.library :active_model
  end
end

RSpec.configure do |config|
  config.include Shoulda::Matchers::ActiveRecord
  config.include Shoulda::Matchers::ActiveModel
  config.include Shoulda::Matchers::ActionController
end

# TODO: Add any application specific code necessary to reproduce the bug
class Post < ActiveRecord::Base
  validates :body, uniqueness: true
end

# TODO: Write a failing test case to demonstrate what isn't working as
# expected
RSpec.describe Post do
  describe 'validations' do
    it { is_expected.to validate_uniqueness_of(:body) }
  end
end
