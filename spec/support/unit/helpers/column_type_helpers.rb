module UnitTests
  module ColumnTypeHelpers
    def self.configure_example_group(example_group)
      example_group.include(self)
    end

    def column_type_class_namespace
      if database_adapter == :postgresql
        ActiveRecord::ConnectionAdapters::PostgreSQL
      else
        ActiveRecord::Type
      end
    end

    def column_type_class_for(type)
      namespace =
        if type == :integer && database_adapter == :postgresql
          column_type_class_namespace::OID
        else
          column_type_class_namespace
        end

      namespace.const_get(type.to_s.camelize)
    end
  end
end
