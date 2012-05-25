module Shoulda
  module Matchers
    module ActiveModel
      class FormattedErrorMessage
        def initialize(instance, attribute)
          @instance = instance
          @attribute = attribute
        end

        def message(error_message)
           "#{@attribute} #{error_message}" + formatted_value
        end

        private

        def formatted_value
          if @attribute.to_sym == :base
            ""
          else
            " " + "(#{actual_value})"
          end
        end

        def actual_value
          @instance.send(@attribute).inspect
        end
      end
    end
  end
end
