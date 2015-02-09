require_relative 'database_configuration_registry'
require 'delegate'

module Tests
  class DatabaseConfiguration < SimpleDelegator
    ENVIRONMENTS = %w(development test production)

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

    def to_hash
      ENVIRONMENTS.each_with_object({}) do |env, config_as_hash|
        config_as_hash[env] = inner_config_as_hash
      end
    end

    private

    def inner_config_as_hash
      { 'adapter' => adapter.to_s, 'database' => database.to_s }
    end
  end
end
