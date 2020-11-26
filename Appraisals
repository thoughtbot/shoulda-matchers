# Note: All of the dependencies here were obtained by running `rails new` with
# various versions of Rails and copying lines from the generated Gemfile. It's
# best to keep the gems here in the same order as they're listed there so you
# can compare them more easily.

shared_spring_dependencies = proc do
  gem 'spring'
  gem 'spring-commands-rspec'
end

shared_test_dependencies = proc do
  # Needed for Rails 5+ controller tests
  gem 'rails-controller-testing', '>= 1.0.1'
  gem 'rspec-rails', '~> 4.0'
  gem 'shoulda-context', '~> 2.0'
end

shared_dependencies = proc do
  instance_eval(&shared_spring_dependencies)
  instance_eval(&shared_test_dependencies)
end

appraise 'rails_5_0' do
  instance_eval(&shared_dependencies)

  gem 'rails', '5.0.7.2'
  gem 'puma', '~> 5.0'
  gem 'sass-rails', '~> 6.0'
  gem 'jquery-rails'
  gem 'turbolinks', '~> 5'
  gem 'jbuilder', '~> 2.10'
  gem 'bcrypt', '~> 3.1.16'
  gem 'listen', '~> 3.3'
  gem 'spring-watcher-listen', '~> 2.0.0'

  # Database adapters
  gem 'pg', '~> 0.18'
  gem 'sqlite3', '~> 1.3.6'
end

appraise 'rails_5_1' do
  instance_eval(&shared_dependencies)

  gem 'rails', '5.1.7'
  gem 'puma', '~> 5.0'
  gem 'sass-rails', '~> 6.0'
  gem 'turbolinks', '~> 5.2'
  gem 'jbuilder', '~> 2.10'
  gem 'bcrypt', '~> 3.1.16'
  gem 'capybara', '~> 3.33'
  gem 'selenium-webdriver'
  gem 'listen', '~> 3.3'
  gem 'spring-watcher-listen', '~> 2.0.0'

  # Database adapters
  gem 'pg', '~> 0.18'
  gem 'sqlite3', '~> 1.4'
end

appraise 'rails_5_2' do
  instance_eval(&shared_dependencies)

  gem 'rails', '5.2.4.1'
  gem 'puma', '~> 5.0'
  gem 'bootsnap', '>= 1.5.0', require: false
  gem 'sass-rails', '~> 6.0'
  gem 'turbolinks', '~> 5.2'
  gem 'jbuilder', '~> 2.10'
  gem 'bcrypt', '~> 3.1.16'
  gem 'capybara', '~> 3.33'
  gem 'selenium-webdriver'
  gem 'chromedriver-helper'
  gem 'listen', '~> 3.3'
  gem 'spring-watcher-listen', '~> 2.0.0'

  # Database adapters
  gem 'pg', '>= 0.18', '< 2.0'
  gem 'sqlite3', '~> 1.4'
end

appraise 'rails_6_0' do
  instance_eval(&shared_dependencies)

  gem 'rails', '6.0.3.4'
  gem 'puma', '~> 5.0'
  gem 'bootsnap', '>= 1.5.0', require: false
  gem 'sass-rails', '>= 6'
  gem 'turbolinks', '~> 5.2'
  gem 'jbuilder', '~> 2.10'
  gem 'bcrypt', '~> 3.1.16'
  gem 'capybara', '>= 3.33'
  gem 'listen', '~> 3.3'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'selenium-webdriver'
  gem 'webdrivers'

  # Database adapters
  gem 'pg', '>= 0.18', '< 2.0'
  gem 'sqlite3', '~> 1.4'
end
