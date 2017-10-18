module Shoulda
  module Matchers
    module ActiveRecord
      module AssociationMatchers
        # @private
        class OptionalMatcher
          attr_reader :missing_option

          def initialize(attribute_name, optional)
            @attribute_name = attribute_name
            @missing_option = ''
            @submatcher = submatcher_class_for(optional).new(nil).
              for(attribute_name).
              with_message(:required)
          end

          def description
            'required: true'
          end

          def matches?(subject)
            if submatcher.matches?(subject)
              true
            else
              @missing_option =
                'the association should have been defined ' +
                'with `optional: true`, but was not'
              false
            end
          end

          private

          attr_reader :subject, :submatcher

          def submatcher_class_for(optional)
            if optional
              ActiveModel::AllowValueMatcher
            else
              ActiveModel::DisallowValueMatcher
            end
          end
        end
      end
    end
  end
end
