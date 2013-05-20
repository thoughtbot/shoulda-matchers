module Shoulda # :nodoc:
  module Matchers
    module ActiveRecord # :nodoc:

      # Ensures that the attribute cannot be changed once the record has been
      # created.
      #
      #   it { should have_readonly_attribute(:password) }
      #
      def have_readonly_attribute(value)
        HaveReadonlyAttributeMatcher.new(value)
      end

      class HaveReadonlyAttributeMatcher # :nodoc:
        def initialize(attribute)
          @attribute = attribute.to_s
        end

        attr_reader :failure_message_for_should, :failure_message_for_should_not

        def matches?(subject)
          @subject = subject
          if readonly_attributes.include?(@attribute)
            @failure_message_for_should_not = "Did not expect #{@attribute} to be read-only"
            true
          else
            if readonly_attributes.empty?
              @failure_message_for_should = "#{class_name} attribute #{@attribute} " <<
                'is not read-only'
            else
              @failure_message_for_should = "#{class_name} is making " <<
                "#{readonly_attributes.to_a.to_sentence} " <<
                "read-only, but not #{@attribute}."
            end
            false
          end
        end

        def description
          "make #{@attribute} read-only"
        end

        private

        def readonly_attributes
          @readonly_attributes ||= (@subject.class.readonly_attributes || [])
        end

        def class_name
          @subject.class.name
        end
      end
    end
  end
end
