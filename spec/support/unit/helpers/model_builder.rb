require_relative 'class_builder'

module UnitTests
  module ModelBuilder
    def create_table(*args, &block)
      ModelBuilder.create_table(*args, &block)
    end

    def define_model(*args, &block)
      ModelBuilder.define_model(*args, &block)
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
        connection = ::ActiveRecord::Base.connection

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
        ClassBuilder.define_class(class_name, ::ActiveRecord::Base, &block)
      end

      def define_active_model_class(class_name, options = {}, &block)
        attribute_names = options.delete(:accessors) { [] }

        columns = attribute_names.reduce({}) do |hash, attribute_name|
          hash.merge(attribute_name => nil)
        end

        UnitTests::ModelCreationStrategies::ActiveModel.call(
          'Example',
          columns,
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
        defined_models << model
        model
      end

      private

      def clear_column_caches
        # Rails 4.x
        if ::ActiveRecord::Base.connection.respond_to?(:schema_cache)
          ::ActiveRecord::Base.connection.schema_cache.clear!
        # Rails 3.1 - 4.0
        elsif ::ActiveRecord::Base.connection_pool.respond_to?(:clear_cache!)
          ::ActiveRecord::Base.connection_pool.clear_cache!
        end

        defined_models.each do |model|
          model.reset_column_information
        end
      end

      def drop_created_tables
        connection = ::ActiveRecord::Base.connection

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
end
