module UnitTests
  module ActiveRecordVersions
    def self.configure_example_group(example_group)
      example_group.include(self)
      example_group.extend(self)
    end

    def active_record_version
      Tests::Version.new(::ActiveRecord::VERSION::STRING)
    end

    def active_record_supports_enum?
      defined?(::ActiveRecord::Enum)
    end

    def active_record_supports_has_secure_password?
      active_record_version >= 3.1
    end

    def active_record_supports_array_columns?
      active_record_version > 4.2
    end
  end
end
