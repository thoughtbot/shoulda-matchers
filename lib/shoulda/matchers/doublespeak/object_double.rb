module Shoulda
  module Matchers
    module Doublespeak
      class ObjectDouble < BasicObject
        attr_reader :calls

        def initialize
          @calls = []
          @calls_by_method_name = {}
        end

        def calls_to(method_name)
          @calls_by_method_name[method_name] || []
        end

        def respond_to?(name, include_private = nil)
          true
        end

        def method_missing(method_name, *args, &block)
          calls << MethodCallWithName.new(method_name, args, block)
          (calls_by_method_name[method_name] ||= []) << MethodCall.new(args, block)
          nil
        end

        private

        attr_reader :calls_by_method_name
      end
    end
  end
end
