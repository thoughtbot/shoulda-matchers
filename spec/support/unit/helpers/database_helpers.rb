module UnitTests
  module DatabaseHelpers
    def self.configure_example_group(example_group)
      example_group.include(self)
      example_group.extend(self)
    end

    def database_adapter
      Tests::Database.instance.adapter_name
    end

    def postgresql?
      database_adapter == :postgresql
    end

    alias_method :database_supports_array_columns?, :postgresql?
    alias_method :database_supports_uuid_columns?, :postgresql?
    alias_method :database_supports_money_columns?, :postgresql?
  end
end
