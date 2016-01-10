module UnitTests
  module ModelCreationStrategies
    class ActiveRecord
      def self.call(name, columns = {}, options = {}, &block)
        new(name, columns, options, &block).call
      end

      def initialize(name, columns = {}, options = {}, &block)
        @name = name
        @columns = columns
        @options = options
        @model_customizers = []

        if block
          customize_model(&block)
        end
      end

      def customize_model(&block)
        model_customizers << block
      end

      def call
        create_table_for_model
        define_class_for_model
      end

      protected

      attr_reader :columns, :model_customizers, :name, :options

      private

      def create_table_for_model
        UnitTests::ActiveRecord::CreateTable.call(table_name, columns)
      end

      def define_class_for_model
        model = UnitTests::ModelBuilder.define_model_class(class_name)

        model_customizers.each do |block|
          run_block(model, block)
        end

        if whitelist_attributes?
          model.attr_accessible(*columns.keys)
        end

        model.table_name = table_name

        model
      end

      def run_block(model, block)
        if block
          if block.arity == 0
            model.class_eval(&block)
          else
            block.call(model)
          end
        end
      end

      def class_name
        name.to_s.pluralize.classify
      end

      def table_name
        class_name.tableize.gsub('/', '_')
      end

      def whitelist_attributes?
        options.fetch(:whitelist_attributes, true)
      end
    end
  end
end
