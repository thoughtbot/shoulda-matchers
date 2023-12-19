module UnitTests
  module ActiveModelVersions
    def self.configure_example_group(example_group)
      example_group.include(self)
      example_group.extend(self)
    end

    def active_model_version
      Tests::Version.new(::ActiveModel::VERSION::STRING)
    end
  end
end
