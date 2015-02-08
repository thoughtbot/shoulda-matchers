module Tests
  module DatabaseAdapters
    class SQLite3
      def self.name
        :sqlite3
      end

      def initialize(_database)
      end

      def adapter
        self.class.name
      end

      def database
        'db/db.sqlite3'
      end

      def require_dependencies
        require 'sqlite3'
      end
    end

    DatabaseConfigurationRegistry.instance.register(SQLite3)
  end
end
