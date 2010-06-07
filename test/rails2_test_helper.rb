rails_root = File.dirname(__FILE__) + '/rails2_root'
require "#{rails_root}/config/environment.rb"
require 'test_help'
require 'test/rails2_model_builder'
silence_warnings { RAILS_ENV = ENV['RAILS_ENV'] }

