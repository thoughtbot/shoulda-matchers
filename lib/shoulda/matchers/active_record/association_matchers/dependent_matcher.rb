module Shoulda
  module Matchers
    module ActiveRecord
      module AssociationMatchers
        # @private
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
            if correct_for?(dependent)
              true
            else
              self.missing_option = missing_option_for(name, dependent)
              false
            end
          end

          protected

          attr_accessor :subject, :dependent, :name

          def option_verifier
            @option_verifier ||= OptionVerifier.new(subject)
          end

          def correct_for?(dependent=dependent)
            case dependent
            when true, false then option_verifier.correct_for_boolean?(:dependent, dependent)
            else option_verifier.correct_for_string?(:dependent, dependent)
            end
          end

          def missing_option_for(name=name, dependent=dependent)
            "#{name} should have #{dependent == true ? "a" : dependent} dependency"
          end

        end
      end
    end
  end
end
