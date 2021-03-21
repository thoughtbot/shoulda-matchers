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

    def rails_5_x?
      rails_version =~ '~> 5.0'
    end

    def rails_gte_5_2?
      rails_version >= 5.2
    end
  end
end
