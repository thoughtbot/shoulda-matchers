shared_dependencies = proc do
  gem 'rspec-rails', '~> 3.6'
  gem 'shoulda-context', '~> 1.2.0'
  gem 'sqlite3', platform: :ruby
  gem 'pg', platform: :ruby
  gem 'activerecord-jdbc-adapter', platform: :jruby
  gem 'activerecord-jdbcsqlite3-adapter', platform: :jruby
  gem 'jdbc-sqlite3', platform: :jruby
  gem 'jruby-openssl', platform: :jruby
  gem 'therubyrhino', platform: :jruby
end

spring = proc do
  gem 'spring'
  gem 'spring-commands-rspec'
end

appraise '4.2' do
  instance_eval(&shared_dependencies)
  instance_eval(&spring)
  gem 'uglifier', '>= 1.3.0'
  gem 'jquery-rails'
  gem 'turbolinks', '2.5.3'
  gem 'sdoc'
  gem 'json', '~> 1.4'
  gem 'activeresource', '4.0.0'
  gem 'protected_attributes'
  gem 'minitest-reporters'
  gem 'rails', '~> 4.2.9'
  gem 'sass-rails', '~> 5.0'
  gem 'coffee-rails', '~> 4.1.0'
  gem 'jbuilder', '~> 2.0'
  gem 'nokogiri', '~> 1.8'
  gem 'bcrypt', '~> 3.1.7'
  gem 'protected_attributes', "~> 1.0.6"
end

appraise '5.0' do
  instance_eval(&shared_dependencies)
  instance_eval(&spring)
  gem 'rails', '~> 5.0.4'
  gem 'rails-controller-testing', '>= 1.0.1'
  gem 'puma', '~> 3.0'
  gem 'sass-rails', '~> 5.0'
  gem 'jquery-rails'
  gem 'turbolinks', '~> 5'
  gem 'jbuilder', '~> 2.5'
  gem 'bcrypt', '~> 3.1.7'
  gem 'listen', '~> 3.0.5'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'nokogiri', '~> 1.8'
  gem 'minitest-reporters'
end
