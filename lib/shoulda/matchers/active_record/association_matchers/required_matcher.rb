module Shoulda
  module Matchers
    module ActiveRecord
      module AssociationMatchers
        # @private
        class RequiredMatcher
          attr_reader :missing_option

          def initialize(attribute_name, required)
            @required = required
            @submatcher = ActiveModel::DisallowValueMatcher.new(nil).
              for(attribute_name).
              with_message(validation_message_key)
            @missing_option = ''
          end

          def description
            "required: #{required}"
          end

          def matches?(subject)
            if submatcher_passes?(subject)
              true
            else
              @missing_option =
                'the association should have been defined ' +
                "with `required: #{required}`, but was not"
              false
            end
          end

          private

          attr_reader :required, :submatcher

          def submatcher_passes?(subject)
            if required
              submatcher.matches?(subject)
            else
              submatcher.does_not_match?(subject)
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
