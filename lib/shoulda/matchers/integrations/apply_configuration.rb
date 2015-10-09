require 'forwardable'

module Shoulda
  module Matchers
    module Integrations
      class ApplyConfiguration
        def self.call(configuration)
          new(configuration).call
        end

        extend Forwardable
        def_delegators :configuration, :test_framework_names, :library_names

        def initialize(configuration)
          @configuration = configuration
        end

        def call
          validate_configuration!
          @test_frameworks_by_name = find_test_frameworks!
          @libraries_by_name = find_libraries!
          validate_test_frameworks!
          validate_libraries!

          test_frameworks.each do |test_framework|
            test_framework.include(Shoulda::Matchers::Independent)
            libraries.each { |library| library.integrate_with(test_framework) }
          end
        end

        protected

        attr_reader :configuration, :test_frameworks_by_name, :libraries_by_name

        private

        def validate_configuration!
          if no_test_frameworks_specified? && no_libraries_specified?
            raise NoTestFrameworksOrLibrariesSpecifiedError
          end

          # TODO: Test this
          if no_test_frameworks_specified?
            raise NoTestFrameworksSpecifiedError
          end
        end

        def no_test_frameworks_specified?
          test_framework_names.empty?
        end

        def no_libraries_specified?
          library_names.empty?
        end

        def find_test_frameworks!
          test_framework_names.reduce({}) do |hash, name|
            hash.merge name => Integrations.find_test_framework!(name)
          end
        end

        def find_libraries!
          library_names.reduce({}) do |hash, name|
            hash.merge name => Integrations.find_library!(name)
          end
        end

        def validate_test_frameworks!
          test_frameworks_by_name.each do |name, test_framework|
            validate_test_framework!(test_framework, name)
          end
        end

        def validate_test_framework!(test_framework, test_framework_name)
          missing_inclusion_target =
            test_framework.find_first_missing_inclusion_target

          if missing_inclusion_target
            raise TestFrameworkNotAvailableError.create(
              test_framework_name: test_framework_name,
              missing_inclusion_target: missing_inclusion_target
            )
          end
        end

        def validate_libraries!
          libraries_by_name.each do |name, library|
            validate_library!(library, name)
          end
        end

        def validate_library!(library, library_name)
          missing_inclusion_target =
            library.find_first_missing_inclusion_target

          if missing_inclusion_target
            raise LibraryNotAvailableError.create(
              library_name: library_name,
              missing_inclusion_target: missing_inclusion_target
            )
          end
        end
      end
    end
  end
end
