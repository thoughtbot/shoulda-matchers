module Shoulda
  module Matchers
    module ActiveRecord
      module AssociationMatchers
        # @private
        class RequiredMatcher
          attr_reader :missing_option

          def initialize(attribute_name, required)
            @attribute_name = attribute_name
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
              @missing_option = build_missing_option

              false
            end
          end

          private

          attr_reader :attribute_name, :required, :submatcher

          def submatcher_passes?(subject)
            if required
              submatcher.matches?(subject)
            else
              submatcher.does_not_match?(subject)
            end
          end

          def validation_message_key
            :required
          end

          def build_missing_option
            String.new('and for the record ').tap do |missing_option_string|
              missing_option_string <<
                if required
                  'to '
                else
                  'not to '
                end

              missing_option_string << (
                'fail validation if '\
                ":#{attribute_name} is unset; i.e., either the association "\
                'should have been defined with `required: '\
                "#{required.inspect}`, or there "
              )

              missing_option_string <<
                if required
                  'should '
                else
                  'should not '
                end

              missing_option_string << "be a presence validation on :#{attribute_name}"
            end
          end
        end
      end
    end
  end
end
