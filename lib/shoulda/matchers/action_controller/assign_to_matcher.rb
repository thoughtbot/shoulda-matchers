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

        def initialize(variable)
          @variable    = variable.to_s
          @check_value = false
        end

        def with_kind_of(expected_class)
          @expected_class = expected_class
          self
        end

        def with(expected_value = nil, &block)
          @check_value       = true
          @expected_value    = expected_value
          @expectation_block = block
          self
        end

        def matches?(controller)
          @controller = controller
          @expected_value = @context.instance_eval(&@expectation_block) if @expectation_block
          assigned_value? && kind_of_expected_class? && equal_to_expected_value?
        end

        attr_reader :failure_message, :negative_failure_message

        def description
          description = "assign @#{@variable}"
          description << " with a kind of #{@expected_class}" if @expected_class
          description
        end

        def in_context(context)
          @context = context
          self
        end

        private

        def assigned_value?
          if !@controller.instance_variables.map(&:to_s).include?("@#{@variable}")
            @failure_message =
              "Expected action to assign a value for @#{@variable}"
            false
          else
            @negative_failure_message =
              "Didn't expect action to assign a value for @#{@variable}, " <<
              "but it was assigned to #{assigned_value.inspect}"
            true
          end
        end

        def kind_of_expected_class?
          return true unless @expected_class
          if assigned_value.kind_of?(@expected_class)
            @negative_failure_message =
              "Didn't expect action to assign a kind of #{@expected_class} " <<
              "for #{@variable}, but got one anyway"
            true
          else
            @failure_message =
              "Expected action to assign a kind of #{@expected_class} " <<
              "for #{@variable}, but got #{assigned_value.inspect} " <<
              "(#{assigned_value.class.name})"
            false
          end
        end

        def equal_to_expected_value?
          return true unless @check_value
          if @expected_value == assigned_value
            @negative_failure_message =
              "Didn't expect action to assign #{@expected_value.inspect} " <<
              "for #{@variable}, but got it anyway"
            true
          else
            @failure_message =
              "Expected action to assign #{@expected_value.inspect} " <<
              "for #{@variable}, but got #{assigned_value.inspect}"
            false
          end
        end

        def assigned_value
          @controller.instance_variable_get("@#{@variable}")
        end

      end

    end
  end
end
