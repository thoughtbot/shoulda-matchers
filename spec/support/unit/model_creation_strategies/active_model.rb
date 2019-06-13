module UnitTests
  module ModelCreationStrategies
    class ActiveModel
      def self.call(name, attribute_names = [], options = {}, &block)
        new(name, attribute_names, options, &block).call
      end

      def initialize(name, attribute_names = [], options = {}, &block)
        @name = name
        @attribute_names =
          if attribute_names.is_a?(Hash)
            # mimicking columns
            attribute_names.keys
          else
            attribute_names
          end
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
          attribute_names.each do |attribute_name|
            model.attribute(attribute_name)
          end

          model_customizers.each do |block|
            run_block(model, block)
          end
        end
      end

      private

      attr_reader :name, :attribute_names, :model_customizers, :options

      def run_block(model, block)
        if block
          if block.arity == 0
            model.class_eval(&block)
          else
            block.call(model)
          end
        end
      end

      module PoorMansAttributes
        extend ActiveSupport::Concern

        included do
          class_attribute :attribute_names

          self.attribute_names = Set.new
        end

        module ClassMethods
          def attribute(name)
            include attributes_module

            name = name.to_sym

            if (
              attribute_names.include?(name) &&
              attributes_module.instance_methods.include?(name)
            )
              attributes_module.module_eval do
                remove_method(name)
                remove_method("#{name}=")
              end
            end

            self.attribute_names += [name]

            attributes_module.module_eval do
              define_method(name) do
                attributes[name]
              end

              define_method("#{name}=") do |value|
                attributes[name] = value
              end
            end
          end

          private

          def attributes_module
            @_attributes_module ||= Module.new
          end
        end

        attr_reader :attributes

        def initialize(attributes = {})
          @attributes = attributes.symbolize_keys
        end

        def inspect
          middle = '%s:0x%014x%s' % [
            self.class,
            object_id * 2,
            ' ' + inspected_attributes.join(' '),
          ]

          "#<#{middle.strip}>"
        end

        private

        def inspected_attributes
          self.class.attribute_names.map do |name|
            "#{name}: #{attributes[name].inspect}"
          end
        end
      end

      class Model
        include ::ActiveModel::Model

        if defined?(::ActiveModel::Attributes)
          include ::ActiveModel::Attributes
        else
          include PoorMansAttributes
        end
      end
    end
  end
end
