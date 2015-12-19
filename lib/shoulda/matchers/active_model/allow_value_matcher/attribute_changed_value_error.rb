module Shoulda
  module Matchers
    module ActiveModel
      class AllowValueMatcher
        # @private
        class AttributeChangedValueError < Shoulda::Matchers::Error
          attr_accessor :matcher_name, :model, :attribute_name, :value_written,
            :value_read

          def message
            Shoulda::Matchers.word_wrap <<-MESSAGE
The #{matcher_name} matcher attempted to set :#{attribute_name} on
#{model.name} to #{value_written.inspect}, but when the attribute was
read back, it had stored #{value_read.inspect} instead.

This creates a problem because it means that the model is behaving in a way that
is interfering with the test -- there's a mismatch between the test that was
written and test that was actually run.

There are a couple of reasons why this could be happening:

* The writer method for :#{attribute_name} has been overridden and contains
custom logic to prevent certain values from being set or change which values
are stored.
* ActiveRecord is typecasting the incoming value.

Regardless, the fact you're seeing this message usually indicates a larger
problem. Please file an issue on the GitHub repo for shoulda-matchers,
including details about your model and the test you've written, and we can point
you in the right direction:

https://github.com/thoughtbot/shoulda-matchers/issues
            MESSAGE
          end

          def successful?
            false
          end
        end
      end
    end
  end
end
