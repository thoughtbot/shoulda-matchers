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
            subject = ModelReflector.new(subject, name)

            if dependent.nil? || subject.option_set_properly?(dependent, :dependent)
              true
            else
              self.missing_option = "#{name} should have #{dependent} dependency"
              false
            end
          end

          private
          attr_accessor :dependent, :name
        end
      end
    end
  end
end
