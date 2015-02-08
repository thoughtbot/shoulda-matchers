module Tests
  module DatabaseAdapters
    class PostgreSQL
      def self.name
        :postgresql
      end

      attr_reader :database

      def initialize(database)
        @database = database
      end

      def adapter
        self.class.name
      end

      def require_dependencies
        require 'pg'
      end
    end

    DatabaseConfigurationRegistry.instance.register(PostgreSQL)
  end
end
