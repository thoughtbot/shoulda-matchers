module UnitTests
  module ActiveModelVersions
    def self.configure_example_group(example_group)
      example_group.include(self)
      example_group.extend(self)
    end

    def active_model_version
      Tests::Version.new(::ActiveModel::VERSION::STRING)
    end

    def active_model_3_1?
      (::ActiveModel::VERSION::MAJOR == 3 && ::ActiveModel::VERSION::MINOR >= 1) || active_model_4_0?
    end

    def active_model_3_2?
      (::ActiveModel::VERSION::MAJOR == 3 && ::ActiveModel::VERSION::MINOR >= 2) || active_model_4_0?
    end

    def active_model_4_0?
      ::ActiveModel::VERSION::MAJOR == 4
    end

    def active_model_supports_strict?
      active_model_version >= 3.2
    end
  end
end
