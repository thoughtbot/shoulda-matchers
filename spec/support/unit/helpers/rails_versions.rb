module UnitTests
  module RailsVersions
    def self.configure_example_group(example_group)
      example_group.include(self)
      example_group.extend(self)
    end

    def rails_version
      Gem::Version.new(Rails::VERSION::STRING)
    end

    def rails_3_x?
      Gem::Requirement.new('~> 3.0').satisfied_by?(rails_version)
    end

    def rails_4_x?
      Gem::Requirement.new('~> 4.0').satisfied_by?(rails_version)
    end

    def rails_gte_4_1?
      Gem::Requirement.new('>= 4.1').satisfied_by?(rails_version)
    end

    def active_record_supports_enum?
      defined?(::ActiveRecord::Enum)
    end
  end
end
