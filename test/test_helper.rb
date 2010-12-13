require 'fileutils'
require 'test/unit'

ENV['RAILS_ENV'] = 'test'

ENV['RAILS_VERSION'] ||= '3.0.0.beta4'
RAILS_GEM_VERSION = ENV['RAILS_VERSION']

rails_root = File.dirname(__FILE__) + '/rails3_root'
ENV['BUNDLE_GEMFILE'] = rails_root + '/Gemfile'
require "#{rails_root}/config/environment.rb"
require 'test/rails3_model_builder'
require 'rails/test_help'

shoulda_path = File.join(File.dirname(__FILE__), '..', 'lib')
$LOAD_PATH << shoulda_path
require 'shoulda'

# Run the migrations
ActiveRecord::Migration.verbose = false
ActiveRecord::Migrator.migrate("#{Rails.root}/db/migrate")

# Setup the fixtures path
ActiveSupport::TestCase.fixture_path =
  File.join(File.dirname(__FILE__), "fixtures")

class ActiveSupport::TestCase #:nodoc:
  self.use_transactional_fixtures = false
  self.use_instantiated_fixtures  = false
end

Shoulda.autoload_macros File.join(File.dirname(__FILE__), 'rails3_root'),
                        File.join("vendor", "{plugins,gems}", "*")

