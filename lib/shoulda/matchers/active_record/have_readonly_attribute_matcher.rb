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
      #     RSpec.describe User, type: :model do
      #       it { should have_readonly_attribute(:password) }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class UserTest < ActiveSupport::TestCase
      #       should have_readonly_attribute(:password)
      #     end
      #
      # #### Multiple attributes
      #
      # You can pass multiple attributes to assert that each one has the
      # validation. Any qualifier chained on the matcher is applied to
      # every attribute uniformly.
      #
      #     class User < ActiveRecord::Base
      #       attr_readonly :name, :email
      #     end
      #
      #     # RSpec
      #     RSpec.describe User, type: :model do
      #       it { should have_readonly_attribute(:name, :email) }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class UserTest < ActiveSupport::TestCase
      #       should have_readonly_attribute(:name, :email)
      #     end
      #
      # @return [HaveReadonlyAttributeMatcher]
      #
      def have_readonly_attribute(*values)
        MatcherCollection.build(values) { |value| HaveReadonlyAttributeMatcher.new(value) }
      end

      # @private
      class HaveReadonlyAttributeMatcher
        def initialize(attribute)
          @attribute = attribute.to_s
        end

        attr_reader :failure_message, :failure_message_when_negated

        def failure_reason
          @failure_message
        end

        def matches?(subject)
          @subject = subject
          if readonly_attributes.include?(@attribute)
            @failure_message_when_negated = "Did not expect #{@attribute}"\
            ' to be read-only'
            true
          else
            @failure_message =
              if readonly_attributes.empty?
                "#{class_name} attribute #{@attribute} " <<
                  'is not read-only'
              else
                "#{class_name} is making " <<
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
          @_readonly_attributes ||= @subject.class.readonly_attributes || []
        end

        def class_name
          @subject.class.name
        end
      end
    end
  end
end
