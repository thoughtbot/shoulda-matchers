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
      #   it { should allow_mass_assignment_of(:first_name).as(:admin) }
      #
      def allow_mass_assignment_of(value)
        AllowMassAssignmentOfMatcher.new(value)
      end

      class AllowMassAssignmentOfMatcher # :nodoc:
        attr_reader :failure_message, :failure_message_when_negated

        alias failure_message_for_should failure_message
        alias failure_message_for_should_not failure_message_when_negated

        def initialize(attribute)
          @attribute = attribute.to_s
          @options = {}
        end

        def as(role)
          if active_model_less_than_3_1?
            raise 'You can specify role only in Rails 3.1 or greater'
          end
          @options[:role] = role
          self
        end

        def matches?(subject)
          @subject = subject
          if attr_mass_assignable?
            if whitelisting?
              @failure_message_when_negated = "#{@attribute} was made accessible"
            else
              if protected_attributes.empty?
                @failure_message_when_negated = 'no attributes were protected'
              else
                @failure_message_when_negated = "#{class_name} is protecting " <<
                  "#{protected_attributes.to_a.to_sentence}, " <<
                  "but not #{@attribute}."
              end
            end
            true
          else
            if whitelisting?
              @failure_message = "Expected #{@attribute} to be accessible"
            else
              @failure_message = "Did not expect #{@attribute} to be protected"
            end
            false
          end
        end

        def description
          [base_description, role_description].compact.join(' ')
        end

        private

        def base_description
          "allow mass assignment of #{@attribute}"
        end

        def role_description
          if role != :default
            "as #{role}"
          end
        end

        def role
          @options[:role] || :default
        end

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
          if active_model_less_than_3_1?
            @subject.class.active_authorizer
          else
            @subject.class.active_authorizer[role]
          end
        end

        def class_name
          @subject.class.name
        end

        def active_model_less_than_3_1?
          ::ActiveModel::VERSION::STRING.to_f < 3.1
        end
      end
    end
  end
end
