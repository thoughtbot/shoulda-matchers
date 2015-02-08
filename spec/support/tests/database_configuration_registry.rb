require 'singleton'

module Tests
  class DatabaseConfigurationRegistry
    include Singleton

    def initialize
      @registry = {}
    end

    def register(config_class)
      registry[config_class.name] = config_class
    end

    def get(name)
      registry.fetch(name) do
        raise KeyError, "No such adapter registered: #{name}"
      end
    end

    protected

    attr_reader :registry
  end
end

require_relative 'database_adapters/postgresql'
require_relative 'database_adapters/sqlite3'
