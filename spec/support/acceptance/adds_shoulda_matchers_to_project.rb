require_relative 'helpers/base_helpers'
require_relative 'helpers/rspec_helpers'

module AcceptanceTests
  class AddsShouldaMatchersToProject
    def self.call(options)
      new(options).call
    end

    include BaseHelpers
    include RspecHelpers

    def initialize(options)
      @options = options
    end

    def call
      add_gem 'shoulda-matchers', gem_options
      configure_test_helper_files
    end

    protected

    attr_reader :options

    private

    def gem_options
      gem_options = { path: fs.root_directory }

      if options[:manually]
        gem_options[:require] = false
      end

      gem_options
    end

    def configure_test_helper_files
      each_test_helper_file do |test_helper_file, test_framework, library|
        add_configuration_block_to(
          test_helper_file,
          test_framework,
          library
        )
      end
    end

    def each_test_helper_file
      options[:test_frameworks].each do |test_framework|
        libraries = options.fetch(:libraries, [])
        test_helper_file = test_helper_file_for(test_framework, libraries)
        yield test_helper_file, test_framework, libraries
      end
    end

    def add_configuration_block_to(test_helper_file, test_framework, libraries)
      test_framework_config = test_framework_config_for(test_framework)
      library_config = library_config_for(libraries)

      content = <<-EOT
        Shoulda::Matchers.configure do |config|
          config.integrate do |with|
            #{test_framework_config}
            #{library_config}
          end
        end
      EOT

      if options[:manually]
        content = "require 'shoulda-matchers'\n#{content}"
      end

      fs.append_to_file(test_helper_file, content)
    end

    def test_framework_config_for(test_framework)
      if test_framework
        "with.test_framework :#{test_framework}\n"
      else
        ''
      end
    end

    def library_config_for(libraries)
      libraries.map { |library| "with.library :#{library}" }.join("\n")
    end

    def test_helper_file_for(test_framework, libraries)
      if integrates_with_rails?(test_framework, libraries) ||
        integrates_with_nunit?(test_framework)
        'test/test_helper.rb'
      elsif integrates_with_rspec?(test_framework)
        spec_helper_file_path
      end
    end

    def integrates_with_nunit?(test_framework)
      nunit_frameworks = [:test_unit, :minitest]
      nunit_frameworks.include?(test_framework)
    end

    def integrates_with_rspec?(test_framework)
      test_framework == :rspec
    end

    def integrates_with_rails?(test_framework, libraries)
      test_framework.nil? && libraries.include?(:rails)
    end
  end
end
