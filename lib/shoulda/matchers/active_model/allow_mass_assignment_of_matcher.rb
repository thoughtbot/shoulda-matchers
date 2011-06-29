module Shoulda # :nodoc:
  module Matchers
    module ActiveModel # :nodoc:

      # Ensures that the attribute can be set on mass update.
      #
      #   it { should_not allow_mass_assignment_of(:password) }
      #   it { should allow_mass_assignment_of(:first_name) }
      #
      # In Rails 3.1 you can check role as well:
      #
      #   it { should allow_mass_assigment_of(:first_name).as(:admin) }
      #
      def allow_mass_assignment_of(value)
        AllowMassAssignmentOfMatcher.new(value)
      end

      class AllowMassAssignmentOfMatcher # :nodoc:

        def initialize(attribute)
          @attribute = attribute.to_s
        end

        def as(role)
          raise "You can specify role only in Rails 3.1 or greater" unless rails_3_1?
          @role = role
          self
        end

        def matches?(subject)
          @subject = subject
          @role ||= :default
          if attr_mass_assignable?
            if whitelisting?
              @negative_failure_message = "#{@attribute} was made accessible"
            else
              if protected_attributes.empty?
                @negative_failure_message = "no attributes were protected"
              else
                @negative_failure_message = "#{class_name} is protecting " <<
                  "#{protected_attributes.to_a.to_sentence}, " <<
                  "but not #{@attribute}."
              end
            end
            true
          else
            if whitelisting?
              @failure_message =
                "Expected #{@attribute} to be accessible"
            else
              @failure_message =
                "Did not expect #{@attribute} to be protected"
            end
            false
          end
        end

        attr_reader :failure_message, :negative_failure_message

        def description
          "allow mass assignment of #{@attribute}"
        end

        private

        def protected_attributes
          @protected_attributes ||= (@subject.class.protected_attributes || [])
        end

        def accessible_attributes
          @accessible_attributes ||= (@subject.class.accessible_attributes || [])
        end

        def whitelisting?
          authorizer.kind_of?(::ActiveModel::MassAssignmentSecurity::WhiteList)
        end

        def attr_mass_assignable?
          !authorizer.deny?(@attribute)
        end

        def authorizer
          if rails_3_1?
            @subject.class.active_authorizer[@role]
          else
            @subject.class.active_authorizer
          end
        end

        def class_name
          @subject.class.name
        end

        def rails_3_1?
          ::ActiveModel::VERSION::MAJOR == 3 && ::ActiveModel::VERSION::MINOR >= 1
        end
      end
    end
  end
end
