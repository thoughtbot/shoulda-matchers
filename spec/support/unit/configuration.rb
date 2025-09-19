module UnitTests
  class Configuration
    CLASSES = %i[
      ActiveModelHelpers
      ActiveModelVersions
      ActiveRecordVersions
      ClassBuilder
      ColumnTypeHelpers
      ControllerBuilder
      DatabaseHelpers
      I18nFaker
      MailerBuilder
      MessageHelpers
      ModelBuilder
      RailsVersions
      RubyVersions
      ValidationMatcherScenarioHelpers
    ].freeze

    def self.configure_example_groups(config)
      CLASSES.each do |class_name|
        constantized_class = "UnitTests::#{class_name}"
        Object.const_get(constantized_class).configure_example_group(config)
      end
    end
  end
end
