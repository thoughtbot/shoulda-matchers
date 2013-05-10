if RUBY_VERSION < '2.0'
  appraise '3.0' do
    gem 'rails', '~> 3.0.17'
    gem 'strong_parameters'
  end

  appraise '3.1' do
    gem 'rails', '~> 3.1.8'
    gem 'jquery-rails'
    gem 'sass-rails'
    gem 'strong_parameters'
  end
end

appraise '3.2' do
  gem 'rails', '~> 3.2.13'
  gem 'jquery-rails'
  gem 'sass-rails'
  gem 'strong_parameters'
end

appraise '4.0' do
  gem 'rails', '4.0.0.rc1'
  gem 'jquery-rails'
  gem 'sass-rails', '~> 4.0.0.rc1'

  # Test suite makes heavy use of attr_accessible
  gem 'protected_attributes'
end
