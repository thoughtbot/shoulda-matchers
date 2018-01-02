module Shoulda
  module Matchers
    module ActiveModel
      # @private
      class HaveAttributeMatcher
        def initialize(attribute)
          @attribute = attribute
        end

        def matches?(subject)
          @subject = subject

          model.method_defined?("#{attribute}=") ||
            model.columns_hash.key?(attribute.to_s)
        end

        def failure_message
          "Expected #{model} to #{expectation}, but #{aberration}."
        end

        private

        attr_reader :attribute, :subject

        def expectation
          "have :#{attribute}"
        end

        def aberration
          'it did not'
        end

        def model
          subject.class
        end
      end
    end
  end
end
