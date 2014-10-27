require_relative '../../tests/version'

module AcceptanceTests
  module RubyVersionHelpers
    def ruby_version
      Tests::Version.new(RUBY_VERSION)
    end
  end
end
