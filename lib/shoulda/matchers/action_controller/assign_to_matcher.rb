module Shoulda # :nodoc:
  module Matchers
    module ActionController # :nodoc:

      # Ensures that the controller assigned to the named instance variable.
      #
      # Options:
      # * <tt>with_kind_of</tt> - The expected class of the instance variable
      #   being checked.
      # * <tt>with</tt> - The value that should be assigned.
      #
      # Example:
      #
      #   it { should assign_to(:user) }
      #   it { should_not assign_to(:user) }
      #   it { should assign_to(:user).with_kind_of(User) }
      #   it { should assign_to(:user).with(@user) }
      def assign_to(variable)
        AssignToMatcher.new(variable)
      end

      class AssignToMatcher # :nodoc:
        attr_reader :failure_message, :negative_failure_message

        def initialize(variable)
          @variable    = variable.to_s
          @options = {}
          @options[:check_value] = false
        end

        def with_kind_of(expected_class)
          @options[:expected_class] = expected_class
          self
        end

        def with(expected_value = nil, &block)
          @options[:check_value] = true
          @options[:expected_value] = expected_value
          @options[:expectation_block] = block
          self
        end

        def matches?(controller)
          @controller = controller
          normalize_expected_value!
          assigned_value? &&
            kind_of_expected_class? &&
            equal_to_expected_value?
        end

        def description
          description = "assign @#{@variable}"
          if @options.key?(:expected_class)
            description << " with a kind of #{@options[:expected_class]}"
          end
          description
        end

        def in_context(context)
          @context = context
          self
        end

        private

        def assigned_value?
          if @controller.instance_variables.map(&:to_s).include?("@#{@variable}")
            @negative_failure_message =
              "Didn't expect action to assign a value for @#{@variable}, " <<
              "but it was assigned to #{assigned_value.inspect}"
            true
          else
            @failure_message =
              "Expected action to assign a value for @#{@variable}"
            false
          end
        end

        def kind_of_expected_class?
          if @options.key?(:expected_class)
            if assigned_value.kind_of?(@options[:expected_class])
              @negative_failure_message =
                "Didn't expect action to assign a kind of #{@options[:expected_class]} " <<
                "for #{@variable}, but got one anyway"
              true
            else
              @failure_message =
                "Expected action to assign a kind of #{@options[:expected_class]} " <<
                "for #{@variable}, but got #{assigned_value.inspect} " <<
                "(#{assigned_value.class.name})"
              false
            end
          else
            true
          end
        end

        def equal_to_expected_value?
          if @options[:check_value]
            if @options[:expected_value] == assigned_value
              @negative_failure_message =
                "Didn't expect action to assign #{@options[:expected_value].inspect} " <<
                "for #{@variable}, but got it anyway"
              true
            else
              @failure_message =
                "Expected action to assign #{@options[:expected_value].inspect} " <<
                "for #{@variable}, but got #{assigned_value.inspect}"
              false
            end
          else
            true
          end
        end

        def normalize_expected_value!
          if @options[:expectation_block]
            @options[:expected_value] = @context.instance_eval(&@options[:expectation_block])
          end
        end

        def assigned_value
          @controller.instance_variable_get("@#{@variable}")
        end
      end
    end
  end
end
