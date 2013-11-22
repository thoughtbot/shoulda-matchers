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
      accessors = options.fetch(:accessors, [])

      define_class(class_name) do
        include ActiveModel::Validations

        def initialize(attributes = {})
          attributes.each do |name, value|
            __send__("#{name}=", value)
          end
        end

        accessors.each do |column|
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
            column_type = specification[:type]
            column_options = specification.fetch(:options, {})
          else
            column_type = specification
            column_options = {}
          end

          begin
            table.__send__(column_type, column_name, column_options)
          rescue NoMethodError
            raise NoMethodError, "#{Tests::Database.instance.adapter_class} does not support :#{column_type} columns"
          end
        end
      end

      if columns.key?(:id) && columns[:id] == false
        columns.delete(:id)
        create_table(table_name, id: false, &table_block)
      else
        create_table(table_name, &table_block)
      end

      model = define_model_class(class_name).tap do |m|
        if block
          if block.arity == 0
            m.class_eval(&block)
          else
            block.call(m)
          end
        end

        m.table_name = table_name
      end

      defined_models << model

      model
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

      defined_models.each do |model|
        model.reset_column_information
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

    def defined_models
      @_defined_models ||= []
    end
  end
end
