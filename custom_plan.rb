require 'zeus'
require 'zeus/plan'
require_relative 'spec/support/tests/current_bundle'

class CouldNotBootZeusError < StandardError
  def self.create(underlying_error:)
    new(<<-MESSAGE)
Couldn't boot Zeus.

Bundler tried to load a gem that has already been loaded (but the
versions are different).

Note that Appraisal requires Rake, and so you'll want to make sure that
the Gemfile is pointing to the same version of Rake that you have
installed locally.

The original message is as follows:

#{underlying_error.message}
    MESSAGE
  end
end

class CustomPlan < Zeus::Plan
  def boot
    ENV['BUNDLE_GEMFILE'] = File.expand_path(
      "../gemfiles/#{latest_appraisal}.gemfile",
      __FILE__
    )

    require 'bundler/setup'

    $LOAD_PATH << File.expand_path('../lib', __FILE__)
    $LOAD_PATH << File.expand_path('../spec', __FILE__)

    require_relative 'spec/support/unit/load_environment'
  rescue Gem::LoadError => error
    raise CouldNotBootZeusError.create(underlying_error: error)
  end

  def after_fork
  end

  def test_environment
    require_relative 'spec/unit_spec_helper'
  end

  def rspec
    ARGV.replace(file_paths_to_run)
    RSpec::Core::Runner.invoke
  end

  private

  def latest_appraisal
    current_bundle.latest_appraisal
  end

  def current_bundle
    Tests::CurrentBundle.instance
  end

  def file_paths_to_run
    if given_file_paths.empty?
      ['spec/unit']
    else
      given_file_paths.map do |given_path|
        determine_file_path_to_run(given_path)
      end
    end
  end

  def determine_file_path_to_run(given_rspec_argument)
    expanded_file_path, location =
      expand_rspec_argument(given_rspec_argument)

    if File.exist?(expanded_file_path)
      if location
        expanded_file_path + location
      else
        expanded_file_path
      end
    else
      given_rspec_argument
    end
  end

  def expand_rspec_argument(rspec_argument)
    match = rspec_argument.match(/\A(.+?)(:\d+|\[[\d:]+\])?\Z/)
    file_path, location = match.captures
    expanded_file_path = File.expand_path(
      "../spec/unit/shoulda/matchers/#{file_path}",
      __FILE__
    )

    [expanded_file_path, location]
  end

  def given_file_paths
    ARGV
  end
end

Zeus.plan = CustomPlan.new
