module Shoulda # :nodoc:
  module Matchers
    module ActiveModel # :nodoc:
      class BlankValue

        def initialize(instance, attribute)
          @instance = instance
          @attribute = attribute
        end

        def value
          if collection?
            []
          else
            nil
          end
        end

        private

        def collection?
          if reflection
            [:has_many, :has_and_belongs_to_many].include?(reflection.macro)
          else
            false
          end
        end

        def reflection
          @instance.class.respond_to?(:reflect_on_association) &&
            @instance.class.reflect_on_association(@attribute)
        end
      end
    end
  end
end

