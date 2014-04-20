require 'forwardable'

module Shoulda
  module Matchers
    module Doublespeak
      class << self
        extend Forwardable

        def_delegators :world, :register_double_collection,
          :with_doubles_activated

        def world
          @_world ||= World.new
        end
      end
    end
  end
end

require 'shoulda/matchers/doublespeak/double'
require 'shoulda/matchers/doublespeak/double_collection'
require 'shoulda/matchers/doublespeak/double_implementation_registry'
require 'shoulda/matchers/doublespeak/object_double'
require 'shoulda/matchers/doublespeak/proxy_implementation'
require 'shoulda/matchers/doublespeak/structs'
require 'shoulda/matchers/doublespeak/stub_implementation'
require 'shoulda/matchers/doublespeak/world'
