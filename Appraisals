# Note: All of the dependencies here were obtained by running `rails new` with
# various versions of Rails and copying lines from the generated Gemfile. It's
# best to keep the gems here in the same order as they're listed there so you
# can compare them more easily.

# Needed for Rails 5+ controller tests
controller_test_dependency = proc do
  gem 'rails-controller-testing', '>= 1.0.1'
end

shared_spring_dependencies = proc do
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

appraise 'rails_6_1' do
  instance_eval(&shared_spring_dependencies)
  instance_eval(&controller_test_dependency)

  gem 'rails', '6.1.7.2'
  gem 'puma', '~> 5.0'
  gem 'sass-rails', '>= 6'
  gem 'turbolinks', '~> 5'
  gem 'jbuilder', '~> 2.7'
  gem 'bcrypt', '~> 3.1.7'
  gem 'bootsnap', '>= 1.4.4', require: false
  gem 'rack-mini-profiler', '~> 2.0.0'
  gem 'listen', '~> 3.3'
  gem 'capybara', '>= 3.26'
  gem 'selenium-webdriver', '>= 4.0.0.rc1'
  gem 'webdrivers'
  gem 'net-smtp', require: false
  gem 'psych', '~> 3.0'

  # test dependencies
  gem 'rspec-rails', '~> 6.0'
  gem 'shoulda-context', '~> 2.0.0'

  # Database adapters
  gem 'pg', '>= 0.18', '< 2.0'
  gem 'sqlite3', '~> 1.4'
end

appraise 'rails_7_0' do
  instance_eval(&shared_spring_dependencies)
  instance_eval(&controller_test_dependency)

  gem 'rails', '7.0.4.2'
  gem 'sprockets-rails'
  gem 'puma', '~> 5.0'
  gem 'importmap-rails'
  gem 'turbo-rails'
  gem 'stimulus-rails'
  gem 'jbuilder'
  gem 'bootsnap', require: false
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'webdrivers'

  # test dependencies
  gem 'rspec-rails', '~> 6.0'
  gem 'shoulda-context', '~> 2.0.0'

  # other dependencies
  gem 'bcrypt', '~> 3.1.7'

  # Database adapters
  gem 'sqlite3', '~> 1.4'
  gem 'pg', '~> 1.1'
end
