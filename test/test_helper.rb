BASE = File.dirname(__FILE__)
$LOAD_PATH << File.join(BASE, '..', 'lib')

require 'rubygems'
require 'test/unit' 
require 'active_support'
require 'active_record'
require 'active_record/fixtures'
require 'shoulda'

config = YAML::load(IO.read(File.join(BASE, 'database.yml')))
ActiveRecord::Base.logger = Logger.new(File.join(BASE, "debug.log"))
ActiveRecord::Base.establish_connection(config['sqlite3'])
ActiveRecord::Migration.verbose = false

load(File.join(BASE, "schema.rb"))

Test::Unit::TestCase.fixture_path = File.join(BASE, "fixtures")

class Test::Unit::TestCase #:nodoc:
	def self.fixtures(*args)
		Fixtures.create_fixtures(Test::Unit::TestCase.fixture_path, args)
	end

  self.use_transactional_fixtures = false
  self.use_instantiated_fixtures  = false
end

