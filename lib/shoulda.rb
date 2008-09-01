require 'shoulda/context'
require 'shoulda/proc_extensions'
require 'shoulda/assertions'
require 'shoulda/macros'
require 'shoulda/helpers'

module Test # :nodoc: all
  module Unit
    class TestCase
      extend Thoughtbot::Shoulda
      include ThoughtBot::Shoulda::Assertions
      extend ThoughtBot::Shoulda::Macros
      include ThoughtBot::Shoulda::Helpers
    end
  end
end

require 'yaml'

shoulda_options = {}

possible_config_paths = []
possible_config_paths << File.join(ENV["HOME"], ".shoulda.conf")       if ENV["HOME"]
possible_config_paths << "shoulda.conf"
possible_config_paths << File.join("test", "shoulda.conf")
possible_config_paths << File.join(RAILS_ROOT, "test", "shoulda.conf") if defined?(RAILS_ROOT)

possible_config_paths.each do |config_file|
  if File.exists? config_file
    shoulda_options = YAML.load_file(config_file).symbolize_keys
    break
  end
end

require 'shoulda/color' if shoulda_options[:color]
