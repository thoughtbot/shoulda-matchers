require_relative 'class_builder'

module UnitTests
  module ModelBuilder
    def create_table(*args, &block)
      ModelBuilder.create_table(*args, &block)
    end

    def define_model(*args, &block)
      ModelBuilder.define_model(*args, &block)
    end

    def define_model_instance(*args, &block)
      define_model(*args, &block).new
    end

    def define_model_class(*args, &block)
      ModelBuilder.define_model_class(*args, &block)
    end

    def define_active_model_class(*args, &block)
      ModelBuilder.define_active_model_class(*args, &block)
    end

    class << self
      def configure_example_group(example_group)
        example_group.include(self)

        example_group.after do
          ModelBuilder.reset
        end
      end

      def reset
        clear_column_caches
        drop_created_tables
        created_tables.clear
        defined_models.clear
      end

      def create_table(table_name, options = {}, &block)
        connection =
          options.delete(:connection) || DevelopmentRecord.connection

        begin
          connection.execute("DROP TABLE IF EXISTS #{table_name}")
          connection.create_table(table_name, **options, &block)
          created_tables << table_name
          connection
        rescue StandardError => e
          connection.execute("DROP TABLE IF EXISTS #{table_name}")
          raise e
        end
      end

      def define_model_class(class_name, parent_class: DevelopmentRecord, &block)
        ClassBuilder.define_class(class_name, parent_class, &block)
      end

      def define_active_model_class(class_name, options = {}, &block)
        attribute_names = options.delete(:accessors) { [] }

        UnitTests::ModelCreationStrategies::ActiveModel.call(
          class_name,
          attribute_names,
          options,
          &block
        )
      end

      def define_model(name, columns = {}, options = {}, &block)
        model = UnitTests::ModelCreationStrategies::ActiveRecord.call(
          name,
          columns,
          options,
          &block
        )
        model.reset_column_information
        defined_models << model
        model
      end

      private

      def clear_column_caches
        DevelopmentRecord.connection.schema_cache.clear!
        ProductionRecord.connection.schema_cache.clear!
      end

      def drop_created_tables
        created_tables.each do |table_name|
          DevelopmentRecord.connection.
            execute("DROP TABLE IF EXISTS #{table_name}")
          ProductionRecord.connection.
            execute("DROP TABLE IF EXISTS #{table_name}")
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
end
