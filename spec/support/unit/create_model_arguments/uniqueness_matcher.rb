module UnitTests
  module CreateModelArguments
    class UniquenessMatcher < Basic
      def self.normalize_attribute(attribute)
        if attribute.is_a?(Hash)
          Attribute.new(attribute)
        else
          Attribute.new(name: attribute)
        end
      end

      def self.normalize_attributes(attributes)
        attributes.map do |attribute|
          normalize_attribute(attribute)
        end
      end

      def columns
        attributes.reduce({}) do |options, attribute|
          options.merge(
            attribute.name => {
              type: attribute.column_type,
              options: attribute.column_options
            }
          )
        end
      end

      def validation_options
        super.merge(scope: scope_attribute_names)
      end

      def attribute_default_values_by_name
        attributes.reduce({}) do |values, attribute|
          values.merge(attribute.name => attribute.default_value)
        end
      end

      protected

      def attribute_class
        Attribute
      end

      private

      def attributes
        [attribute] + scope_attributes + additional_attributes
      end

      def scope_attribute_names
        scope_attributes.map(&:name)
      end

      def scope_attributes
        @_scope_attributes ||= self.class.normalize_attributes(
          args.fetch(:scopes, [])
        )
      end

      def additional_attributes
        @_additional_attributes ||= self.class.normalize_attributes(
          args.fetch(:additional_attributes, [])
        )
      end

      class Attribute < UnitTests::Attribute
        def value_type
          args.fetch(:value_type) { column_type }
        end
      end
    end
  end
end
