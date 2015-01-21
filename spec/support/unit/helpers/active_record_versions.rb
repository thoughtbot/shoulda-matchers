module UnitTests
  module ActiveRecordVersions
    def self.configure_example_group(example_group)
      example_group.include(self)
      example_group.extend(self)
    end

    def active_record_version
      Tests::Version.new(ActiveRecord::VERSION::STRING)
    end

    def active_record_can_raise_range_error?
      active_record_version >= 4.2
    end
  end
end
