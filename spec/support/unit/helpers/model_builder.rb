require_relative 'class_builder'

module UnitTests
  module ModelBuilder
    include ClassBuilder

    def self.configure_example_group(example_group)
      example_group.include(self)

      example_group.after do
        clear_column_caches
        drop_created_tables
      end
    end

    def create_table(table_name, options = {}, &block)
      connection = ActiveRecord::Base.connection

      begin
        connection.execute("DROP TABLE IF EXISTS #{table_name}")
        connection.create_table(table_name, options, &block)
        created_tables << table_name
        connection
      rescue Exception => e
        connection.execute("DROP TABLE IF EXISTS #{table_name}")
        raise e
      end
    end

    def define_model_class(class_name, &block)
      define_class(class_name, ActiveRecord::Base, &block)
    end

    def define_active_model_class(class_name, options = {}, &block)
      define_class(class_name) do
        include ActiveModel::Validations

        options[:accessors].each do |column|
          attr_accessor column.to_sym
        end

        if block_given?
          class_eval(&block)
        end
      end
    end

    def define_model(name, columns = {}, &block)
      class_name = name.to_s.pluralize.classify
      table_name = class_name.tableize.gsub('/', '_')

      table_block = lambda do |table|
        columns.each do |column_name, specification|
          if specification.is_a?(Hash)
            table.column column_name, specification[:type], specification[:options]
          else
            table.column column_name, specification
          end
        end
      end

      if columns.key?(:id) && columns[:id] == false
        columns.delete(:id)
        create_table(table_name, id: false, &table_block)
      else
        create_table(table_name, &table_block)
      end

      define_model_class(class_name).tap do |model|
        if block
          model.class_eval(&block)
        end

        model.table_name = table_name
      end
    end

    private

    def clear_column_caches
      # Rails 4.x
      if ActiveRecord::Base.connection.respond_to?(:schema_cache)
        ActiveRecord::Base.connection.schema_cache.clear!
      # Rails 3.1 - 4.0
      elsif ActiveRecord::Base.connection_pool.respond_to?(:clear_cache!)
        ActiveRecord::Base.connection_pool.clear_cache!
      end
    end

    def drop_created_tables
      connection = ActiveRecord::Base.connection

      created_tables.each do |table_name|
        connection.execute("DROP TABLE IF EXISTS #{table_name}")
      end
    end

    def created_tables
      @_created_tables ||= []
    end
  end
end
