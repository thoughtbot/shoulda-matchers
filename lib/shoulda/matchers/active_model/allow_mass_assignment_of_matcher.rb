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
        attr_reader :failure_message, :negative_failure_message

        def initialize(attribute)
          @attribute = attribute.to_s
          @options = {}
        end

        def as(role)
          if active_model_less_than_3_1?
            raise "You can specify role only in Rails 3.1 or greater"
          end
          @options[:role] = role
          self
        end

        def matches?(subject)
          @subject = subject
          if attr_mass_assignable?
            if whitelisting?
              @negative_failure_message = "#{@attribute} was made accessible"
              @negative_failure_message << " to #{@options[:role].inspect} role" if role_used?
            else
              if protected_attributes.empty?
                @negative_failure_message = "no attributes were protected"
                @negative_failure_message << " from #{@options[:role].inspect} role" if role_used?
              else
                @negative_failure_message = "#{class_name} is protecting " <<
                  "#{protected_attributes.to_a.to_sentence}, " <<
                  "but not #{@attribute}"
                @negative_failure_message << " from #{@options[:role].inspect} role" if role_used?
              end
            end
            true
          else
            if whitelisting?
              @failure_message = "Expected #{@attribute} to be accessible"
              @failure_message << " to #{@options[:role].inspect} role" if role_used?
            else
              @failure_message = "Did not expect #{@attribute} to be protected"
              @failure_message << " from #{@options[:role].inspect} role" if role_used?
            end
            false
          end
        end

        def description
          description = "allow mass assignment of #{@attribute}"
          description << " for #{@options[:role].inspect} role" if role_used?
          description
        end

        private

        def role
          @options[:role] || :default
        end

        def role_used?
          !active_model_less_than_3_1? && !@options[:role].blank? && @options[:role] != :default
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
