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
      #     describe Process do
      #       it { should define_enum_for(:status) }
      #       end
      #     end
      #
      #     # Test::Unit
      #     class ProcessTest < ActiveSupport::TestCase
      #       should define_enum_for(:status)
      #     end
      #
      # #### Qualifiers
      #
      # ##### with
      #
      # Use `with` to test that the enum has been defined with a certain set of
      # known values.
      #
      #     class Process < ActiveRecord::Base
      #       enum status: [:running, :stopped, :suspended]
      #     end
      #
      #     # RSpec
      #     describe Process do
      #       it do
      #         should define_enum_for(:status).
      #           with([:running, :stopped, :suspended])
      #       end
      #     end
      #
      #     # Test::Unit
      #     class ProcessTest < ActiveSupport::TestCase
      #       should define_enum_for(:status).
      #         with([:running, :stopped, :suspended])
      #     end
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
          @options = {}
        end

        def with(expected_enum_values)
          options[:expected_enum_values] = expected_enum_values
          self
        end

        def matches?(subject)
          @model = subject
          enum_defined? && enum_values_match?
        end

        def failure_message
          "Expected #{expectation}"
        end
        alias :failure_message_for_should :failure_message

        def failure_message_when_negated
          "Did not expect #{expectation}"
        end
        alias :failure_message_for_should_not :failure_message_when_negated

        def description
          desc = "define :#{attribute_name} as an enum"

          if options[:expected_enum_values]
            desc << " with #{options[:expected_enum_values]}"
          end

          desc
        end

        protected

        attr_reader :model, :attribute_name, :options

        def expectation
          "#{model.class.name} to #{description}"
        end

        def expected_enum_values
          hashify(options[:expected_enum_values]).with_indifferent_access
        end

        def enum_method
          attribute_name.to_s.pluralize
        end

        def actual_enum_values
          model.class.send(enum_method)
        end

        def enum_defined?
          model.class.respond_to?(enum_method)
        end

        def enum_values_match?
          expected_enum_values.empty? || actual_enum_values == expected_enum_values
        end

        def hashify(value)
          if value.nil?
            return {}
          end

          if value.is_a?(Array)
            new_value = {}

            value.each_with_index do |v, i|
              new_value[v] = i
            end

            new_value
          else
            value
          end
        end
      end
    end
  end
end
