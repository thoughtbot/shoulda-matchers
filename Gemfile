source 'https://rubygems.org'

gemspec

# For test Rails application
gem 'shoulda-context', '~> 1.0.0'
gem 'sqlite3', :platform => :ruby
gem 'bcrypt-ruby'

# Can't wrap in platform :jruby do...end block because appraisal doesn't support
# it
gem 'activerecord-jdbc-adapter',        :platform => :jruby
gem 'activerecord-jdbcsqlite3-adapter', :platform => :jruby
gem 'jdbc-sqlite3',                     :platform => :jruby
gem 'jruby-openssl',                    :platform => :jruby
gem 'therubyrhino',                     :platform => :jruby
