module Shoulda
  module Matchers
    module ActiveModel
      module Qualifiers
        # @private
        module Callbacks
          def initialize(*args)
            require "pry-byebug"; binding.pry

            super

            @before_matching_callbacks = []
            @after_matching_callbacks = []
          end

          def before_matching(&block)
            before_matching_callbacks << block
          end

          def after_matching(&block)
            after_matching_callbacks << block
          end

          protected

          def before_match
          end

          def after_match
          end

          def matching
            before_matching_callbacks.each(&:call)
            before_match

            yield.tap do
              after_matching_callbacks.each(&:call)
              after_match
            end
          end

          private

          attr_reader :before_matching_callbacks, :after_matching_callbacks
        end
      end
    end
  end
end
