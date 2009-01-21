module Shoulda # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers # :nodoc:

      class RequireAttributeMatcher < ValidationMatcher

        def with_message(message)
          @expected_message = message if message
          self
        end

        def matches?(subject)
          super(subject)
          @expected_message ||= :blank
          disallows_value_of(blank_value, @expected_message)
        end

        def description
          "require #{@attribute} to be set"
        end

        private

        def blank_value
          if collection?
            []
          else
            nil
          end
        end

        def collection?
          if reflection = @subject.class.reflect_on_association(@attribute)
            [:has_many, :has_and_belongs_to_many].include?(reflection.macro)
          else
            false
          end
        end
      end

      def require_attribute(attr)
        RequireAttributeMatcher.
          new(attr)
      end
    end
  end
end
