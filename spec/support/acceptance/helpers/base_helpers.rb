require_relative '../../tests/filesystem'
require_relative '../../tests/bundle'

module AcceptanceTests
  module BaseHelpers
    def fs
      @_fs ||= Tests::Filesystem.new
    end

    def bundle
      @_bundle ||= Tests::Bundle.new
    end
  end
end
