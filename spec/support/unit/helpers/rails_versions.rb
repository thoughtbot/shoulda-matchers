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

    def rails_3_x?
      rails_version =~ '~> 3.0'
    end

    def rails_4_x?
      rails_version =~ '~> 4.0'
    end

    def rails_lte_4?
      rails_version <= 4
    end

    def rails_gte_4_1?
      rails_version >= 4.1
    end

    def rails_gte_4_2?
      rails_version >= 4.2
    end

    def rails_lt_5?
      rails_version < 5
    end

    def rails_5_x?
      rails_version =~ '~> 5.0'
    end
  end
end
