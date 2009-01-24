module Shoulda # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers # :nodoc:

      class ProtectAttributeMatcher

        def initialize(attribute)
          @attribute = attribute.to_s
        end

        def matches?(subject)
          @subject = subject
          if attr_protected?
            if whitelisting?
              @negative_failure_message =
                "Expected #{@attribute} to be accessible"
            else
              @negative_failure_message =
                "Did not expect #{@attribute} to be protected"
            end
            true
          else
            if whitelisting?
              @failure_message = "#{@attribute} was made accessible"
            else
              if protected_attributes.empty?
                @failure_message = "no attributes were protected"
              else
                @failure_message = "#{class_name} is protecting " <<
                  "#{protected_attributes.to_a.to_sentence}, " <<
                  "but not #{@attribute}."
              end
            end
            false
          end
        end

        attr_reader :failure_message, :negative_failure_message

        def description
          "protect #{@attribute} from mass updates"
        end

        private

        def protected_attributes
          @protected_attributes ||= (@subject.class.protected_attributes || [])
        end

        def accessible_attributes
          @accessible_attributes ||= (@subject.class.accessible_attributes || [])
        end

        def whitelisting?
          !accessible_attributes.empty?
        end

        def attr_protected?
          if whitelisting?
            !accessible_attributes.include?(@attribute)
          else
            protected_attributes.include?(@attribute)
          end
        end

        def class_name
          @subject.class.name
        end

      end

      def protect_attribute(value)
        ProtectAttributeMatcher.new(value)
      end

    end
  end
end
