module Shoulda
  module Matchers
    module ActiveRecord
      # The `define_enum_for` matcher is used to test that the `enum` macro has
      # been used to decorate an attribute with enum methods.
      #
      #     class Process < ActiveRecord::Base
      #       enum status: [:running, :stopped, :suspended]
      #     end
      #
      #     # RSpec
      #     RSpec.describe Process, type: :model do
      #       it { should define_enum_for(:status) }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class ProcessTest < ActiveSupport::TestCase
      #       should define_enum_for(:status)
      #     end
      #
      # #### Qualifiers
      #
      # ##### with_values
      #
      # Use `with_values` to test that the attribute has been defined with a
      # certain set of possible values.
      #
      #     class Process < ActiveRecord::Base
      #       enum status: [:running, :stopped, :suspended]
      #     end
      #
      #     # RSpec
      #     RSpec.describe Process, type: :model do
      #       it do
      #         should define_enum_for(:status).
      #           with_values([:running, :stopped, :suspended])
      #       end
      #     end
      #
      #     # Minitest (Shoulda)
      #     class ProcessTest < ActiveSupport::TestCase
      #       should define_enum_for(:status).
      #         with_values([:running, :stopped, :suspended])
      #     end
      #
      # ##### backed_by_column_of_type
      #
      # Use `backed_by_column_of_type` to test that the attribute is of a
      # certain column type. (The default is `:integer`.)
      #
      #     class LoanApplication < ActiveRecord::Base
      #       enum status: {
      #         active: "active",
      #         pending: "pending",
      #         rejected: "rejected"
      #       }
      #     end
      #
      #     # RSpec
      #     RSpec.describe LoanApplication, type: :model do
      #       it do
      #         should define_enum_for(:status).
      #           with_values(
      #             active: "active",
      #             pending: "pending",
      #             rejected: "rejected"
      #           ).
      #           backed_by_column_of_type(:string)
      #       end
      #     end
      #
      #     # Minitest (Shoulda)
      #     class LoanApplicationTest < ActiveSupport::TestCase
      #       should define_enum_for(:status).
      #         with_values(
      #           active: "active",
      #           pending: "pending",
      #           rejected: "rejected"
      #         ).
      #         backed_by_column_of_type(:string)
      #     end
      #
      #
      # @return [DefineEnumForMatcher]
      #
      def define_enum_for(attribute_name)
        DefineEnumForMatcher.new(attribute_name)
      end

      # @private
      class DefineEnumForMatcher
        def initialize(attribute_name)
          @attribute_name = attribute_name
          @options = { expected_enum_values: [] }
        end

        def description
          description = "define :#{attribute_name} as an enum, backed by "
          description << Shoulda::Matchers::Util.a_or_an(expected_column_type)

          if presented_expected_enum_values.any?
            description << ', with possible values '
            description << Shoulda::Matchers::Util.inspect_value(
              presented_expected_enum_values,
            )
          end

          description
        end

        def with_values(expected_enum_values)
          options[:expected_enum_values] = expected_enum_values
          self
        end

        def with(expected_enum_values)
          Shoulda::Matchers.warn_about_deprecated_method(
            'The `with` qualifier on `define_enum_for`',
            '`with_values`',
          )
          with_values(expected_enum_values)
        end

        def backed_by_column_of_type(expected_column_type)
          options[:expected_column_type] = expected_column_type
          self
        end

        def matches?(subject)
          @record = subject
          enum_defined? && enum_values_match? && column_type_matches?
        end

        def failure_message
          message = "Expected #{model} to #{expectation}"

          if failure_reason
            message << ". However, #{failure_reason}"
          end

          message << '.'

          Shoulda::Matchers.word_wrap(message)
        end

        def failure_message_when_negated
          message = "Expected #{model} not to #{expectation}, but it did."
          Shoulda::Matchers.word_wrap(message)
        end

        private

        attr_reader :attribute_name, :options, :record, :failure_reason

        def expectation
          description
        end

        def presented_expected_enum_values
          if expected_enum_values.is_a?(Hash)
            expected_enum_values.symbolize_keys
          else
            expected_enum_values
          end
        end

        def normalized_expected_enum_values
          to_hash(expected_enum_values)
        end

        def expected_enum_values
          options[:expected_enum_values]
        end

        def presented_actual_enum_values
          if expected_enum_values.is_a?(Array)
            to_array(actual_enum_values)
          else
            to_hash(actual_enum_values).symbolize_keys
          end
        end

        def normalized_actual_enum_values
          to_hash(actual_enum_values)
        end

        def actual_enum_values
          model.send(attribute_name.to_s.pluralize)
        end

        def enum_defined?
          if model.defined_enums.include?(attribute_name.to_s)
            true
          else
            @failure_reason = "no such enum exists in #{model}"
            false
          end
        end

        def enum_values_match?
          passed =
            expected_enum_values.empty? ||
            normalized_actual_enum_values == normalized_expected_enum_values

          if passed
            true
          else
            @failure_reason =
              "the actual enum values for #{attribute_name.inspect} are " +
              Shoulda::Matchers::Util.inspect_value(
                presented_actual_enum_values,
              )
            false
          end
        end

        def column_type_matches?
          if column.type == expected_column_type.to_sym
            true
          else
            @failure_reason =
              "#{attribute_name.inspect} is " +
              Shoulda::Matchers::Util.a_or_an(column.type) +
              ' column'
            false
          end
        end

        def expected_column_type
          options[:expected_column_type] || :integer
        end

        def column
          model.columns_hash[attribute_name.to_s]
        end

        def model
          record.class
        end

        def to_hash(value)
          if value.is_a?(Array)
            value.each_with_index.inject({}) do |hash, (item, index)|
              hash.merge(item.to_s => index)
            end
          else
            value.stringify_keys
          end
        end

        def to_array(value)
          if value.is_a?(Array)
            value.map(&:to_s)
          else
            value.keys.map(&:to_s)
          end
        end
      end
    end
  end
end
