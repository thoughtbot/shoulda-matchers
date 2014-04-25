module Shoulda
  module Matchers
    module ActiveModel
      # The `validate_absence_of` matcher tests the usage of the
      # `validates_absence_of` validation.
      #
      #     class Artillery
      #       include ActiveModel::Model
      #       attr_accessor :arms
      #
      #       validates_absence_of :arms
      #     end
      #
      #     # RSpec
      #     describe Artillery do
      #       it { should validate_absence_of(:arms) }
      #     end
      #
      #     # Test::Unit
      #     class ArtilleryTest < ActiveSupport::TestCase
      #       should validate_absence_of(:arms)
      #     end
      #
      # #### Qualifiers
      #
      # ##### with_message
      #
      # Use `with_message` if you are using a custom validation message.
      #
      #     class Artillery
      #       include ActiveModel::Model
      #       attr_accessor :arms
      #
      #       validates_absence_of :arms,
      #         message: "We're fresh outta arms here, soldier!"
      #     end
      #
      #     # RSpec
      #     describe Artillery do
      #       it do
      #         should validate_absence_of(:arms).
      #           with_message("We're fresh outta arms here, soldier!")
      #       end
      #     end
      #
      #     # Test::Unit
      #     class ArtilleryTest < ActiveSupport::TestCase
      #       should validate_absence_of(:arms).
      #         with_message("We're fresh outta arms here, soldier!")
      #     end
      #
      # @return [ValidateAbsenceOfMatcher}
      #
      def validate_absence_of(attr)
        ValidateAbsenceOfMatcher.new(attr)
      end

      # @private
      class ValidateAbsenceOfMatcher < ValidationMatcher
        def with_message(message)
          @expected_message = message
          self
        end

        def matches?(subject)
          super(subject)
          @expected_message ||= :present
          disallows_value_of(value, @expected_message)
        end

        def description
          "require #{@attribute} to not be set"
        end

        private

        def value
          if reflection
            obj = reflection.klass.new
            if collection?
              [ obj ]
            else
              obj
            end
          elsif [Fixnum, Float].include?(attribute_class)
            1
          elsif attribute_class == BigDecimal
            BigDecimal.new(1, 0)
          elsif !attribute_class || attribute_class == String
            'an arbitrary value'
          else
            attribute_class.new
          end
        end

        def attribute_class
          @subject.class.respond_to?(:columns_hash) &&
            @subject.class.columns_hash[@attribute.to_s].respond_to?(:klass) &&
            @subject.class.columns_hash[@attribute.to_s].klass
        end

        def collection?
          if reflection
            [:has_many, :has_and_belongs_to_many].include?(reflection.macro)
          else
            false
          end
        end

        def reflection
          @subject.class.respond_to?(:reflect_on_association) &&
            @subject.class.reflect_on_association(@attribute)
        end
      end
    end
  end
end
