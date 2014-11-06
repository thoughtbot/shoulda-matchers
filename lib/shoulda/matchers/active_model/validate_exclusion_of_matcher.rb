module Shoulda
  module Matchers
    module ActiveModel
      # The `validate_exclusion_of` matcher tests usage of the
      # `validates_exclusion_of` validation, asserting that an attribute cannot
      # take a blacklist of values, and inversely, can take values outside of
      # this list.
      #
      # If your blacklist is an array of values, use `in_array`:
      #
      #     class Game
      #       include ActiveModel::Model
      #       attr_accessor :supported_os
      #
      #       validates_exclusion_of :supported_os, in: ['Mac', 'Linux']
      #     end
      #
      #     # RSpec
      #     describe Game do
      #       it do
      #         should validate_exclusion_of(:supported_os).
      #           in_array(['Mac', 'Linux'])
      #       end
      #     end
      #
      #     # Test::Unit
      #     class GameTest < ActiveSupport::TestCase
      #       should validate_exclusion_of(:supported_os).
      #         in_array(['Mac', 'Linux'])
      #     end
      #
      # If your blacklist is a range of values, use `in_range`:
      #
      #     class Game
      #       include ActiveModel::Model
      #       attr_accessor :supported_os
      #
      #       validates_exclusion_of :supported_os, in: ['Mac', 'Linux']
      #     end
      #
      #     # RSpec
      #     describe Game do
      #       it do
      #         should validate_exclusion_of(:floors_with_enemies).
      #           in_range(5..8)
      #       end
      #     end
      #
      #     # Test::Unit
      #     class GameTest < ActiveSupport::TestCase
      #       should validate_exclusion_of(:floors_with_enemies).
      #         in_range(5..8)
      #     end
      #
      # #### Qualifiers
      #
      # ##### with_message
      #
      # Use `with_message` if you are using a custom validation message.
      #
      #     class Game
      #       include ActiveModel::Model
      #       attr_accessor :weapon
      #
      #       validates_exclusion_of :weapon,
      #         in: ['pistol', 'paintball gun', 'stick'],
      #         message: 'You chose a puny weapon'
      #     end
      #
      #     # RSpec
      #     describe Game do
      #       it do
      #         should validate_exclusion_of(:weapon).
      #           in_array(['pistol', 'paintball gun', 'stick']).
      #           with_message('You chose a puny weapon')
      #       end
      #     end
      #
      #     # Test::Unit
      #     class GameTest < ActiveSupport::TestCase
      #       should validate_exclusion_of(:weapon).
      #         in_array(['pistol', 'paintball gun', 'stick']).
      #         with_message('You chose a puny weapon')
      #     end
      #
      # @return [ValidateExclusionOfMatcher]
      #
      def validate_exclusion_of(attr)
        ValidateExclusionOfMatcher.new(attr)
      end

      # @deprecated Use {#validate_exclusion_of} instead.
      # @return [ValidateExclusionOfMatcher]
      def ensure_exclusion_of(attr)
        Shoulda::Matchers.warn_about_deprecated_method(
          :ensure_exclusion_of,
          :validate_exclusion_of
        )
        validate_exclusion_of(attr)
      end

      # @private
      class ValidateExclusionOfMatcher < ValidationMatcher
        def initialize(attribute)
          super(attribute)
          @array = nil
          @range = nil
          @expected_message = nil
        end

        def in_array(array)
          @array = array
          self
        end

        def in_range(range)
          @range = range
          @minimum = range.first
          @maximum = range.max
          self
        end

        def with_message(message)
          @expected_message = message if message
          self
        end

        def description
          "ensure exclusion of #{@attribute} in #{inspect_message}"
        end

        def matches?(subject)
          super(subject)

          if @range
            allows_lower_value &&
              disallows_minimum_value &&
              allows_higher_value &&
              disallows_maximum_value
          elsif @array
            disallows_all_values_in_array?
          end
        end

        private

        def disallows_all_values_in_array?
          @array.all? do |value|
            disallows_value_of(value, expected_message)
          end
        end

        def allows_lower_value
          @minimum == 0 || allows_value_of(@minimum - 1, expected_message)
        end

        def allows_higher_value
          allows_value_of(@maximum + 1, expected_message)
        end

        def disallows_minimum_value
          disallows_value_of(@minimum, expected_message)
        end

        def disallows_maximum_value
          disallows_value_of(@maximum, expected_message)
        end

        def expected_message
          @expected_message || :exclusion
        end

        def inspect_message
          if @range
            @range.inspect
          else
            @array.inspect
          end
        end
      end
    end
  end
end
