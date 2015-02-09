require_relative 'database_configuration'

module Tests
  class Database
    NAME = 'shoulda-matchers-test'
    ADAPTER_NAME = ENV.fetch('DATABASE_ADAPTER', 'sqlite3').to_sym

    include Singleton

    attr_reader :config

    def initialize
      @config = Tests::DatabaseConfiguration.for(NAME, ADAPTER_NAME)
    end

    def name
      config.database
    end

    def adapter_name
      config.adapter
    end

    def adapter_class
      config.adapter_class
    end
  end
end
