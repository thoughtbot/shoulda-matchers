module Shoulda # :nodoc:
  module Matchers
    module ActiveRecord # :nodoc:
      module AssociationMatchers
        class ThroughMatcher
          attr_accessor :missing_option

          def initialize(through, name)
            @through = through
            @name = name
            @missing_option = ''
          end

          def description
            "through #{through}"
          end

          def matches?(subject)
            self.subject = ModelReflector.new(subject, name)
            through.nil? || association_set_properly?
          end

          def association_set_properly?
            through_association_exists? && through_association_correct?
          end

          def through_association_exists?
            if through_reflection.present?
              true
            else
              self.missing_option = "#{name} does not have any relationship to #{through}"
              false
            end
          end

          def through_reflection
            @through_reflection ||= subject.reflect_on_association(through)
          end

          def through_association_correct?
            if option_verifier.correct_for_string?(:through, through)
              true
            else
              self.missing_option =
                "Expected #{name} to have #{name} through #{through}, " +
                "but got it through #{option_verifier.actual_value_for(:through)}"
              false
            end
          end

          private

          attr_accessor :through, :name, :subject

          def option_verifier
            @option_verifier ||= OptionVerifier.new(subject)
          end
        end
      end
    end
  end
end
