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
  gem 'spring-commands-rspec'
end

shared_test_dependencies = proc do
  gem 'rspec-rails', '~> 4.0'
  gem 'shoulda-context', '~> 1.2.0'
end

shared_dependencies = proc do
  instance_eval(&shared_spring_dependencies)
  instance_eval(&shared_test_dependencies)
end

appraise 'rails_5_2' do
  instance_eval(&shared_dependencies)
  instance_eval(&controller_test_dependency)

  gem 'rails', '5.2.6'
  gem 'puma', '~> 3.11'
  gem 'bootsnap', '>= 1.1.0', require: false
  gem 'sass-rails', '~> 5.0'
  gem 'turbolinks', '~> 5'
  gem 'jbuilder', '~> 2.5'
  gem 'bcrypt', '~> 3.1.7'
  gem 'capybara', '~> 3.1.1'
  gem 'selenium-webdriver'
  gem 'chromedriver-helper'
  gem 'listen', '~> 3.0.5'
  gem 'spring-watcher-listen', '~> 2.0.0'

  # Database adapters
  gem 'pg', '~> 0.18'
  gem 'sqlite3', '~> 1.4'
end

appraise 'rails_6_0' do
  instance_eval(&shared_dependencies)
  instance_eval(&controller_test_dependency)

  gem 'rails', '6.0.4.4'
  gem 'puma', '~> 4.1'
  gem 'bootsnap', '>= 1.4.2', require: false
  gem 'sass-rails', '>= 6'
  gem 'turbolinks', '~> 5'
  gem 'jbuilder', '~> 2.7'
  gem 'bcrypt', '~> 3.1.7'
  gem 'capybara', '>= 2.15'
  gem 'listen', '~> 3.3.0'
  gem 'psych', '~> 3.0'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'selenium-webdriver'
  gem 'webdrivers'
  gem 'net-smtp', require: false

  # Database adapters
  gem 'pg', '>= 0.18', '< 2.0'
  gem 'sqlite3', '~> 1.4'
end

appraise 'rails_6_1' do
  instance_eval(&shared_dependencies)
  instance_eval(&controller_test_dependency)

  gem 'rails', '6.1.4.4'
  gem 'puma', '~> 5.0'
  gem 'bootsnap', '>= 1.4.2', require: false
  gem 'sass-rails', '>= 6'
  gem 'turbolinks', '~> 5'
  gem 'jbuilder', '~> 2.7'
  gem 'bcrypt', '~> 3.1.7'
  gem 'capybara', '>= 2.15'
  gem 'listen', '>= 3.0.5', '< 3.6'
  gem 'net-smtp', require: false
  gem 'psych', '~> 3.0'
  gem 'rack-mini-profiler', '~> 2.0.0'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'selenium-webdriver'
  gem 'webdrivers'

  # Database adapters
  gem 'pg', '>= 0.18', '< 2.0'
  gem 'sqlite3', '~> 1.4'
end

appraise 'rails_7_0' do
  instance_eval(&shared_spring_dependencies)
  instance_eval(&shared_test_dependencies)

  gem 'rails', '~> 7.0.1'
  gem 'sprockets-rails'
  gem 'puma', '~> 5.0'
  gem 'importmap-rails'
  gem 'turbo-rails'
  gem 'stimulus-rails'
  gem 'jbuilder'
  gem 'redis', '~> 4.0'
  gem "capybara"
  gem "selenium-webdriver"
  gem "webdrivers"

  # other dependencies
  gem 'bcrypt', '~> 3.1.7'
  gem 'rails-controller-testing'

  # Database adapters
  gem 'sqlite3', '~> 1.4'
  gem 'pg', '~> 1.1'
end
