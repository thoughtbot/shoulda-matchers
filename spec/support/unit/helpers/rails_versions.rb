module UnitTests
  module RailsVersions
    def self.configure_example_group(example_group)
      example_group.include(self)
      example_group.extend(self)
    end

    def rails_version
      Tests::Version.new(Rails::VERSION::STRING)
    end

    def rails_3_x?
      rails_version =~ '~> 3.0'
    end

    def rails_4_x?
      rails_version =~ '~> 4.0'
    end

    def rails_gte_4_1?
      rails_version >= 4.1
    end

    def active_record_supports_enum?
      defined?(::ActiveRecord::Enum)
    end
  end
end
