module Shoulda
  module Matchers
    module ActiveModel
      # The `allow_mass_assignment_of` matcher tests usage of Rails 3's
      # `attr_accessible` and `attr_protected` macros, asserting that an
      # attribute in your model is contained in either the whitelist or
      # blacklist and thus can or cannot be set via mass assignment.
      #
      #     class Post
      #       include ActiveModel::Model
      #       include ActiveModel::MassAssignmentSecurity
      #       attr_accessor :title
      #
      #       attr_accessible :title
      #     end
      #
      #     class User
      #       include ActiveModel::Model
      #       include ActiveModel::MassAssignmentSecurity
      #       attr_accessor :encrypted_password
      #
      #       attr_protected :encrypted_password
      #     end
      #
      #     # RSpec
      #     describe Post do
      #       it { is_expected.to allow_mass_assignment_of(:title) }
      #     end
      #
      #     describe User do
      #       it { is_expected.not_to allow_mass_assignment_of(:encrypted_password) }
      #     end
      #
      #     # Test::Unit
      #     class PostTest < ActiveSupport::TestCase
      #       should allow_mass_assignment_of(:title)
      #     end
      #
      #     class UserTest < ActiveSupport::TestCase
      #       should_not allow_mass_assignment_of(:encrypted_password)
      #     end
      #
      # #### Optional qualifiers
      #
      # ##### as
      #
      # Use `as` if your mass-assignment rules apply only under a certain role
      # *(Rails >= 3.1 only)*.
      #
      #     class Post
      #       include ActiveModel::Model
      #       include ActiveModel::MassAssignmentSecurity
      #       attr_accessor :title
      #
      #       attr_accessible :title, as: :admin
      #     end
      #
      #     # RSpec
      #     describe Post do
      #       it { is_expected.to allow_mass_assignment_of(:title).as(:admin) }
      #     end
      #
      #     # Test::Unit
      #     class PostTest < ActiveSupport::TestCase
      #       should allow_mass_assignment_of(:title).as(:admin)
      #     end
      #
      # @return [AllowMassAssignmentOfMatcher]
      #
      def allow_mass_assignment_of(value)
        AllowMassAssignmentOfMatcher.new(value)
      end

      # @private
      class AllowMassAssignmentOfMatcher
        attr_reader :failure_message, :failure_message_when_negated

        alias failure_message_for_should failure_message
        alias failure_message_for_should_not failure_message_when_negated

        def initialize(attribute)
          @attribute = attribute.to_s
          @options = {}
        end

        def as(role)
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
          @subject.class.active_authorizer[role]
        end

        def class_name
          @subject.class.name
        end
      end
    end
  end
end
