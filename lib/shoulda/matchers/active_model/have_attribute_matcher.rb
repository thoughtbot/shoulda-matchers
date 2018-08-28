module Shoulda
  module Matchers
    module ActiveModel
      # @private
      class HaveAttributeMatcher
        def initialize(attribute_name)
          @attribute_name = attribute_name
        end

        def matches?(record)
          @record = record

          model.method_defined?("#{attribute_name}=") ||
            model.columns_hash.key?(attribute_name.to_s)
        end

        def expectation_description
          "Expected :#{attribute_name} to be an attribute of #{model} " +
            "(i.e. for #{model} to define a writer method called " +
            ":#{attribute_name}=)."
        end

        def aberration_description
          'However, it was not.'
        end

        private

        attr_reader :attribute_name, :record

        def model
          record.class
        end
      end
    end
  end
end
