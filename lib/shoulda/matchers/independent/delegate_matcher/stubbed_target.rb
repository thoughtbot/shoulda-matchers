module Shoulda # :nodoc:
  module Matchers
    module Independent # :nodoc:
      class DelegateMatcher::StubbedTarget # :nodoc:
        def initialize(method)
          @received_method = false
          @received_arguments = []
          stub_method(method)
        end

        def has_received_method?
          received_method
        end

        def has_received_arguments?(*args)
          args == received_arguments
        end

        private

        def stub_method(method)
          class_eval do
            define_method method do |*args|
              @received_method = true
              @received_arguments = args
            end
          end
        end

        attr_reader :received_method, :received_arguments
      end
    end
  end
end
