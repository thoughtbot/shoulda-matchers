module UnitTests
  module ApplicationConfigurationHelpers
    def with_belongs_to_as_required_by_default(&block)
      configuring_application(
        ::ActiveRecord::Base,
        :belongs_to_required_by_default,
        true,
        &block
      )
    end

    def with_belongs_to_as_optional_by_default(&block)
      configuring_application(
        ::ActiveRecord::Base,
        :belongs_to_required_by_default,
        false,
        &block
      )
    end

    private

    def configuring_application(config, name, value)
      previous_value = config.send(name)
      config.send("#{name}=", value)
      yield
    ensure
      config.send("#{name}=", previous_value)
    end
  end
end
