module Shoulda
  module Matchers
    module ActiveModel
      class AllowValueMatcher
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

          def first_to_unexpectedly_not_pass
            tuples.detect(&method(:fails_to_pass?))
          end

          def first_to_unexpectedly_not_fail
            tuples.detect(&method(:fails_to_fail?))
          end

          def pretty_print(pp)
            Shoulda::Matchers::Util.pretty_print(self, pp, {
              tuples: tuples,
            })
          end

          protected

          attr_reader :tuples

          private

          def fails_to_pass?(tuple)
            # binding.pry
            tuple.attribute_setter.set!
            # tuple.validator.does_not_pass?
            !tuple.validator.passes?
          end

          def fails_to_fail?(tuple)
            # binding.pry
            tuple.attribute_setter.set!
            # -- BEFORE: -- !tuple.validator.does_not_pass?
            # tuple.validator.passes?
            !tuple.validator.fails?
          end
        end
      end
    end
  end
end
