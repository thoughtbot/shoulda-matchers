module UnitTests
  module ActionPackVersions
    extend self

    def self.configure_example_group(example_group)
      example_group.include(self)
      example_group.extend(self)
    end

    def action_pack_gte_5?
      action_pack_version =~ '>= 5'
    end

    def action_pack_version
      Tests::Version.new(ActionPack::VERSION::STRING)
    end
  end
end
