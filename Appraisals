ruby_version = Gem::Version.new(RUBY_VERSION + '')

spring = proc do
  gem 'spring'
  gem 'spring-commands-rspec'
end

rails_3 = proc do
  gem 'strong_parameters'
  gem 'rspec-rails', '2.99.0'
  gem 'minitest', '~> 4.0'
  gem 'minitest-reporters'
end

rails_3_1 = proc do
  instance_eval(&rails_3)
  gem 'rails', '~> 3.1.8'
  gem 'bcrypt-ruby', '~> 3.0.0'
  gem 'jquery-rails'
  gem 'sass-rails', '~> 3.1.5'
  gem 'coffee-rails', '~> 3.1.1'
  gem 'uglifier', '>= 1.0.3'
  gem 'rspec-rails', '2.99.0'
  gem 'minitest', '~> 4.0'
  gem 'minitest-reporters'
end

rails_3_2 = proc do
  instance_eval(&rails_3)
  gem 'rails', '~> 3.2.13'
  gem 'bcrypt-ruby', '~> 3.0.0'
  gem 'jquery-rails'
  gem 'sass-rails', '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
  gem 'minitest', '~> 4.0'
  gem 'minitest-reporters'
end

rails_4 = proc do
  instance_eval(&spring)
  gem 'uglifier', '>= 1.3.0'
  gem 'coffee-rails', '~> 4.0.0'
  gem 'jquery-rails'
  gem 'turbolinks'
  gem 'sdoc'
  gem 'activeresource', '4.0.0'
  gem 'rspec-rails', '~> 3.0.1'
  # Test suite makes heavy use of attr_accessible
  gem 'protected_attributes'
  gem 'minitest-reporters'
end

#---

if Gem::Requirement.new('< 2').satisfied_by?(ruby_version)
  appraise '3.0' do
    instance_eval(&rails_3)
    gem 'rails', '~> 3.0.17'
  end

  if Gem::Requirement.new('= 1.9.2').satisfied_by?(ruby_version)
    appraise '3.1-1.9.2' do
      instance_eval(&rails_3_1)
      gem 'turn', '0.8.2'
    end
  else
    appraise '3.1' do
      instance_eval(&rails_3_1)
      gem 'turn', '~> 0.8.3'
    end
  end
end

if Gem::Requirement.new('= 1.9.2').satisfied_by?(ruby_version)
  appraise '3.2-1.9.2' do
    instance_eval(&rails_3_2)
  end
else
  appraise '3.2' do
    instance_eval(&rails_3_2)
    instance_eval(&spring)
  end
end

if Gem::Requirement.new('> 1.9.2').satisfied_by?(ruby_version)
  appraise '4.0.0' do
    instance_eval(&rails_4)
    gem 'rails', '4.0.0'
    gem 'jbuilder', '~> 1.2'
    gem 'sass-rails', '~> 4.0.0'
    gem 'bcrypt-ruby', '~> 3.0.0'
  end

  appraise '4.0.1' do
    instance_eval(&rails_4)
    gem 'rails', '4.0.1'
    gem 'jbuilder', '~> 1.2'
    gem 'sass-rails', '~> 4.0.0'
    gem 'bcrypt-ruby', '~> 3.1.2'
    gem 'rspec-rails', '2.99.0'
  end

  appraise '4.1' do
    instance_eval(&rails_4)
    gem 'rails', '~> 4.1.0'
    gem 'jbuilder', '~> 2.0'
    gem 'sass-rails', '~> 4.0.3'
    gem 'sdoc', '~> 0.4.0'
    gem 'bcrypt', '~> 3.1.7'
    gem 'protected_attributes', "~> 1.0.6"
    gem 'spring'
  end

  appraise '4.2' do
    instance_eval(&rails_4)
    gem 'rails', '~> 4.2.0'
    gem 'sass-rails', '~> 5.0'
    gem 'coffee-rails', '~> 4.1.0'
    gem 'jbuilder', '~> 2.0'
    gem 'sdoc', '~> 0.4.0'
    gem 'bcrypt', '~> 3.1.7'
    gem 'byebug'
    gem 'web-console', '~> 2.0'
    gem 'spring'
    gem 'protected_attributes', "~> 1.0.6"
  end
end
