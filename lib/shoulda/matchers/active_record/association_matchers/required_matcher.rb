module Shoulda
  module Matchers
    module ActiveRecord
      module AssociationMatchers
        # @private
        class RequiredMatcher
          attr_reader :missing_option

          def initialize(attribute_name, required)
            @missing_option = ''
            @submatcher = submatcher_class_for(required).new(nil).
              for(attribute_name).
              with_message(validation_message_key)
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
                'with `required: true`, but was not'
              false
            end
          end

          private

          attr_reader :subject, :submatcher

          def submatcher_class_for(required)
            if required
              ActiveModel::DisallowValueMatcher
            else
              ActiveModel::AllowValueMatcher
            end
          end

          def validation_message_key
            RailsShim.validation_message_key_for_association_required_option
          end
        end
      end
    end
  end
end
