require 'fileutils'
# Load the environment
ENV['RAILS_ENV'] = 'sqlite3'

# ln rails_root/vendor/plugins/shoulda => ../../../../
rails_root = File.dirname(__FILE__) + '/rails_root'

FileUtils.ln_s('../../../../', "#{rails_root}/vendor/plugins/shoulda") unless File.exists?("#{rails_root}/vendor/plugins/shoulda")

require "#{rails_root}/config/environment.rb"
 
# Load the testing framework
require 'test_help'
silence_warnings { RAILS_ENV = ENV['RAILS_ENV'] }
 
# Run the migrations
ActiveRecord::Migration.verbose = false
ActiveRecord::Migrator.migrate("#{RAILS_ROOT}/db/migrate")
 
# Setup the fixtures path
Test::Unit::TestCase.fixture_path = File.join(File.dirname(__FILE__), "fixtures")
# $LOAD_PATH.unshift(Test::Unit::TestCase.fixture_path)

class Test::Unit::TestCase #:nodoc:
  def create_fixtures(*table_names)
    if block_given?
      Fixtures.create_fixtures(Test::Unit::TestCase.fixture_path, table_names) { yield }
    else
      Fixtures.create_fixtures(Test::Unit::TestCase.fixture_path, table_names)
    end
  end
 
  self.use_transactional_fixtures = false
  self.use_instantiated_fixtures  = false
end
