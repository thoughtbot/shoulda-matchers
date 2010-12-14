ENV['RAILS_ENV'] = 'test'
ENV['RAILS_VERSION'] ||= '3.0.3'
RAILS_GEM_VERSION = ENV['RAILS_VERSION']

rails_root = File.dirname(__FILE__) + '/rails3_root'
ENV['BUNDLE_GEMFILE'] = rails_root + '/Gemfile'

require "#{rails_root}/config/environment"
require 'rspec'
require 'rspec/autorun'

PROJECT_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..')).freeze

$LOAD_PATH << File.join(PROJECT_ROOT, 'lib')

Dir[File.join(PROJECT_ROOT, 'spec', 'support', '**', '*.rb')].each { |file| require(file) }

require 'shoulda'
require 'rspec/rails'

# Run the migrations
ActiveRecord::Migration.verbose = false
ActiveRecord::Migrator.migrate("#{Rails.root}/db/migrate")

RSpec.configure do |config|
  config.mock_with :mocha
  config.include Shoulda::ActionController::Matchers,
                 :example_group => { :file_path => /action_controller/ }
  config.include Shoulda::ActionMailer::Matchers,
                 :example_group => { :file_path => /action_mailer/ }
end

