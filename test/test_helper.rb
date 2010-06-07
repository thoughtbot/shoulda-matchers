require 'fileutils'
require 'test/unit'

ENV['RAILS_ENV'] = 'test'

ENV['RAILS_VERSION'] ||= '2.3.8'
RAILS_GEM_VERSION = ENV['RAILS_VERSION']

if ENV['RAILS_VERSION'].to_s =~ /^2/
  require 'test/rails2_test_helper'
else
  require 'test/rails3_test_helper'
end

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

require 'test/fail_macros'

Shoulda.autoload_macros File.join(File.dirname(__FILE__), 'rails2_root'),
                        File.join("vendor", "{plugins,gems}", "*")

