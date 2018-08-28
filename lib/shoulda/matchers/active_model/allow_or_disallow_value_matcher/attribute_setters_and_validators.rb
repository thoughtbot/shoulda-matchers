module Shoulda
  module Matchers
    module ActiveModel
      class AllowOrDisallowValueMatcher
        # @private
        class AttributeSettersAndValidators
          include Enumerable

          def initialize(allow_value_matcher, values)
            @tuples = values.map do |attribute_name, value|
              AttributeSetterAndValidator.new(
                allow_value_matcher,
                attribute_name,
                value
              )
            end
          end

          def each(&block)
            tuples.each(&block)
          end

          def first_to_produce_validation_messages
            tuples.detect(&method(:has_validation_messages?))
          end

          def first_where_validation_messages_do_not_match
            tuples.detect(&method(:validation_messages_do_not_match?))
          end

          def pretty_print(pp)
            Shoulda::Matchers::Util.pretty_print(self, pp, {
              tuples: tuples,
            })
          end

          protected

          attr_reader :tuples

          private

          def has_validation_messages?(tuple)
            tuple.attribute_setter.set!
            tuple.validator.perform_validation
            tuple.validator.has_validation_messages?
          end

          def validation_messages_do_not_match?(tuple)
            tuple.attribute_setter.set!
            tuple.validator.perform_validation
            !tuple.validator.validation_messages_match?
          end
        end
      end
    end
  end
end
