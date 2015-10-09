require 'set'

module Shoulda
  module Matchers
    module Integrations
      # @private
      class Configuration
        attr_reader :test_framework_names, :library_names

        def initialize(&block)
          @test_framework_names = Set.new
          @library_names = Set.new

          block.call(self)
        end

        def test_framework(name)
          test_framework_names << name
        end

        def library(name)
          library_names << name
        end
      end
    end
  end
end
