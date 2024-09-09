require_relative '../helpers/active_record_versions'
require_relative '../helpers/database_helpers'

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
        @columns = normalize_columns(columns)
        @connection = connection
        @customizer = block || proc {}
      end

      def call
        if columns.key?(:id) && columns[:id] == false
          columns.delete(:id)
          UnitTests::ModelBuilder.create_table(
            table_name,
            connection: connection,
            id: false,
          ) do |table|
            add_columns_to_table(table)
          end
        else
          UnitTests::ModelBuilder.create_table(
            table_name,
            connection: connection,
          ) do |table|
            add_columns_to_table(table)
          end
        end
      end

      private

      attr_reader :table_name, :columns, :connection, :customizer

      delegate(
        :database_supports_array_columns?,
        :database_adapter,
        to: UnitTests::DatabaseHelpers,
      )

      def normalize_columns(columns)
        if columns.is_a?(Hash)
          if columns.values.first.is_a?(Hash)
            columns
          else
            columns.transform_values do |value|
              if value == false
                value
              else
                { type: value }
              end
            end
          end
        else
          columns.inject({}) do |hash, column_name|
            hash.merge!(column_name => { type: :string })
          end
        end
      end

      def add_columns_to_table(table)
        columns.each do |column_name, column_specification|
          add_column_to_table(table, column_name, column_specification)
        end

        customizer.call(table)
      end

      def add_column_to_table(table, column_name, column_specification)
        column_specification = column_specification.dup
        column_type = column_specification.delete(:type)
        column_options = column_specification.delete(:options) { {} }
        column_options.merge!({ _skip_validate_options: true }) if Shoulda::Matchers::RailsShim.validates_column_options?

        if column_options[:array] && !database_supports_array_columns?
          raise ArgumentError.new(
            'An array column is being added to a table, but this '\
            "database adapter (#{database_adapter}) "\
            'does not support array columns.',
          )
        end

        if column_specification.any?
          raise ArgumentError.new(
            "Invalid column specification.\nYou need to put "\
            "#{column_specification.keys.map(&:inspect).to_sentence} "\
            'inside an :options key!',
          )
        end

        table.column(column_name, column_type, **column_options)
      end
    end
  end
end
