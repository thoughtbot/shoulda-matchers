module UnitTests
  module ActiveRecordVersions
    def self.configure_example_group(example_group)
      example_group.include(self)
      example_group.extend(self)
    end

    extend self

    def active_record_version
      Tests::Version.new(::ActiveRecord::VERSION::STRING)
    end

    def active_record_supports_relations?
      active_record_version >= 4
    end

    def active_record_supports_more_dependent_options?
      active_record_version >= 4
    end

    def active_record_uniqueness_supports_array_columns?
      active_record_version < 5
    end

    def active_record_supports_optional_for_associations?
      active_record_version >= 5
    end

    def active_record_supports_expression_indexes?
      active_record_version >= 5
    end

    def active_record_supports_active_storage?
      active_record_version >= 5.2
    end

    def active_record_supports_validate_presence_on_active_storage?
      active_record_version >= '6.0.0.beta1'
    end

    def active_record_supports_implicit_order_column?
      active_record_version >= '6.0.0.beta1'
    end
  end
end
