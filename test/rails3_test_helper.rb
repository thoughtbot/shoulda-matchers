rails_root = File.dirname(__FILE__) + '/rails3_root'
ENV['BUNDLE_GEMFILE'] = rails_root + '/Gemfile'
require "#{rails_root}/config/environment.rb"
require 'test/rails3_model_builder'
require 'rails/test_help'

