module Shoulda # :nodoc:
  module Matchers
    module ActiveRecord # :nodoc:
      module AssociationMatchers
        class DependentMatcher
          attr_accessor :missing_option

          def initialize(dependent, name)
            @dependent = dependent
            @name = name
            @missing_option = ''
          end

          def description
            "dependent => #{dependent}"
          end

          def matches?(subject)
            self.subject = ModelReflector.new(subject, name)

            if option_verifier.correct_for_string?(:dependent, dependent)
              true
            else
              self.missing_option = "#{name} should have #{dependent} dependency"
              false
            end
          end

          private

          attr_accessor :subject, :dependent, :name

          def option_verifier
            @option_verifier ||= OptionVerifier.new(subject)
          end
        end
      end
    end
  end
end
