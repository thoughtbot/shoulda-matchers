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
  end
end
