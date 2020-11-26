module UnitTests
  module ActiveModelVersions
    def self.configure_example_group(example_group)
      example_group.include(self)
      example_group.extend(self)
    end

    def active_model_version
      Tests::Version.new(::ActiveModel::VERSION::STRING)
    end

    def active_model_supports_full_attributes_api?
      active_model_version >= '5.2'
    end

    def active_model_supports_custom_has_secure_password_attribute?
      active_model_version >= '6.0'
    end
  end
end
