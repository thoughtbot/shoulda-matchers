BASE = File.dirname(__FILE__)
$LOAD_PATH << File.join(BASE, '..', 'lib')

require 'rubygems'
require 'test/unit' 
require 'active_support'
require 'active_record'
require 'active_record/fixtures'
require 'shoulda'

config = YAML::load(IO.read(File.join(BASE, "support", 'database.yml')))
ActiveRecord::Base.logger = Logger.new(File.join(BASE, "support", "debug.log"))
ActiveRecord::Base.establish_connection(config['sqlite3'])
ActiveRecord::Migration.verbose = false

load(File.join(BASE, "support", "schema.rb"))

Test::Unit::TestCase.fixture_path = File.join(BASE, "support", "fixtures")

class Test::Unit::TestCase #:nodoc:
	def self.fixtures(*args)
		Fixtures.create_fixtures(Test::Unit::TestCase.fixture_path, args)
	end

  self.use_transactional_fixtures = false
  self.use_instantiated_fixtures  = false
end

