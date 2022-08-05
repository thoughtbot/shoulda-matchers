require_relative '../../tests/version'

module AcceptanceTests
  module RubyVersionHelpers
    def ruby_version
      Tests::Version.new(RUBY_VERSION)
    end

    def ruby_gt_3_1?
      ruby_version >= '3.1'
    end
  end
end
