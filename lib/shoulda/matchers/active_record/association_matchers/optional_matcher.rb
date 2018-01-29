module Shoulda
  module Matchers
    module ActiveRecord
      module AssociationMatchers
        # @private
        class OptionalMatcher
          attr_reader :missing_option

          def initialize(attribute_name, optional)
            @optional = optional
            @submatcher = ActiveModel::AllowValueMatcher.new(nil).
              for(attribute_name)
            @missing_option = ''
          end

          def description
            "optional: #{optional}"
          end

          def matches?(subject)
            if submatcher_passes?(subject)
              true
            else
              @missing_option =
                'the association should have been defined ' +
                "with `optional: #{optional}`, but was not"
              false
            end
          end

          private

          attr_reader :optional, :submatcher

          def submatcher_passes?(subject)
            if optional
              submatcher.matches?(subject)
            else
              submatcher.does_not_match?(subject)
            end
          end
        end
      end
    end
  end
end
