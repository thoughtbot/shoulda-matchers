require_relative '../../tests/version'

module AcceptanceTests
  module RubyVersionHelpers
    extend self

    def self.configure_example_group(example_group)
      example_group.include(self)
      example_group.extend(self)
    end

    def ruby_version
      Tests::Version.new(RUBY_VERSION)
    end

    def ruby_gt_4_0?
      ruby_version >= '4.0'
    end
  end
end
