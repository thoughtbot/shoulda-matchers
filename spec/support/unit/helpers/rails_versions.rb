module UnitTests
  module RailsVersions
    extend self

    def self.configure_example_group(example_group)
      example_group.include(self)
      example_group.extend(self)
    end

    def rails_version
      Tests::Version.new(Rails::VERSION::STRING)
    end

    def active_record_version
      Tests::Version.new(::ActiveModel::VERSION::STRING)
    end

    def rails_oldest_version_supported
      7.1
    end

    def rails_gt_8_0?
      rails_version >= '8.0'
    end

    def active_record_gte_8_1?
      active_record_version >= '8.1'
    end
  end
end
