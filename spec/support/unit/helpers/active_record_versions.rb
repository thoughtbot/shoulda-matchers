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
  end
end
