require_relative 'gem_helpers'

module AcceptanceTests
  module RspecHelpers
    include GemHelpers

    def rspec_core_version
      bundle_version_of('rspec-core')
    end

    def rspec_expectations_version
      bundle_version_of('rspec-expectations')
    end

    def rspec_rails_version
      bundle_version_of('rspec-rails')
    end

    def add_rspec_file(path, content)
      content = "require 'rails_helper'\n#{content}"
      write_file path, content
    end
  end
end
