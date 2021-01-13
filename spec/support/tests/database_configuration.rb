require_relative 'database_configuration_registry'
require 'delegate'

module Tests
  class DatabaseConfiguration < SimpleDelegator
    attr_reader :adapter_class

    def self.for(database_name, adapter_name)
      config_class = DatabaseConfigurationRegistry.instance.get(adapter_name)
      config = config_class.new(database_name)
      new(config)
    end

    def initialize(config)
      @adapter_class = config.class.to_s.split('::').last
      super(config)
    end

    def load_file
      YAML::load_file(File.join(__dir__, "database_adapters/config/#{adapter}.yml"))
    end
  end
end
