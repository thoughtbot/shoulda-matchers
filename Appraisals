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
  gem 'rspec-rails', '~> 3.9'
  gem 'shoulda-context', '~> 1.2.0'
end

shared_dependencies = proc do
  instance_eval(&shared_spring_dependencies)
  instance_eval(&shared_test_dependencies)
end

appraise 'rails_4_2' do
  instance_eval(&shared_dependencies)

  gem 'rails', '4.2.11.1'
  gem 'sass-rails', '~> 5.0'
  gem 'uglifier', '>= 1.3.0'
  gem 'coffee-rails', '~> 4.1.0'
  gem 'jquery-rails'
  gem 'turbolinks'
  gem 'jbuilder', '~> 2.0'
  gem 'sdoc', '~> 0.4.0', group: :doc
  gem 'bcrypt', '~> 3.1.7'

  # Other dependencies
  gem 'activeresource', '4.0.0'
  gem 'json', '~> 1.4'
  gem 'protected_attributes', '~> 1.0.6'

  # Database adapters
  gem 'pg', '~> 0.18'
  gem 'sqlite3', '~> 1.3.6'
end

appraise 'rails_5_0' do
  instance_eval(&shared_dependencies)
  instance_eval(&controller_test_dependency)

  gem 'rails', '5.0.7.2'
  gem 'puma', '~> 3.0'
  gem 'sass-rails', '~> 5.0'
  gem 'jquery-rails'
  gem 'turbolinks', '~> 5'
  gem 'jbuilder', '~> 2.5'
  gem 'bcrypt', '~> 3.1.7'
  gem 'listen', '~> 3.0.5'
  gem 'spring-watcher-listen', '~> 2.0.0'

  # Database adapters
  gem 'pg', '~> 0.18'
  gem 'sqlite3', '~> 1.3.6'
end

appraise 'rails_5_1' do
  instance_eval(&shared_dependencies)
  instance_eval(&controller_test_dependency)

  gem 'rails', '5.1.7'
  gem 'puma', '~> 3.7'
  gem 'sass-rails', '~> 5.0'
  gem 'turbolinks', '~> 5'
  gem 'jbuilder', '~> 2.5'
  gem 'bcrypt', '~> 3.1.7'
  gem 'capybara', '~> 2.13'
  gem 'selenium-webdriver'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring-watcher-listen', '~> 2.0.0'

  # Database adapters
  gem 'pg', '~> 0.18'
  gem 'sqlite3', '~> 1.3.6'
end

appraise 'rails_5_2' do
  instance_eval(&shared_dependencies)
  instance_eval(&controller_test_dependency)

  gem 'rails', '5.2.4.1'
  gem 'puma', '~> 3.11'
  gem 'bootsnap', '>= 1.1.0', require: false
  gem 'sass-rails', '~> 5.0'
  gem 'turbolinks', '~> 5'
  gem 'jbuilder', '~> 2.5'
  gem 'bcrypt', '~> 3.1.7'
  gem 'capybara', '~> 3.1.1'
  gem 'selenium-webdriver'
  gem 'chromedriver-helper'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring-watcher-listen', '~> 2.0.0'

  # Database adapters
  gem 'pg', '~> 0.18'
  gem 'sqlite3', '~> 1.3.6'
end

if Gem::Requirement.new('>= 2.5.0').satisfied_by?(Gem::Version.new(RUBY_VERSION))
  appraise 'rails_6_0' do
    instance_eval(&shared_dependencies)
    instance_eval(&controller_test_dependency)

    gem 'rails', '6.0.2.1'
    gem 'puma', '~> 4.1'
    gem 'bootsnap', '>= 1.4.2', require: false
    gem 'sass-rails', '>= 6'
    gem 'webpacker', '~> 4.0'
    gem 'turbolinks', '~> 5'
    gem 'jbuilder', '~> 2.7'
    gem 'bcrypt', '~> 3.1.7'
    gem 'capybara', '>= 2.15'
    gem 'listen', '>= 3.0.5', '< 3.2'
    gem 'spring-watcher-listen', '~> 2.0.0'
    gem 'selenium-webdriver'
    gem 'webdrivers'

    # Other dependencies
    gem 'actiontext', '~> 6.0.2.1'

    # Database adapters
    gem 'pg', '>= 0.18', '< 2.0'
    gem 'sqlite3', '~> 1.4'
  end
end
