module Shoulda
  module Matchers
    module ActiveRecord
      # The `have_readonly_attribute` matcher tests usage of the
      # `attr_readonly` macro.
      #
      #     class User < ActiveRecord::Base
      #       attr_readonly :password
      #     end
      #
      #     # RSpec
      #     describe User do
      #       it { should have_readonly_attribute(:password) }
      #     end
      #
      #     # Test::Unit
      #     class UserTest < ActiveSupport::TestCase
      #       should have_readonly_attribute(:password)
      #     end
      #
      # @return [HaveReadonlyAttributeMatcher]
      #
      def have_readonly_attribute(value)
        HaveReadonlyAttributeMatcher.new(value)
      end

      # @private
      class HaveReadonlyAttributeMatcher
        def initialize(attribute)
          @attribute = attribute.to_s
        end

        attr_reader :failure_message, :failure_message_when_negated

        alias failure_message_for_should failure_message
        alias failure_message_for_should_not failure_message_when_negated

        def matches?(subject)
          @subject = subject
          if readonly_attributes.include?(@attribute)
            @failure_message_when_negated = "Did not expect #{@attribute} to be read-only"
            true
          else
            if readonly_attributes.empty?
              @failure_message = "#{class_name} attribute #{@attribute} " <<
                'is not read-only'
            else
              @failure_message = "#{class_name} is making " <<
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
