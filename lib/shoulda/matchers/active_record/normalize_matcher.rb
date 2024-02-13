module Shoulda
  module Matchers
    module ActiveRecord
      # The `normalize` matcher is used to ensure attribute normalizations
      # are transforming attribute values as expected.
      #
      # Take this model for example:
      #
      #     class User < ActiveRecord::Base
      #       normalizes :email, with: -> email { email.strip.downcase }
      #     end
      #
      # You can use `normalize` providing an input and defining the expected
      # normalization output:
      #
      #     # RSpec
      #     RSpec.describe User, type: :model do
      #       it do
      #         should normalize(:email).from(" ME@XYZ.COM\n").to("me@xyz.com")
      #       end
      #     end
      #
      #     # Minitest (Shoulda)
      #     class User < ActiveSupport::TestCase
      #       should normalize(:email).from(" ME@XYZ.COM\n").to("me@xyz.com")
      #     end
      #
      # You can use `normalize` to test multiple attributes at once:
      #
      #     class User < ActiveRecord::Base
      #       normalizes :email, :handle, with: -> value { value.strip.downcase }
      #     end
      #
      #     # RSpec
      #     RSpec.describe User, type: :model do
      #       it do
      #         should normalize(:email, :handle).from(" Example\n").to("example")
      #       end
      #     end
      #
      #     # Minitest (Shoulda)
      #     class User < ActiveSupport::TestCase
      #       should normalize(:email, :handle).from(" Example\n").to("example")
      #     end
      #
      # If the normalization accepts nil values with the `apply_to_nil` option,
      # you just need to use `.from(nil).to("Your expected value here")`.
      #
      #     class User < ActiveRecord::Base
      #       normalizes :name, with: -> name { name&.titleize || 'Untitled' },
      #         apply_to_nil: true
      #     end
      #
      #     # RSpec
      #     RSpec.describe User, type: :model do
      #       it { should normalize(:name).from("jane doe").to("Jane Doe") }
      #       it { should normalize(:name).from(nil).to("Untitled") }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class User < ActiveSupport::TestCase
      #       should normalize(:name).from("jane doe").to("Jane Doe")
      #       should normalize(:name).from(nil).to("Untitled")
      #     end
      #
      # @return [NormalizeMatcher]
      #
      def normalize(*attributes)
        if attributes.empty?
          raise ArgumentError, 'need at least one attribute'
        else
          NormalizeMatcher.new(*attributes)
        end
      end

      # @private
      class NormalizeMatcher
        attr_reader :attributes, :from_value, :to_value, :failure_message,
          :failure_message_when_negated

        def initialize(*attributes)
          @attributes = attributes
        end

        def description
          %(
            normalize #{attributes.to_sentence(last_word_connector: ' and ')} from
            ‹#{from_value.inspect}› to ‹#{to_value.inspect}›
          ).squish
        end

        def from(value)
          @from_value = value

          self
        end

        def to(value)
          @to_value = value

          self
        end

        def matches?(subject)
          attributes.all? { |attribute| attribute_matches?(subject, attribute) }
        end

        def does_not_match?(subject)
          attributes.all? { |attribute| attribute_does_not_match?(subject, attribute) }
        end

        private

        def attribute_matches?(subject, attribute)
          return true if normalize_attribute?(subject, attribute)

          @failure_message = build_failure_message(
            attribute,
            subject.class.normalize_value_for(attribute, from_value),
          )
          false
        end

        def attribute_does_not_match?(subject, attribute)
          return true unless normalize_attribute?(subject, attribute)

          @failure_message_when_negated = build_failure_message_when_negated(attribute)
          false
        end

        def normalize_attribute?(subject, attribute)
          subject.class.normalize_value_for(attribute, from_value) == to_value
        end

        def build_failure_message(attribute, attribute_value)
          %(
            Expected to normalize #{attribute.inspect} from ‹#{from_value.inspect}› to
            ‹#{to_value.inspect}› but it was normalized to ‹#{attribute_value.inspect}›
          ).squish
        end

        def build_failure_message_when_negated(attribute)
          %(
            Expected to not normalize #{attribute.inspect} from ‹#{from_value.inspect}› to
            ‹#{to_value.inspect}› but it was normalized
          ).squish
        end
      end
    end
  end
end
