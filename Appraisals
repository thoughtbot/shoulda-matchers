rails_4_0 = proc do
  gem 'jquery-rails'
  gem 'activeresource', '4.0.0'
  # Test suite makes heavy use of attr_accessible
  gem 'protected_attributes'
end

#---

if RUBY_VERSION < '2.0'
  appraise '3.0' do
    gem 'rails', '~> 3.0.17'
    gem 'strong_parameters'
  end

  appraise '3.1' do
    gem 'rails', '~> 3.1.8'
    gem 'bcrypt-ruby', '~> 3.0.0'
    gem 'jquery-rails'
    gem 'sass-rails'
    gem 'strong_parameters'
  end
end

appraise '3.2' do
  gem 'rails', '~> 3.2.13'
  gem 'bcrypt-ruby', '~> 3.0.0'
  gem 'jquery-rails'
  gem 'sass-rails'
  gem 'strong_parameters'
end

appraise '4.0.0' do
  instance_eval(&rails_4_0)
  gem 'rails', '4.0.0'
  gem 'sass-rails', '4.0.0'
  gem 'bcrypt-ruby', '~> 3.0.0'
end

appraise '4.0.1' do
  instance_eval(&rails_4_0)
  gem 'rails', '4.0.1'
  gem 'sass-rails', '4.0.1'
  gem 'bcrypt-ruby', '~> 3.1.2'
end

appraise '4.1' do
  instance_eval(&rails_4_0)
  gem 'rails', '~> 4.1.0'
  gem 'sass-rails', '4.0.3'
  gem 'bcrypt-ruby', '~> 3.1.2'
  gem "protected_attributes", '~> 1.0.6'
end
