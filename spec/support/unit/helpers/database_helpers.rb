module UnitTests
  module DatabaseHelpers
    def self.configure_example_group(example_group)
      example_group.include(self)
      example_group.extend(self)
    end

    def database_adapter
      Tests::Database.instance.adapter_name
    end

    def database_supports_uuid_columns?
      database_adapter == :postgresql
    end
    alias_method :database_supports_array_columns?,
      :database_supports_uuid_columns?
  end
end
