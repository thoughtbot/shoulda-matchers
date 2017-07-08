require 'forwardable'

module UnitTests
  module ModelCreators
    class Basic
      def self.call(args)
        new(args).call
      end

      extend Forwardable

      def_delegators :arguments, :attribute_name, :model_name
      def_delegators :model_creator, :customize_model

      def initialize(arguments)
        @arguments = arguments
        @model_creator = build_model_creator
      end

      def call
        model_creator.call
      end

      protected

      attr_reader :arguments, :model_creator

      private

      def_delegators(
        :arguments,
        :additional_model_creation_strategy_args,
        :all_attribute_overrides,
        :columns,
        :custom_validation?,
        :model_creation_strategy,
        :validation_name,
        :validation_options,
        :column_type,
      )

      def build_model_creator
        model_creator = model_creation_strategy.new(
          model_name,
          columns,
          arguments
        )

        model_creator.customize_model do |model|
          add_validation_to(model)
          possibly_override_attribute_writer_method_for(model)
        end

        model_creator
      end

      def add_validation_to(model)
        if custom_validation?
          _attribute_name = attribute_name

          model.send(:define_method, :custom_validation) do
            custom_validation.call(self, _attribute_name)
          end

          model.validate(:custom_validation)
        else
          model.public_send(validation_name, attribute_name, validation_options)
        end
      end

      def possibly_override_attribute_writer_method_for(model)
        all_attribute_overrides.each do |attribute_name, overrides|
          if overrides.key?(:changing_values_with)
            _change_value = method(:change_value)

            model.send(:define_method, "#{attribute_name}=") do |value|
              new_value = _change_value.call(
                value,
                overrides[:changing_values_with]
              )

              if respond_to?(:write_attribute)
                write_attribute(new_value)
              else
                super(new_value)
              end
            end
          end
        end
      end

      def change_value(value, value_changer)
        UnitTests::ChangeValue.call(column_type, value, value_changer)
      end
    end
  end
end
