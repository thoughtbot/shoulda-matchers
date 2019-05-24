module UnitTests
  module ActiveRecord
    class CreateTable
      def self.call(
        table_name:,
        columns:,
        connection: ::ActiveRecord::Base.connection,
        &block
      )
        new(
          table_name: table_name,
          columns: columns,
          connection: connection,
          &block
        ).call
      end

      def initialize(
        table_name:,
        columns:,
        connection: ::ActiveRecord::Base.connection,
        &block
      )
        @table_name = table_name
        @columns = columns
        @connection = connection
        @customizer = block || proc {}
      end

      def call
        if columns.key?(:id) && columns[:id] == false
          columns.delete(:id)
          UnitTests::ModelBuilder.create_table(
            table_name,
            connection: connection,
            id: false
          ) do |table|
            add_columns_to_table(table)
          end
        else
          UnitTests::ModelBuilder.create_table(
            table_name,
            connection: connection
          ) do |table|
            add_columns_to_table(table)
          end
        end
      end

      private

      attr_reader :table_name, :columns, :connection, :customizer

      def add_columns_to_table(table)
        columns.each do |column_name, column_specification|
          add_column_to_table(table, column_name, column_specification)
        end

        customizer.call(table)
      end

      def add_column_to_table(table, column_name, column_specification)
        if column_specification.is_a?(Hash)
          column_type = column_specification.fetch(:type)
          column_options = column_specification.fetch(:options, {})
        else
          column_type = column_specification
          column_options = {}
        end

        table.column(column_name, column_type, column_options)
      end
    end
  end
end
