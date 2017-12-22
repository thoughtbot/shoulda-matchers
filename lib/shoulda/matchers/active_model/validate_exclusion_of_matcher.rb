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
      #     RSpec.describe Game, type: :model do
      #       it do
      #         should validate_exclusion_of(:supported_os).
      #           in_array(['Mac', 'Linux'])
      #       end
      #     end
      #
      #     # Minitest (Shoulda)
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
      #     RSpec.describe Game, type: :model do
      #       it do
      #         should validate_exclusion_of(:floors_with_enemies).
      #           in_range(5..8)
      #       end
      #     end
      #
      #     # Minitest (Shoulda)
      #     class GameTest < ActiveSupport::TestCase
      #       should validate_exclusion_of(:floors_with_enemies).
      #         in_range(5..8)
      #     end
      #
      # #### Qualifiers
      #
      # ##### on
      #
      # Use `on` if your validation applies only under a certain context.
      #
      #     class Game
      #       include ActiveModel::Model
      #       attr_accessor :weapon
      #
      #       validates_exclusion_of :weapon,
      #         in: ['pistol', 'paintball gun', 'stick'],
      #         on: :create
      #     end
      #
      #     # RSpec
      #     RSpec.describe Game, type: :model do
      #       it do
      #         should validate_exclusion_of(:weapon).
      #           in_array(['pistol', 'paintball gun', 'stick']).
      #           on(:create)
      #       end
      #     end
      #
      #     # Minitest (Shoulda)
      #     class GameTest < ActiveSupport::TestCase
      #       should validate_exclusion_of(:weapon).
      #         in_array(['pistol', 'paintball gun', 'stick']).
      #         on(:create)
      #     end
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
      #     RSpec.describe Game, type: :model do
      #       it do
      #         should validate_exclusion_of(:weapon).
      #           in_array(['pistol', 'paintball gun', 'stick']).
      #           with_message('You chose a puny weapon')
      #       end
      #     end
      #
      #     # Minitest (Shoulda)
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

      # @private
      class ValidateExclusionOfMatcher < ValidationMatcher
        def initialize(attribute)
          super(attribute)
          @expected_message = :exclusion
          @array = nil
          @range = nil
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

        protected

        def simple_description
          if @range
            "validate that :#{@attribute} lies outside the range " +
              Shoulda::Matchers::Util.inspect_range(@range)
          else
            description = "validate that :#{@attribute}"

            if @array.many?
              description << " is neither #{inspected_array}"
            else
              description << " is not #{inspected_array}"
            end

            description
          end
        end

        def add_submatchers
          if @range
            add_submatcher_allowing_lower_value
            add_submatcher_disallowing_minimum_value
            add_submatcher_allowing_higher_value
            add_submatcher_disallowing_maximum_value
          elsif @array
            add_submatchers_disallowing_all_values_in_array
          end
        end

        private

        def add_submatchers_disallowing_all_values_in_array
          @array.each do |value|
            add_submatcher_disallowing(value, @expected_message)
          end
        end

        def add_submatcher_allowing_lower_value
          if @minimum != 0
            add_submatcher_allowing(@minimum - 1, @expected_message)
          end
        end

        def add_submatcher_allowing_higher_value
          add_submatcher_allowing(@maximum + 1, @expected_message)
        end

        def add_submatcher_disallowing_minimum_value
          add_submatcher_disallowing(@minimum, @expected_message)
        end

        def add_submatcher_disallowing_maximum_value
          add_submatcher_disallowing(@maximum, @expected_message)
        end

        def inspect_message
          if @range
            @range.inspect
          else
            @array.inspect
          end
        end

        def inspected_array
          Shoulda::Matchers::Util.inspect_values(@array).to_sentence(
            two_words_connector: " nor ",
            last_word_connector: ", nor "
          )
        end
      end
    end
  end
end
