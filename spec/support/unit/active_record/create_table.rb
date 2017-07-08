module UnitTests
  module ActiveRecord
    class CreateTable
      def self.call(table_name, columns)
        new(table_name, columns).call
      end

      def initialize(table_name, columns)
        @table_name = table_name
        @columns = columns
      end

      def call
        if columns.key?(:id) && columns[:id] == false
          columns.delete(:id)
          UnitTests::ModelBuilder.create_table(
            table_name,
            id: false,
            &method(:add_columns_to_table)
          )
        else
          UnitTests::ModelBuilder.create_table(
            table_name,
            &method(:add_columns_to_table)
          )
        end
      end

      protected

      attr_reader :table_name, :columns

      private

      def add_columns_to_table(table)
        columns.each do |column_name, column_specification|
          add_column_to_table(table, column_name, column_specification)
        end
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
