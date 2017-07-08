module UnitTests
  module ModelCreationStrategies
    class ActiveModel
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
        ClassBuilder.define_class(name, Model).tap do |model|
          model.columns = columns.keys

          model_customizers.each do |block|
            run_block(model, block)
          end
        end
      end

      protected

      attr_reader :name, :columns, :model_customizers, :options

      private

      def run_block(model, block)
        if block
          if block.arity == 0
            model.class_eval(&block)
          else
            block.call(model)
          end
        end
      end

      class Model
        class << self
          def columns
            @_columns ||= []
          end

          def columns=(columns)
            existing_columns = self.columns
            new_columns = columns - existing_columns

            @_columns += new_columns

            include attributes_module

            attributes_module.module_eval do
              new_columns.each do |column|
                define_method(column) do
                  attributes[column]
                end

                define_method("#{column}=") do |value|
                  attributes[column] = value
                end
              end
            end
          end

          private

          def attributes_module
            @_attributes_module ||= Module.new
          end
        end

        include ::ActiveModel::Model

        attr_reader :attributes

        def initialize(attributes = {})
          @attributes = attributes.symbolize_keys
        end

        def inspect
          middle = '%s:0x%014x%s' % [
            self.class,
            object_id * 2,
            ' ' + inspected_attributes.join(' ')
          ]

          "#<#{middle.strip}>"
        end

        private

        def inspected_attributes
          self.class.columns.map do |key, value|
            "#{key}: #{attributes[key].inspect}"
          end
        end
      end
    end
  end
end
